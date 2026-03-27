#!/bin/bash

# שם הפרויקט
PROJECT_NAME="my_realtime_iot"

echo "🧹 Cleaning and creating project: $PROJECT_NAME..."
mkdir -p $PROJECT_NAME
cd $PROJECT_NAME

# 1. הקמת שרת Node.js
echo "📦 Setting up Server..."
mkdir -p server
cd server
npm init -y > /dev/null
npm install express cors socket.io @elastic/elasticsearch@8
touch index.js # יצירת קובץ ריק שתוכל להדביק בו קוד
cd ..

# 2. הקמת אפליקציית Flutter
echo "💙 Setting up Flutter Mobile..."
flutter create mobile --overwrite > /dev/null
cd mobile
flutter pub add http socket_io_client
# יצירת קובץ main.dart נקי
cat <<EOF > lib/main.dart
import 'package:flutter/material.dart';
void main() => runApp(MaterialApp(home: Scaffold(body: Center(child: Text("Ready!")))));
EOF
cd ..

# 3. הקמת סביבה וירטואלית לפייתון
echo "🐍 Setting up Python venv..."
python3 -m venv venv
source venv/bin/activate
pip install requests > /dev/null
deactivate

# 4. יצירת קובץ .gitignore בתיקיית האב
cat <<EOF > .gitignore
server/node_modules/
mobile/build/
mobile/.dart_tool/
venv/
*~
.DS_Store
EOF

echo "✅ DONE! Your project structure is clean at: $(pwd)"
