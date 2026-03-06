#!/usr/bin/env fish

basestrap /mnt ca-certificates acmetool certbot
basestrap /mnt docker docker-dinit
basestrap /mnt rsync samba
