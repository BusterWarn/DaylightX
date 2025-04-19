<script>
  import { onMount, onDestroy } from 'svelte';
  import { fade } from 'svelte/transition';
  import Sun from './components/Sun.svelte';
  import Moon from './components/Moon.svelte';
  import Stars from './components/Stars.svelte';
  import LocationSelector from './components/LocationSelector.svelte';
  import InfoPanel from './components/InfoPanel.svelte';
  import './global.css';

  // Available locations with timezone offsets
  const locations = [
    { name: "Local", timezone: Intl.DateTimeFormat().resolvedOptions().timeZone, offset: 0 },
    { name: "New York", timezone: "America/New_York", offset: -4 }, // EDT
    { name: "Stockholm", timezone: "Europe/Stockholm", offset: 2 }, // CEST
    { name: "Tokyo", timezone: "Asia/Tokyo", offset: 9 },
    { name: "Sydney", timezone: "Australia/Sydney", offset: 10 }
  ];

  // Initial state
  let selectedLocation = locations[0]; // Default to local time
  let currentTime = new Date();
  let sunriseTime, sunsetTime, solarNoon;
  let dayProgress = 0;
  let dayPhase = '';
  let windowWidth = 0;
  let windowHeight = 0;
  let updateInterval;

// Set up location and time
  function setLocation(location) {
    selectedLocation = location;
    calculateDayTimes();
    calculateDayProgress(); // Add this line to update day progress immediately
  }

  // Calculate sunrise and sunset times
  function calculateDayTimes() {
    // For a real app, we would calculate the actual sunrise/sunset times
    // based on date and geographical coordinates. For now, we'll use simplified times.
    const today = new Date(currentTime);

    // Set time to midnight in the selected timezone
    today.setHours(0, 0, 0, 0);
    if (selectedLocation.offset !== 0) {
      const localOffset = -today.getTimezoneOffset() / 60;
      const hourDifference = selectedLocation.offset - localOffset;
      today.setHours(today.getHours() + hourDifference);
    }

    // Set sunrise, solar noon, and sunset times
    sunriseTime = new Date(today);
    sunriseTime.setHours(6, 0, 0, 0);

    solarNoon = new Date(today);
    solarNoon.setHours(12, 0, 0, 0);

    sunsetTime = new Date(today);
    sunsetTime.setHours(18, 0, 0, 0);
  }

  // Calculate sun position based on current time
  function calculateDayProgress() {
    let now = new Date(currentTime);

    // Adjust time for selected timezone if not local
    if (selectedLocation.name !== "Local") {
      const localOffset = -now.getTimezoneOffset() / 60;
      const hourDifference = selectedLocation.offset - localOffset;
      now = new Date(now.getTime() + hourDifference * 60 * 60 * 1000);
    }

    // Calculate progress (0 = sunrise, 0.5 = noon, 1 = sunset)
    if (now < sunriseTime) {
      // Before sunrise (night)
      const midnight = new Date(sunriseTime);
      midnight.setHours(0, 0, 0, 0);
      const msSinceMidnight = now - midnight;
      const msUntilSunrise = sunriseTime - midnight;
      dayProgress = -0.25 + (msSinceMidnight / msUntilSunrise) * 0.25;
    } else if (now > sunsetTime) {
      // After sunset (night)
      const msSinceSunset = now - sunsetTime;
      const midnight = new Date(sunsetTime);
      midnight.setHours(24, 0, 0, 0);
      const msUntilMidnight = midnight - sunsetTime;
      dayProgress = 1 + (msSinceSunset / msUntilMidnight) * 0.25;
    } else {
      // During day
      dayProgress = (now - sunriseTime) / (sunsetTime - sunriseTime);
    }

    // Determine day phase
    if (dayProgress < 0) dayPhase = "Night (pre-dawn)";
    else if (dayProgress < 0.1) dayPhase = "Sunrise";
    else if (dayProgress < 0.4) dayPhase = "Morning";
    else if (dayProgress < 0.6) dayPhase = "Midday";
    else if (dayProgress < 0.9) dayPhase = "Afternoon";
    else if (dayProgress < 1) dayPhase = "Sunset";
    else dayPhase = "Night";
  }

  // Get sky color based on time of day
  function getSkyColor(progress) {
    if (progress < 0) {
      // Night before sunrise
      const nightProgress = (progress + 0.25) / 0.25;
      return `rgb(${10 + 20 * nightProgress}, ${20 + 30 * nightProgress}, ${40 + 50 * nightProgress})`;
    } else if (progress > 1) {
      // Night after sunset
      const nightProgress = (progress - 1) / 0.25;
      return `rgb(${30 - 20 * nightProgress}, ${50 - 30 * nightProgress}, ${90 - 50 * nightProgress})`;
    } else if (progress < 0.1) {
      // Sunrise transition
      const sunriseProgress = progress / 0.1;
      return `rgb(${30 + 225 * sunriseProgress}, ${50 + 100 * sunriseProgress}, ${90 + 110 * sunriseProgress})`;
    } else if (progress > 0.9) {
      // Sunset transition
      const sunsetProgress = (progress - 0.9) / 0.1;
      return `rgb(${255 - 225 * sunsetProgress}, ${150 - 100 * sunsetProgress}, ${200 - 110 * sunsetProgress})`;
    } else {
      // Day time
      const intensity = Math.sin(Math.PI * progress);
      const blueIntensity = 200 + Math.sin(Math.PI * progress) * 55;
      return `rgb(135, ${150 + intensity * 50}, ${blueIntensity})`;
    }
  }

  // Get ground color based on time of day
  function getGroundColor(progress) {
    if (progress < 0 || progress > 1) {
      // Night
      return `linear-gradient(to bottom, #1a2e12, #0a1a0a)`;
    } else if (progress < 0.1 || progress > 0.9) {
      // Dawn/Dusk
      return `linear-gradient(to bottom, #2a4e1a, #1a2e12)`;
    } else {
      // Day
      return `linear-gradient(to bottom, #4b7e29, #2a451a)`;
    }
  }

  // Update state every 10 minutes
  function startUpdateCycle() {
    // Initial update
    updateState();

    // Set interval (every 10 minutes)
    const TEN_MINUTES = 10 * 60 * 1000;
    updateInterval = setInterval(updateState, TEN_MINUTES);

    // Also update at the start of each new 10-minute interval
    const now = new Date();
    const msUntilNextTenMinutes = (10 - (now.getMinutes() % 10)) * 60 * 1000 - now.getSeconds() * 1000 - now.getMilliseconds();
    setTimeout(() => {
      updateState();
      updateInterval = setInterval(updateState, TEN_MINUTES);
    }, msUntilNextTenMinutes);
  }

  // Update application state
  function updateState() {
    currentTime = new Date();
    calculateDayProgress();
  }

  // Lifecycle hooks
  onMount(() => {
    calculateDayTimes();
    startUpdateCycle();
  });

  onDestroy(() => {
    clearInterval(updateInterval);
  });
</script>

<svelte:window bind:innerWidth={windowWidth} bind:innerHeight={windowHeight} />

<div
  style="background-color: {getSkyColor(dayProgress)};"
  class="app-container"
>
  <div class="sky"></div>

  {#if dayProgress < 0.2 || dayProgress > 0.8}
    <Stars opacity={dayProgress < 0 || dayProgress > 1 ? 1 :
                     dayProgress < 0.1 ? 1 - dayProgress/0.1 :
                     dayProgress > 0.9 ? (dayProgress-0.9)/0.1 : 0} />
  {/if}

  {#if dayProgress >= 0 && dayProgress <= 1}
    <Sun
      progress={dayProgress}
      width={windowWidth}
      height={windowHeight}
    />
  {/if}

  {#if dayProgress < 0 || dayProgress > 1}
    <Moon
      progress={(dayProgress + 0.5) % 1}
      width={windowWidth}
      height={windowHeight}
    />
  {/if}

  <div class="ground" style="background: {getGroundColor(dayProgress)};"></div>

  <div class="controls">
    <LocationSelector
      locations={locations}
      selected={selectedLocation}
      onSelect={setLocation}
    />
  </div>

  <InfoPanel
    time={currentTime}
    location={selectedLocation}
    progress={dayProgress}
    phase={dayPhase}
  />
</div>

<style>
  :global(html), :global(body) {
    margin: 0;
    padding: 0;
    height: 100%;
    width: 100%;
    overflow: hidden;
  }

  :global(body) {
    background-color: black;
  }

  .app-container {
    position: relative;
    width: 100%;
    height: 100vh;
    overflow: hidden;
    transition: background-color 2s ease;
    margin: 0;
    padding: 0;
  }

  .sky {
    width: 100%;
    height: 100%;
    position: absolute;
    transition: background-color 2s ease;
  }

  .ground {
    position: absolute;
    bottom: 0;
    width: 100%;
    height: 20%;
    border-top-left-radius: 50% 20px;
    border-top-right-radius: 50% 20px;
    transition: background 2s ease;
  }

  .controls {
    position: absolute;
    top: 20px;
    left: 20px;
    z-index: 100;
  }
</style>
