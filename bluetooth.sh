#!/bin/bash

# Here we set the Bluetooth device address
device_address="00:A4:1C:98:D7:CF"

# Get the connection status of the device
connection_status=$(bluetoothctl info $device_address | grep "Connected:" | awk '{print $2}')

# Here we determine status based on connection status
if [ "$connection_status" == "yes" ]; then
  status="connected"
else
  status="disconnected"
fi

# Let's print initial status
echo "Device $device_address is currently $status"

# If the device is connected, disconnect it
if [ "$connection_status" == "yes" ]; then
  echo "Disconnecting from $device_address..."
  status="disconnected"
  bluetoothctl << EOF
  disconnect $device_address
EOF
else
  # If the device is disconnected, connect to it
  echo "Connecting to $device_address..."
  status="connected"
  bluetoothctl << EOF
  connect $device_address
EOF
fi

# Print final status
echo "Device $device_address is now $status"
