import requests, time, random
url = "http://localhost:3000/add"
while True:
    temp = round(random.uniform(20.0, 30.0), 2)
    try:
        requests.post(url, json={"name": "Living_Room", "value": temp})
        print(f"Sent: {temp}C")
    except: pass
    time.sleep(5)
