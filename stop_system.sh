#!/bin/bash

echo "🛑 Stopping IoT System Gently..."

# 1. Stop Docker
if [ -f docker-compose.yml ]; then
    sudo docker-compose down
fi

# 2. Kill only project-specific processes (not the whole Chrome/Network)
pkill -f "node index.js"
pkill -f "python3 sensor_sim.py"
pkill -f "flutter_tools"

# 3. Close the specific terminal tabs we opened
# This sends a signal to gnome-terminal to close its children
pkill -f "gnome-terminal"

echo "✅ System Stopped. Browser stays open for your other tabs."
