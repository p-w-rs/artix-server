#!/usr/bin/env fish

set FF       ffmpeg ffnvcodec-headers libdvdcss avisynthplus frei0r-plugins ladspa
set PACKAGES (string collect $PACKAGES $FF)
