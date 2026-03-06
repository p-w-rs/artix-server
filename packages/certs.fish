#!/usr/bin/env fish

set CA       ca-certificates acmetool certbot
set PACKAGES (string collect $PACKAGES $CA)
