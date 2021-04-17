#!/usr/bin/env bash

# Ideapad Battery Limiter D
# Author: Cledson F. Cavalcanti (cledsonitgames@gmail.com)
# Version: 0.1
# Description: this program limit a Ideapad's battery charge level to 80%.
# Tested on Ideapad 320-15IAP only.

readonly PROG_VERSION="0.1"

# Change to 1 if you want to set a pixel; otherwise let it 0
# I_AM_TESTING=0 sets the file pathes to the default system ones
# You can do this ONLY after testing everything!
readonly I_AM_TESTING=0
# Recommended sleep time: 60 ~ 120 secs
readonly SLEEP_TIME=60

# POWER SUPPLY BATTERY LEVEL (BATT_LEVEL)

# It must be altered to folder name BATTERY_FOLDER present at /sys/class/power_supply/BATTERY_FOLDER
readonly BATT_LEVEL_DEFAULT="/sys/class/power_supply/BAT0/capacity"
readonly BATT_LEVEL_TEST="test_files/capacity"
readonly BATT_LEVEL_WHAT=({$BATT_LEVEL_DEFAULT,$BATT_LEVEL_TEST})

# Capacity file returns battery charge level (%).
readonly BATT_LEVEL="${BATT_LEVEL_WHAT[$I_AM_TESTING]}"

# IDEAPAD'S CONSERVATION MODE CHANNEL
readonly CONSERVATION_MODE_DEFAULT="/sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode"
readonly CONSERVATION_MODE_TEST="test_files/conservation_mode"
readonly CONSERVATION_MODE_WHAT=({$CONSERVATION_MODE_DEFAULT,$CONSERVATION_MODE_TEST})

# This file is a channel to checking and setting conservation mode.
readonly CONSERVATION_MODE="${CONSERVATION_MODE_WHAT[$I_AM_TESTING]}"
readonly CONSERVATION_MODE_ON=1
readonly CONSERVATION_MODE_OFF=0

# LEVEL_MIN is the minimum battery level to keep NOT charging (switch conservation mode off when battery drops below LEVEL_MIN).
# Setting LEVEL_MIN to less than 55 has no effect. There's no known way of switching off the charging outside the default thresholds designed by Lenovo.
readonly LEVEL_MIN=55

# LEVEL_MAX is the maximum battery level to keep charging (switch conservation mode on when battery rises above LEVEL_MAX)
readonly LEVEL_MAX=79


# Ideapad Battery Limiter daemon
echo "Ledso's Ideapad Battery Limiter"
echo "Version $PROG_VERSION"
echo "This script is based on work of Lenovsky (github.com/Lenovsky)"

while [ $? -eq 0 ]; do
  level=$(cat $BATT_LEVEL)
  mode=$(cat $CONSERVATION_MODE)

  echo
  echo "Battery level: $level %"
  if [ "$mode" -eq "$CONSERVATION_MODE_ON" ]; then
    echo "Battery conservation mode is enabled."
  fi

  if [ "$level" -lt "$LEVEL_MIN" ]; then
    if [ "$mode" -eq "$CONSERVATION_MODE_ON" ]; then
      echo "$CONSERVATION_MODE_OFF" > "$CONSERVATION_MODE"
      echo "Battery conservation mode now switched off."
    fi

  elif [ "$level" -gt "$LEVEL_MAX" ]; then
    if [ "$mode" -eq "$CONSERVATION_MODE_OFF" ]; then
      echo "$CONSERVATION_MODE_ON" > "$CONSERVATION_MODE"
      echo "Battery conservation mode now switched on."
    fi
  fi

  echo
  echo "Now sleeping for $SLEEP_TIME secs"
  echo
  sleep $SLEEP_TIME
done
