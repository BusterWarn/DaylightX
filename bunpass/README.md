# BunPass

Microservice for [DaylightX](https://github.com/BusterWarn/DaylightX) built with Bun.
Like a compass, but with a bun instead of a com. 👯

Use `/api/locations` to get recommended locations.
To get coordinates, `/location?place=Kiruna%2C Sweden` :
```json
{
  "lat": "68.1666670",
  "lon": "19.5000000",
  "name": "Kiruna kommun",
  "display_name": "Kiruna kommun, Norrbottens län, Sverige"
}
```

## Installation and setup

To install dependencies:

```bash
bun install
```

To run:

```bash
bun start
```
Or dev mode:
```bash
bun dev
```

Start with a specific port?
```bash
PORT=8080 bun start
```

This project was created using `bun init` in bun v1.2.9. [Bun](https://bun.sh) is a fast all-in-one JavaScript runtime.


## Docker

### Build Docker Image

```bash
docker build -t daylightx-bunpass .
```

### Run Docker Container

```bash
docker run -p 3000:3000 daylightx-bunpass
```

Access the service at http://localhost:3000
