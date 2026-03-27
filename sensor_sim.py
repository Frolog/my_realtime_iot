import requests, time, random
from datetime import datetime
url = "http://localhost:3000/add"
while True:
    temp = round(random.uniform(20.0, 30.0), 2)
    try:
        response = requests.post(url, json={"name": "Living_Room", "value": temp})
        now = datetime.now().strftime("%H:%M:%S")
        if response.status_code == 200:
            print(f"[{now}] Sent: {temp}C | Success ✅")
        else:
            print(f"[{now}] ERROR {response.status_code} ❌ - Check Server/Elasticsearch")
    except Exception as e:
        print(f"Connection Error: {e}")
    time.sleep(5)
