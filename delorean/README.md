# 🕓 Timezone Service

A simple FastAPI service that provides timezone and UTC offset information based on geographic coordinates and an optional date. Daylight Saving Time (DST) is handled automatically.

## ✨ Features

- Get timezone based on latitude and longitude
- Get UTC offset for a specific date (DST-aware)
- Ready for Docker and Kubernetes deployment

---

## 🚀 Running Locally

### 📦 1. Install Dependencies

```bash
python3 -m venv venv # (Optional)
source venv/bin/activate # (Optional)
pip install -r requirements
```

### 🔥 2. Run the API

```bash
HOST=127.0.0.1 PORT=8000 python3 main.py
# Example usage 1
curl http://localhost:8000/timezone\?lat\=37.7749\&lon\=-122.4194
# response:
{"timezone":"America/Los_Angeles","utc_offset":"-7.0"}
# Example usage 2
curl http://localhost:8000/timezone/offset\?lat\=37.7749\&lon\=-122.4194\&date\=2024-12-20
# response:
{"timezone":"America/Los_Angeles","date":"2024-12-20","utc_offset":"-8.0"}
```

---

## 🚜 Running on minikube

### 1. 🐳 Docker - Build the image

```bash
eval $(minikube docker-env)  # Point Docker to Minikube's daemon
docker build -t delorean:latest .
```

### 2. ☁️ Kubernetes Deployment

This service is Kubernetes-ready. Just apply your manifests or use Helm if you’ve packaged it.

```bash
# Deploy
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Consume service
minikube ip
# Change <minikubes-ip> below to the output of the above command
curl http://<minikubes-ip>:30000/timezone\?lat\=37.7749\&lon\=-122.4194
{"timezone":"America/Los_Angeles","utc_offset":"-7.0"}
curl http://<minikubes-ip>:30000/timezone/offset\?lat\=37.7749\&lon\=-122.4194\&date\=2024-12-20
{"timezone":"America/Los_Angeles","date":"2024-12-20","utc_offset":"-8.0"}

# Delete deployment
kubectl delete deployment delorean
kubectl delete svc delorean-service
```

---

## 📘 API Documentation

## 🧭 Endpoints

### ⏰ GET `/timezone`

**Description:** Get the timezone and current UTC offset for a given location.

**Query Parameters:**

| Name  | Type  | Required | Description             |
| ----- | ----- | -------- | ----------------------- |
| `lat` | float | ✅       | Latitude (-90 to 90)    |
| `lon` | float | ✅       | Longitude (-180 to 180) |

**Response:**

```json
{
  "timezone": "Europe/Berlin",
  "utc_offset": "+2.0"
}
```

---

### ⏱️ GET `/timezone/offset`

**Description:** Get the UTC offset for a given location on a specific date (DST-aware).

**Query Parameters:**

| Name   | Type   | Required | Description                 |
| ------ | ------ | -------- | --------------------------- |
| `lat`  | float  | ✅       | Latitude (-90 to 90)        |
| `lon`  | float  | ✅       | Longitude (-180 to 180)     |
| `date` | string | ✅       | Date in `YYYY-MM-DD` format |

**Response:**

```json
{
  "timezone": "America/New_York",
  "date": "2025-04-09",
  "utc_offset": "-4.0"
}
```

---

## 🩺 Health Check

### ❤️ / 💀 GET `/health`

Simple health check endpoint.

**Response:**

```json
{
  "status": "ok"
}
```
