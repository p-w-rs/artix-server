#!/usr/bin/env fish

set YT       yt-dlp rtmpdump atomicparsley aria2
set PYT      python-curl_cffi python-mutagen python-pycryptodome python-pycryptodomex python-websockets
set PACKAGES (string collect $PACKAGES $YT $PYT)
