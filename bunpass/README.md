# bunpass.

Like a compass, but with a bun instead of a com.

Use `/api/locations` to get recommended locations.
To get coordinates, `/location?place=Kiruna%2C Sweden` :
```json
[
  {
    "place_id": 252445935,
    "licence": "Data © OpenStreetMap contributors, ODbL 1.0. http://osm.org/copyright",
    "osm_type": "relation",
    "osm_id": 935541,
    "lat": "68.166667",
    "lon": "19.5",
    "class": "boundary",
    "type": "administrative",
    "place_rank": 14,
    "importance": 0.5409292482374466,
    "addresstype": "municipality",
    "name": "Kiruna kommun",
    "display_name": "Kiruna kommun, Norrbottens län, Sverige",
    "boundingbox": [
      "67.3562770",
      "69.0599735",
      "17.8998001",
      "23.2867684"
    ]
  }
]
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
