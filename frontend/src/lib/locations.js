const DEFAULT_LOCATIONS = [
  { name: "Local", timezone: Intl.DateTimeFormat().resolvedOptions().timeZone, offset: 0 },
  { name: "New York", timezone: "America/New_York", offset: -4 }, // EDT
  { name: "Stockholm", timezone: "Europe/Stockholm", offset: 2 }, // CEST
  { name: "Tokyo", timezone: "Asia/Tokyo", offset: 9 },
  { name: "Sydney", timezone: "Australia/Sydney", offset: 10 }
];

export async function getLocations() {
  try {
    const response = await fetch(`/api/bunpass`);
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
  return DEFAULT_LOCATIONS;
}

