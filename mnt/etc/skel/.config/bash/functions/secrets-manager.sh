#!/bin/bash

# Secrets Management System using age encryption
# Usage: source this file or call functions directly

SECRETS_DIR="/etc/secrets"
AGE_KEY_FILE="$SECRETS_DIR/.age_key"
AGE_PUBLIC_FILE="$SECRETS_DIR/.age_public"
REGISTRY_FILE="$SECRETS_DIR/.secrets_registry"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Security check function
check_security() {
    local file="$1"
    local expected_perm="$2"

    if [[ ! -f "$file" ]]; then
        return 0  # File doesn't exist yet
    fi

    # Check ownership
    if [[ $(stat -c %U "$file") != "$USER" ]]; then
        echo -e "${RED}Error: $file is not owned by $USER${NC}" >&2
        return 1
    fi

    # Check permissions
    local actual_perm=$(stat -c %a "$file")
    if [[ "$actual_perm" != "$expected_perm" ]]; then
        echo -e "${RED}Error: $file has permissions $actual_perm, expected $expected_perm${NC}" >&2
        return 1
    fi

    return 0
}

# Initialize secrets system
secrets-init() {
    local import_key=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --import-key)
                import_key="$2"
                shift 2
                ;;
            *)
                echo "Usage: secrets-init [--import-key /path/to/existing/key]"
                return 1
                ;;
        esac
    done

    echo -e "${YELLOW}Initializing secrets management system...${NC}"

    # Create secrets directory
    if [[ ! -d "$SECRETS_DIR" ]]; then
        sudo mkdir -p "$SECRETS_DIR"
        sudo chown "$USER:$USER" "$SECRETS_DIR"
    fi

    # Set directory permissions
    chmod 700 "$SECRETS_DIR"

    # Check if we're importing an existing key
    if [[ -n "$import_key" ]]; then
        if [[ ! -f "$import_key" ]]; then
            echo -e "${RED}Error: Import key file $import_key not found${NC}" >&2
            return 1
        fi

        cp "$import_key" "$AGE_KEY_FILE"
        chmod 600 "$AGE_KEY_FILE"

        # Extract public key from private key
        age-keygen -y "$AGE_KEY_FILE" > "$AGE_PUBLIC_FILE" 2>/dev/null
        chmod 644 "$AGE_PUBLIC_FILE"

        echo -e "${GREEN}Imported existing age key${NC}"
    else
        # Generate new age key pair
        if [[ ! -f "$AGE_KEY_FILE" ]]; then
            age-keygen -o "$AGE_KEY_FILE" <kcite ref="70"/>
            chmod 600 "$AGE_KEY_FILE"

            # Extract and save public key
            age-keygen -y "$AGE_KEY_FILE" > "$AGE_PUBLIC_FILE" 2>/dev/null
            chmod 644 "$AGE_PUBLIC_FILE"

            echo -e "${GREEN}Generated new age key pair${NC}"
        else
            echo -e "${YELLOW}Age key already exists${NC}"
        fi
    fi

    # Create registry file if it doesn't exist
    if [[ ! -f "$REGISTRY_FILE" ]]; then
        touch "$REGISTRY_FILE"
        chmod 600 "$REGISTRY_FILE"
    fi

    # Display public key for sharing
    echo -e "${GREEN}Your public key (for sharing):${NC}"
    cat "$AGE_PUBLIC_FILE"

    echo -e "${GREEN}Secrets system initialized successfully!${NC}"
    echo -e "${YELLOW}Save your private key ($AGE_KEY_FILE) securely for use on other systems${NC}"
}

# Add a new secret
secrets-add() {
    if [[ $# -lt 3 ]] || [[ $(($# % 2)) -eq 0 ]]; then
        echo "Usage: secrets-add <name> <variable1> <value1> [<variable2> <value2> ...]"
        echo "Example: secrets-add github GITHUB_TOKEN ghp_xxxx"
        echo "Example: secrets-add dns SSH_POWERSLABS_KEY key123 SSH_POWERSLABS_SECRET secret456"
        return 1
    fi

    # Security checks
    check_security "$AGE_KEY_FILE" "600" || return 1
    check_security "$REGISTRY_FILE" "600" || return 1

    local name="$1"
    shift

    local secret_file="$SECRETS_DIR/${name}.age"
    local temp_file=$(mktemp)
    local variables=()

    # Parse variable-value pairs
    while [[ $# -gt 0 ]]; do
        if [[ $# -lt 2 ]]; then
            echo -e "${RED}Error: Missing value for variable $1${NC}" >&2
            rm -f "$temp_file"
            return 1
        fi

        local var="$1"
        local val="$2"
        variables+=("$var")

        echo "export $var=\"$val\"" >> "$temp_file"
        shift 2
    done

    # Encrypt the secret file
    local public_key=$(cat "$AGE_PUBLIC_FILE")
    age -r "$public_key" -o "$secret_file" "$temp_file" <kcite ref="70"/>
    rm -f "$temp_file"

    # Set permissions
    chmod 600 "$secret_file"

    # Update registry
    # Remove existing entry for this name
    grep -v "^$name:" "$REGISTRY_FILE" > "${REGISTRY_FILE}.tmp" 2>/dev/null || true
    mv "${REGISTRY_FILE}.tmp" "$REGISTRY_FILE"

    # Add new entry
    echo "$name:${variables[*]}" >> "$REGISTRY_FILE"

    echo -e "${GREEN}Secret '$name' added successfully${NC}"
    echo -e "${YELLOW}Variables: ${variables[*]}${NC}"
}

# Set (load) a specific secret
secrets-set() {
    if [[ $# -ne 1 ]]; then
        echo "Usage: secrets-set <name>"
        return 1
    fi

    local name="$1"
    local secret_file="$SECRETS_DIR/${name}.age"

    # Security checks
    check_security "$AGE_KEY_FILE" "600" || return 1
    check_security "$secret_file" "600" || return 1

    if [[ ! -f "$secret_file" ]]; then
        echo -e "${RED}Error: Secret '$name' not found${NC}" >&2
        return 1
    fi

    # Decrypt and source the secret
    source <(age --decrypt -i "$AGE_KEY_FILE" "$secret_file" 2>/dev/null) <kcite ref="70"/>

    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}Loaded secret '$name'${NC}"
    else
        echo -e "${RED}Error: Failed to decrypt secret '$name'${NC}" >&2
        return 1
    fi
}

# Set (load) all secrets
secrets-setall() {
    check_security "$REGISTRY_FILE" "600" || return 1

    if [[ ! -f "$REGISTRY_FILE" ]]; then
        echo -e "${YELLOW}No secrets registry found${NC}"
        return 0
    fi

    local loaded=0
    while IFS=: read -r name variables; do
        if [[ -n "$name" ]]; then
            secrets-set "$name"
            if [[ $? -eq 0 ]]; then
                ((loaded++))
            fi
        fi
    done < "$REGISTRY_FILE"

    echo -e "${GREEN}Loaded $loaded secrets${NC}"
}

# Unset a specific secret
secrets-un() {
    if [[ $# -ne 1 ]]; then
        echo "Usage: secrets-un <name>"
        return 1
    fi

    local name="$1"

    # Get variables for this secret from registry
    local variables=$(grep "^$name:" "$REGISTRY_FILE" 2>/dev/null | cut -d: -f2)

    if [[ -z "$variables" ]]; then
        echo -e "${YELLOW}Secret '$name' not found in registry${NC}"
        return 1
    fi

    # Unset each variable
    for var in $variables; do
        unset "$var"
    done

    echo -e "${GREEN}Unset secret '$name' (variables: $variables)${NC}"
}

# Unset all secrets
secrets-unall() {
    check_security "$REGISTRY_FILE" "600" || return 1

    if [[ ! -f "$REGISTRY_FILE" ]]; then
        echo -e "${YELLOW}No secrets registry found${NC}"
        return 0
    fi

    local unset_count=0
    while IFS=: read -r name variables; do
        if [[ -n "$name" && -n "$variables" ]]; then
            for var in $variables; do
                unset "$var"
            done
            ((unset_count++))
        fi
    done < "$REGISTRY_FILE"

    echo -e "${GREEN}Unset $unset_count secrets${NC}"
}

# List available secrets
secrets-list() {
    if [[ ! -f "$REGISTRY_FILE" ]]; then
        echo -e "${YELLOW}No secrets found${NC}"
        return 0
    fi

    echo -e "${GREEN}Available secrets:${NC}"
    while IFS=: read -r name variables; do
        if [[ -n "$name" ]]; then
            echo -e "  ${YELLOW}$name${NC}: $variables"
        fi
    done < "$REGISTRY_FILE"
}

# Export public key for sharing
secrets-pubkey() {
    if [[ -f "$AGE_PUBLIC_FILE" ]]; then
        cat "$AGE_PUBLIC_FILE"
    else
        echo -e "${RED}Error: Public key not found. Run secrets-init first.${NC}" >&2
        return 1
    fi
}
