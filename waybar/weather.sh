#!/bin/bash
# Weather script for Waybar
# Location: 38°14'08"N 122°39'20"W

timeout 10 curl -s 'https://wttr.in/38.2356,-122.6556?format=%t+%C&u' | sed 's/+//' || echo "Weather unavailable"
