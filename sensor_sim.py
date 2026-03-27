import requests
import time
import random
from datetime import datetime

url = "http://localhost:3000/add"
print("📡 Virtual Sensor v2.0 Starting...")

while True:
    temp = round(random.uniform(20.0, 30.0), 2)
    payload = {"name": "Living_Room_Sensor", "value": temp}
    try:
        response = requests.post(url, json=payload)
        now = datetime.now().strftime("%H:%M:%S")
        if response.status_code == 200:
            print(f"[{now}] Sent: {temp}°C | Success ✅")
        else:
            print(f"[{now}] Error: {response.status_code}")
    except Exception as e:
        print(f"Connection Error: {e}")
    time.sleep(5)
