#!/usr/bin/bash

# Auto-detect device type based on device tree model
if [ -f /sys/firmware/devicetree/base/model ]; then
  MODEL=$(cat /sys/firmware/devicetree/base/model)
  if echo "$MODEL" | grep -q "enchilada"; then
    touch /data/oneplus6
  fi
fi

export PASSIVE="0"

# Set NOSENSOR for OnePlus 6 and Pixel 3 devices (no radar sensor)
if [ -f /data/oneplus6 ] || [ -f /data/pixel3 ]; then
  export NOSENSOR=1
fi

exec ./launch_chffrplus.sh

