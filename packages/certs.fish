#!/usr/bin/env fish

set CA       ca-certificates certbot
set PACKAGES (string collect $PACKAGES $CA)
