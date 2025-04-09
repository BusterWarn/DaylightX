import os
from datetime import datetime

import pytz
import uvicorn
from fastapi import FastAPI, Query
from timezonefinder import TimezoneFinder

app = FastAPI()
tf = TimezoneFinder()


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/timezone")
def get_timezone(
    lat: float = Query(..., ge=-90, le=90, description="Latitude"),
    lon: float = Query(..., ge=-180, le=180, description="Longitude"),
):
    timezone_name = tf.timezone_at(lng=lon, lat=lat)
    if not timezone_name:
        return {"error": "Timezone not found"}

    timezone = pytz.timezone(timezone_name)
    now = datetime.now(pytz.utc)
    localized_time = now.astimezone(timezone)
    utc_offset = localized_time.utcoffset().total_seconds() / 3600

    return {
        "timezone": timezone_name,
        "utc_offset": f"{'+' if utc_offset >= 0 else ''}{utc_offset}",
    }


@app.get("/timezone/offset")
def get_timezone_offset_for_date(
    lat: float = Query(..., ge=-90, le=90, description="Latitude"),
    lon: float = Query(..., ge=-180, le=180, description="Longitude"),
    date: str = Query(..., description="Date in YYYY-MM-DD format"),
):
    try:
        date_obj = datetime.strptime(date, "%Y-%m-%d")
    except ValueError:
        return {"error": "Invalid date format. Use YYYY-MM-DD."}

    timezone_name = tf.timezone_at(lng=lon, lat=lat)
    if not timezone_name:
        return {"error": "Timezone not found"}

    timezone = pytz.timezone(timezone_name)

    # Localize the naive date object to the timezone
    localized_time = timezone.localize(
        datetime.combine(date_obj.date(), datetime.min.time())
    )
    utc_offset = localized_time.utcoffset().total_seconds() / 3600

    return {
        "timezone": timezone_name,
        "date": date,
        "utc_offset": f"{'+' if utc_offset >= 0 else ''}{utc_offset}",
    }


if __name__ == "__main__":
    host = os.getenv("HOST")
    port = os.getenv("PORT")
    if host is None:
        raise ValueError("HOST is not set")
    if port is None:
        raise ValueError("PORT is not set")
    port = int(port)
    uvicorn.run(app, host=host, port=port)
