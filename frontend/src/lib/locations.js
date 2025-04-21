const DEFAULT_LOCATIONS = [
  { name: "Local Girls", timezone: Intl.DateTimeFormat().resolvedOptions().timeZone, offset: 0 },
  { name: "New York", timezone: "America/New_York", offset: -4 }, // EDT
  { name: "Stockholm", timezone: "Europe/Stockholm", offset: 2 }, // CEST
  { name: "Tokyo", timezone: "Asia/Tokyo", offset: 9 },
  { name: "Sydney", timezone: "Australia/Sydney", offset: 10 }
];

// Configurable API URL - will be set by environment variables in Kubernetes
const VITE_BUN_URL = import.meta.env.VITE_BUN_URL || undefined;

/**
 * Fetches location data from the API, falling back to default locations if:
 * 1. The API request fails
 * 2. No API URL is configured (local development)
 */
export async function getLocations() {
  console.log('VITE_BUN_URL', VITE_BUN_URL);
  if (VITE_BUN_URL) {
    try {
      const response = await fetch(`${VITE_BUN_URL}/api/locations`);

      if (response.ok) {
        const data = await response.json();
        // If we get valid data back, return it
        if (data && Array.isArray(data) && data.length > 0) {
          return data;
        }
      }
    } catch (error) {
      console.error('Failed to fetch locations:', error);
    }
  }
  return DEFAULT_LOCATIONS;
}
