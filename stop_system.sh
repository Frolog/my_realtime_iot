#!/bin/bash

echo "🛑 Stopping Real-Time IoT System..."

# 1. Stop Docker Containers (Elasticsearch & Kibana)
if [ -f docker-compose.yml ]; then
    echo "🐳 Shutting down Docker containers..."
    sudo docker-compose down
else
    echo "⚠️ docker-compose.yml not found, skipping Docker shutdown."
fi

# 2. Kill Background Processes (Node, Python, Flutter)
echo "🔪 Killing running processes (Node, Python, Flutter)..."
pkill -f "node index.js" 2>/dev/null
pkill -f "python3 sensor_sim.py" 2>/dev/null
pkill -f "flutter_tools" 2>/dev/null
pkill -f "chrome" 2>/dev/null

# 3. Final Cleanup
echo "🧹 Cleaning temporary locks..."
rm -rf mobile/build/ 2>/dev/null

echo "✅ System stopped and cleaned. Everything is fresh!"
