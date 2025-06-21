#!/bin/bash

# This script stops, reloads, and restarts the Bluetooth module and service.
# It will prompt for your sudo password as needed.

echo "Attempting to fix Bluetooth..."

echo "1. Stopping Bluetooth service..."
sudo systemctl stop bluetooth

echo "2. Removing btusb kernel module..."
sudo modprobe -r btusb
# A small delay to ensure the module is fully unloaded
sleep 1

echo "3. Loading btusb kernel module..."
sudo modprobe btusb

echo "4. Starting Bluetooth service..."
sudo systemctl start bluetooth

echo "5. Checking Bluetooth service status..."
sudo systemctl status bluetooth

echo "6. Ensuring Bluetooth service is enabled for future boots..."
sudo systemctl enable bluetooth

echo "Bluetooth fix attempt complete. Please check your Bluetooth devices."
