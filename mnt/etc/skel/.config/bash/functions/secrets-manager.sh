#!/bin/bash

# Secrets Management System using age encryption (no passphrase key)
# Source this file in your .bashrc

SECRETS_DIR="/etc/secrets"
AGE_KEY_FILE="$SECRETS_DIR/.age_key"
AGE_PUBLIC_FILE="$SECRETS_DIR/.age_public"
REGISTRY_FILE="$SECRETS_DIR/.secrets_registry"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ─── Internal Helpers ────────────────────────────────────────────────────────

_secrets_check_deps() {
    if ! command -v age &>/dev/null || ! command -v age-keygen &>/dev/null; then
        echo -e "${RED}Error: 'age' is not installed. Install it with: sudo apt install age${NC}" >&2
        return 1
    fi
}

_secrets_check_dir() {
    if [[ ! -d "$SECRETS_DIR" ]]; then
        echo -e "${RED}Error: $SECRETS_DIR does not exist. Run secrets-init first.${NC}" >&2
        return 1
    fi

    local dir_perm dir_owner
    dir_perm=$(stat -c %a "$SECRETS_DIR")
    dir_owner=$(stat -c %U "$SECRETS_DIR")

    if [[ "$dir_owner" != "$USER" ]]; then
        echo -e "${RED}Error: $SECRETS_DIR is not owned by $USER (owned by $dir_owner)${NC}" >&2
        return 1
    fi

    if [[ "$dir_perm" != "700" ]]; then
        echo -e "${RED}Error: $SECRETS_DIR has permissions $dir_perm, expected 700${NC}" >&2
        return 1
    fi
}

_secrets_check_file() {
    local file="$1"
    local expected_perm="${2:-600}"

    if [[ ! -f "$file" ]]; then
        echo -e "${RED}Error: $file not found${NC}" >&2
        return 1
    fi

    local actual_perm file_owner
    actual_perm=$(stat -c %a "$file")
    file_owner=$(stat -c %U "$file")

    if [[ "$file_owner" != "$USER" ]]; then
        echo -e "${RED}Error: $file is not owned by $USER (owned by $file_owner)${NC}" >&2
        return 1
    fi

    if [[ "$actual_perm" != "$expected_perm" ]]; then
        echo -e "${RED}Error: $file has permissions $actual_perm, expected $expected_perm${NC}" >&2
        return 1
    fi
}

# ─── Public Commands ─────────────────────────────────────────────────────────

# Initialize the secrets system
secrets-init() {
    local import_key=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            --import-key)
                import_key="$2"
                shift 2
                ;;
            *)
                echo "Usage: secrets-init [--import-key /path/to/existing/.age_key]"
                return 1
                ;;
        esac
    done

    _secrets_check_deps || return 1

    echo -e "${YELLOW}Initializing secrets system...${NC}"

    # Create and secure the directory
    if [[ ! -d "$SECRETS_DIR" ]]; then
        sudo mkdir -p "$SECRETS_DIR"
        sudo chown "$USER:$USER" "$SECRETS_DIR"
    fi
    chmod 700 "$SECRETS_DIR"

    if [[ -n "$import_key" ]]; then
        # Import an existing key from another system
        if [[ ! -f "$import_key" ]]; then
            echo -e "${RED}Error: Key file not found at $import_key${NC}" >&2
            return 1
        fi
        cp "$import_key" "$AGE_KEY_FILE"
        chmod 600 "$AGE_KEY_FILE"

        # Derive public key from private key
        age-keygen -y "$AGE_KEY_FILE" > "$AGE_PUBLIC_FILE"
        chmod 644 "$AGE_PUBLIC_FILE"

        echo -e "${GREEN}Imported existing age key${NC}"
    else
        if [[ -f "$AGE_KEY_FILE" ]]; then
            echo -e "${YELLOW}Age key already exists at $AGE_KEY_FILE, skipping generation${NC}"
        else
            # Generate a new passphrase-free age key
            age-keygen -o "$AGE_KEY_FILE" 2>/dev/null
            chmod 600 "$AGE_KEY_FILE"

            # Derive and save public key
            age-keygen -y "$AGE_KEY_FILE" > "$AGE_PUBLIC_FILE"
            chmod 644 "$AGE_PUBLIC_FILE"

            echo -e "${GREEN}Generated new passphrase-free age key${NC}"
        fi
    fi

    # Create registry if it doesn't exist
    if [[ ! -f "$REGISTRY_FILE" ]]; then
        touch "$REGISTRY_FILE"
        chmod 600 "$REGISTRY_FILE"
    fi

    echo ""
    echo -e "${GREEN}Public key (safe to share):${NC}"
    cat "$AGE_PUBLIC_FILE"
    echo ""
    echo -e "${YELLOW}To use on another system, copy these files:${NC}"
    echo -e "  Private key : $AGE_KEY_FILE"
    echo -e "  Public key  : $AGE_PUBLIC_FILE"
    echo -e "  Registry    : $REGISTRY_FILE"
    echo -e "  Secrets     : $SECRETS_DIR/*.age"
    echo -e "${YELLOW}Then run: secrets-init --import-key /path/to/.age_key${NC}"
}

# Add a new secret file with one or more variables
# Usage: secrets-add <name> <VAR1> <value1> [<VAR2> <value2> ...]
secrets-add() {
    if [[ $# -lt 3 ]] || [[ $(( ($# - 1) % 2 )) -ne 0 ]]; then
        echo "Usage: secrets-add <name> <VARIABLE1> <value1> [<VARIABLE2> <value2> ...]"
        echo ""
        echo "Examples:"
        echo "  secrets-add github GITHUB_TOKEN ghp_xxxxxxxxxxxx"
        echo "  secrets-add huggingface HF_TOKEN hf_xxxxxxxxxxxx"
        echo "  secrets-add dns SSH_POWERSLABS_KEY mykey SSH_POWERSLABS_SECRET mysecret"
        return 1
    fi

    _secrets_check_deps  || return 1
    _secrets_check_dir   || return 1
    _secrets_check_file "$AGE_KEY_FILE"    "600" || return 1
    _secrets_check_file "$AGE_PUBLIC_FILE" "644" || return 1
    _secrets_check_file "$REGISTRY_FILE"   "600" || return 1

    local name="$1"
    shift

    local secret_file="$SECRETS_DIR/${name}.age"
    local temp_file
    temp_file=$(mktemp)
    local variables=()

    # Write variable exports to temp file
    while [[ $# -gt 0 ]]; do
        local var="$1"
        local val="$2"
        variables+=("$var")
        echo "export $var=\"$val\"" >> "$temp_file"
        shift 2
    done

    # Encrypt with the public key (no passphrase needed for decryption, just the key file)
    local public_key
    public_key=$(cat "$AGE_PUBLIC_FILE")
    age -r "$public_key" -o "$secret_file" "$temp_file"
    local exit_code=$?

    # Always remove plaintext temp file
    rm -f "$temp_file"

    if [[ $exit_code -ne 0 ]]; then
        echo -e "${RED}Error: Encryption failed${NC}" >&2
        return 1
    fi

    chmod 600 "$secret_file"

    # Update registry: remove old entry for this name, add new one
    grep -v "^${name}:" "$REGISTRY_FILE" > "${REGISTRY_FILE}.tmp" 2>/dev/null || true
    mv "${REGISTRY_FILE}.tmp" "$REGISTRY_FILE"
    echo "${name}:${variables[*]}" >> "$REGISTRY_FILE"
    chmod 600 "$REGISTRY_FILE"

    echo -e "${GREEN}Secret '$name' saved${NC}"
    echo -e "${YELLOW}  Variables: ${variables[*]}${NC}"
}

# Load a specific secret into the current shell environment
secrets-set() {
    if [[ $# -ne 1 ]]; then
        echo "Usage: secrets-set <name>"
        return 1
    fi

    local name="$1"
    local secret_file="$SECRETS_DIR/${name}.age"

    _secrets_check_deps                    || return 1
    _secrets_check_dir                     || return 1
    _secrets_check_file "$AGE_KEY_FILE"    "600" || return 1
    _secrets_check_file "$secret_file"     "600" || return 1

    source <(age --decrypt -i "$AGE_KEY_FILE" "$secret_file" 2>/dev/null)

    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}Loaded '$name'${NC}"
    else
        echo -e "${RED}Error: Failed to decrypt '$name'${NC}" >&2
        return 1
    fi
}

# Load all secrets into the current shell environment
secrets-setall() {
    _secrets_check_deps                  || return 1
    _secrets_check_dir                   || return 1
    _secrets_check_file "$REGISTRY_FILE" "600" || return 1

    local loaded=0
    while IFS=: read -r name _variables; do
        [[ -z "$name" ]] && continue
        secrets-set "$name" && (( loaded++ ))
    done < "$REGISTRY_FILE"

    echo -e "${GREEN}Loaded $loaded secret(s)${NC}"
}

# Unset variables for a specific secret
secrets-un() {
    if [[ $# -ne 1 ]]; then
        echo "Usage: secrets-un <name>"
        return 1
    fi

    _secrets_check_file "$REGISTRY_FILE" "600" || return 1

    local name="$1"
    local variables
    variables=$(grep "^${name}:" "$REGISTRY_FILE" 2>/dev/null | cut -d: -f2)

    if [[ -z "$variables" ]]; then
        echo -e "${YELLOW}No registry entry found for '$name'${NC}"
        return 1
    fi

    for var in $variables; do
        unset "$var"
    done

    echo -e "${GREEN}Unset '$name' (${variables})${NC}"
}

# Unset all secret variables
secrets-unall() {
    _secrets_check_file "$REGISTRY_FILE" "600" || return 1

    local count=0
    while IFS=: read -r name variables; do
        [[ -z "$name" || -z "$variables" ]] && continue
        for var in $variables; do
            unset "$var"
        done
        (( count++ ))
    done < "$REGISTRY_FILE"

    echo -e "${GREEN}Unset $count secret(s)${NC}"
}

# List all registered secrets and their variable names
secrets-list() {
    _secrets_check_file "$REGISTRY_FILE" "600" || return 1

    echo -e "${GREEN}Registered secrets:${NC}"
    while IFS=: read -r name variables; do
        [[ -z "$name" ]] && continue
        printf "  ${YELLOW}%-20s${NC} %s\n" "$name" "$variables"
    done < "$REGISTRY_FILE"
}
