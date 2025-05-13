# 🌙 LunaK - Moon Data API

A lightweight Spring Boot microservice that provides real-time moon data for any location on Earth.

## 🚀 Overview

LunaK is a simple REST API that returns comprehensive astronomical data about the moon, including:
- Current position (azimuth, altitude, constellation)
- Phase information (name, illumination percentage)
- Distance from Earth
- Rise and set times
- Visibility status

## 📡 API Endpoint

### GET `/`

Simple Homepage in Json with API instructions.

### GET `/moon`

Returns detailed moon data for a specific location and time.

**Parameters:**
- `latitude` (required): Latitude of the observer's location (-90 to 90)
- `longitude` (required): Longitude of the observer's location (-180 to 180)
- `time` (optional): ISO 8601 datetime (defaults to current time if not provided)

**Example Request:**
```
GET /moon?latitude=59.3293&longitude=18.0686&time=2024-01-15T12:00:00Z
```

**Example Response:**
```json
{
  "requestTime": "2024-01-15T12:00:00Z",
  "location": {
    "latitude": 59.3293,
    "longitude": 18.0686,
    "elevation": 0.0
  },
  "position": {
    "azimuth": 142.38342497867094,
    "altitude": 19.901495628552375,
    "rightAscension": 23.179386439142586,
    "declination": -4.99924279978298,
    "constellation": "Aquarius"
  },
  "phase": {
    "phaseAngle": 114.78034368973036,
    "phaseName": "Waxing Gibbous",
    "illuminatedFraction": 0.7095703144850112,
    "illuminatedPercentage": 70.95703144850111
  },
  "distance": {
    "kilometers": 405402.8058826967,
    "astronomicalUnits": 0.002709950375534969,
    "angularDiameterArcminutes": 29.465531995347106
  },
  "libration": {
    "longitude": 0.0,
    "latitude": 0.0,
    "distance": 405402.8058826967
  },
  "times": {
    "nextRise": "2024-01-15T18:00:00Z",
    "nextSet": "2024-01-16T06:00:00Z"
  },
  "ecliptic": {
    "longitude": 0.0,
    "latitude": 0.0
  },
  "visibility": "Above horizon"
}
```

## ⚙️ Prerequisites

- Java 17 or higher
- Git
- Docker (optional)

## 💻 Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/LunaK.git
cd LunaK
```

2. Install Java 17 (if not already installed):
```bash
# Update package list
sudo apt update

# Install Java 17
sudo apt install openjdk-17-jdk

# Verify installation
java --version
```

## 🏃‍♂️ Running the Application

### Local Development

The project includes Maven Wrapper, so you don't need to install Maven separately.

1. Make the Maven wrapper executable:
```bash
chmod +x mvnw
```

2. Run the application:
```bash
./mvnw spring-boot:run
```

The API will start on port 8080 by default.

### 🐳 Docker

Build and run using Docker:

```bash
# Build the Docker image
docker build -t lunak .

# Run the container
docker run -p 8080:8080 lunak

# Or run with environment variables
docker run -p 8080:8080 -e SERVER_PORT=8081 lunak
```

For Docker Compose:

```yaml
version: '3.8'
services:
  lunak:
    build: .
    ports:
      - "8080:8080"
    environment:
      - SERVER_PORT=8080
```

## 🔧 Configuration

The application uses the default Spring Boot configuration. To modify settings, edit `src/main/resources/application.properties`:

```properties
# Change port (default: 8080)
server.port=8080

# Bind to all network interfaces
server.address=0.0.0.0
```

## 🏥 Health Check

The application includes Spring Actuator for health monitoring:

```
GET /actuator/health
```

## 📦 Building for Production

Create a production JAR:

```bash
./mvnw clean package
```

The JAR file will be created in the `target/` directory.

## 🤝 Contributing

Part of the DaylightX project: https://github.com/BusterWarn/DaylightX

## 📄 License

[Your License Here]
