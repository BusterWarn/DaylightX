import { Hono } from 'hono';
import { serveStatic } from 'hono/bun';
import { NominatimResponse } from './types';

const app = new Hono();
const PORT: number = process.env.PORT ? parseInt(process.env.PORT) : 3000;

// Create a route to get all recommended locations as JSON
app.get('/api/locations', (c) => {
  return c.json(RECOMMENDED_LOCATIONS);
});// Also serve static files from the public directory

app.use('/public/*', serveStatic({ root: './' }));// index.ts

// List of recommended locations
const RECOMMENDED_LOCATIONS = [
  "Kiruna, Sweden",
  "Umea, Sweden",
  "Stockholm, Sweden",
  "Malmo, Sweden",
  "Gothenburg, Sweden",
  "Ostersund, Sweden",
  "Visby, Sweden",
  "London, United Kingdom",
  "Paris, France",
  "Berlin, Germany",
  "Madrid, Spain",
  "Rome, Italy",
  "Amsterdam, Netherlands",
  "Copenhagen, Denmark",
  "Oslo, Norway",
  "Helsinki, Finland",
  "Warsaw, Poland",
  "Vienna, Austria",
  "New York, United States",
  "Los Angeles, United States",
  "Toronto, Canada",
  "Vancouver, Canada",
  "Mexico City, Mexico",
  "Tokyo, Japan",
  "Beijing, China",
  "Seoul, South Korea",
  "Bangkok, Thailand",
  "Mumbai, India",
  "Sydney, Australia",
  "Auckland, New Zealand",
  "São Paulo, Brazil",
  "Buenos Aires, Argentina",
  "Cape Town, South Africa",
  "Cairo, Egypt",
];

// Helper function to fetch location data from Nominatim
async function fetchLocationData(placeName: string): Promise<NominatimResponse[]> {
  try {
    const encodedPlace = encodeURIComponent(placeName);
    const response = await fetch(
      `https://nominatim.openstreetmap.org/search?q=${encodedPlace}&format=json&limit=1`,
      {
        headers: {
          'User-Agent': 'LocationAPIDemo/1.0',
        },
      }
    );

    if (!response.ok) {
      throw new Error(`HTTP error! Status: ${response.status}`);
    }

    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Error fetching location data:', error);
    throw error;
  }
}

// Root endpoint - Serve the static HTML file
app.get('/', serveStatic({ root: './public', path: 'index.html' }));

// Location endpoint - Get information about a specific place
app.get('/location', async (c) => {
  const place: string | undefined = c.req.query('place');

  if (!place) {
    return c.json({ error: 'Place parameter is required' }, 400);
  }

  try {
    const locationData = await fetchLocationData(place);

    if (!locationData || locationData.length === 0) {
      return c.json({ error: 'Location not found' }, 404);
    }

    const highestImportanceLocation = locationData
      .sort((a, b) => b.importance - a.importance)
      .slice(0, 1)[0];

    return c.json({
      lat: highestImportanceLocation.lat,
      lon: highestImportanceLocation.lon,
      name: highestImportanceLocation.name,
      display_name: highestImportanceLocation.display_name
    });
  } catch (error) {
    console.error('Error processing location request:', error);
    return c.json({ error: 'Failed to fetch location data' }, 500);
  }
});

// Start the server
console.log(`Server running at http://localhost:${PORT}`);
export default {
  port: PORT,
  fetch: app.fetch,
};
