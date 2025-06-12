#!/usr/bin/env python3

import time
import sys

# IMPORTANT: Change this to your actual network interface
# You can find it by running 'ip a' in your terminal
INTERFACE = "wlan0" # <--- !!! CHANGE THIS !!!

def get_bytes(interface, direction):
    """Reads the current byte count for a given interface and direction (rx/tx)."""
    try:
        with open(f"/sys/class/net/{interface}/statistics/{direction}_bytes", 'r') as f:
            return int(f.read())
    except FileNotFoundError:
        print(f"Error: Interface '{interface}' or path not found for {direction}_bytes.", file=sys.stderr)
        return 0
    except Exception as e:
        print(f"Error reading {direction}_bytes for {interface}: {e}", file=sys.stderr)
        return 0

def humanize_bytes_no_decimals(bytes_val, unit_override=None):
    """Converts bytes to human-readable format without decimals."""
    if bytes_val == 0:
        return "0 B/s"

    sizes = ['B/s', 'KB/s', 'MB/s', 'GB/s', 'TB/s']
    i = 0
    while bytes_val >= 1024 and i < len(sizes) - 1:
        bytes_val /= 1024
        i += 1
    
    if unit_override:
        return f"{int(bytes_val)} {unit_override}"
    return f"{int(bytes_val)} {sizes[i]}"

def main():
    rx_bytes_prev = get_bytes(INTERFACE, "rx")
    tx_bytes_prev = get_bytes(INTERFACE, "tx")
    time.sleep(1) # Wait for 1 second to calculate speed
    rx_bytes_curr = get_bytes(INTERFACE, "rx")
    tx_bytes_curr = get_bytes(INTERFACE, "tx")

    down_speed = rx_bytes_curr - rx_bytes_prev
    up_speed = tx_bytes_curr - tx_bytes_prev

    down_speed_human = humanize_bytes_no_decimals(down_speed)
    up_speed_human = humanize_bytes_no_decimals(up_speed)

    # Format the output for the bar
    print(f"󰛶 {down_speed_human} ↓↑ {up_speed_human} 󰛴")

if __name__ == "__main__":
    main()
