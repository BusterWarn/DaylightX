<script>
  import { onMount } from 'svelte';
  import Sun from './Sun.svelte';
  import Moon from './Moon.svelte';
  import Stars from './Stars.svelte';
  import LocationSelector from './LocationSelector.svelte';
  import InfoPanel from './InfoPanel.svelte';

  // Props
  export let location;
  export let locations = [];
  export let onLocationChange;
  export let currentTime = new Date();
  export let width = 1000;
  export let height = 500;

  // Initial state
  let sunriseTime, sunsetTime, solarNoon;
  let dayProgress = 0;
  let dayPhase = '';

  // Calculate sunrise and sunset times
  function calculateDayTimes() {
    // For a real app, we would calculate the actual sunrise/sunset times
    // based on date and geographical coordinates. For now, we'll use simplified times.
    const today = new Date();

    // Create a date object for today at midnight in local time
    const localMidnight = new Date(today);
    localMidnight.setHours(0, 0, 0, 0);

    // Create a new date object for midnight in the selected timezone
    const timezoneMidnight = new Date(localMidnight);

    // Adjust for timezone if not using local time
    if (location.name !== "Local") {
      const localOffset = -timezoneMidnight.getTimezoneOffset() / 60;
      const hourDifference = location.offset - localOffset;
      timezoneMidnight.setHours(timezoneMidnight.getHours() + hourDifference);
    }

    // Set sunrise, solar noon, and sunset times
    sunriseTime = new Date(timezoneMidnight);
    sunriseTime.setHours(6, 0, 0, 0);

    solarNoon = new Date(timezoneMidnight);
    solarNoon.setHours(12, 0, 0, 0);

    sunsetTime = new Date(timezoneMidnight);
    sunsetTime.setHours(18, 0, 0, 0);
  }

  // Calculate sun position based on current time
  function calculateDayProgress() {
    let now = new Date();

    // Adjust time for selected timezone if not local
    if (location.name !== "Local") {
      const localOffset = -now.getTimezoneOffset() / 60;
      const hourDifference = location.offset - localOffset;
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
      const msTotal = sunsetTime - sunriseTime;
      const msCurrent = now - sunriseTime;
      dayProgress = msCurrent / msTotal;
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

  // Update view when location or time changes
  $: if (location || currentTime) {
    calculateDayTimes();
    calculateDayProgress();
  }

  // Initialize on mount
  onMount(() => {
    calculateDayTimes();
    calculateDayProgress();
  });
</script>

<div
  style="background-color: {getSkyColor(dayProgress)};"
  class="sky-view"
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
      width={width}
      height={height}
    />
  {/if}

  {#if dayProgress < 0 || dayProgress > 1}
    <Moon
      progress={(dayProgress + 0.5) % 1}
      width={width}
      height={height}
    />
  {/if}

  <div class="ground" style="background: {getGroundColor(dayProgress)};"></div>

  <div class="controls">
    <LocationSelector
      locations={locations}
      selected={location}
      onSelect={onLocationChange}
    />
  </div>

  <InfoPanel
    time={currentTime}
    location={location}
    progress={dayProgress}
    phase={dayPhase}
  />
</div>

<style>
  .sky-view {
    position: relative;
    width: 100%;
    height: 100%;
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
