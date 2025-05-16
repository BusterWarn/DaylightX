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
  export let width = 1000;
  export let height = 500;

  // Initial state
  let isLoading = true;
  let error = null;
  let data = null;
  let dayInfo = null;

  // Function to simulate fetching data that takes 2 seconds
  async function fetchLocationData() {
    try {
      // Reset states at the beginning of fetch
      isLoading = true;
      error = null;

      const response = await fetch('/api/janus', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ location: location })
      });

      // Set the data
      data = await response.json();
    } catch (e) {
      // Handle any errors
      error = e.message;
    } finally {
      // Always set loading to false when done
      isLoading = false;
    }
  }

  /**
  * Get a Date object with a specified UTC offset
  * @param {number|string|undefined} offset - Hours offset from UTC (e.g., 2, "+2.0", "-3.5")
  * @returns {Date} - Date object adjusted to the specified offset
  */
  function getDateWithOffset(offset = 0) {
    // Handle string offset format (e.g., "+2.0", "-3.5")
    if (typeof offset === 'string') {
      offset = parseFloat(offset);
    }

    // Get current UTC time
    const now = new Date();
    const utcTimestamp = now.getTime();

    // Convert offset from hours to milliseconds and apply
    const offsetMs = offset * 60 * 60 * 1000;
    const adjustedTimestamp = utcTimestamp + offsetMs;

    return new Date(adjustedTimestamp);
  }

  /**
  * Enum for day phases
  */
  const DayPhase = {
    PRE_DAWN: "Night (pre-dawn)",
    SUNRISE: "Sunrise",
    MORNING: "Morning",
    MIDDAY: "Midday",
    AFTERNOON: "Afternoon",
    SUNSET: "Sunset",
    NIGHT: "Night"
  };

  function getCurrentDayInfo(sunData, time) {
    // Extract sun times from the data
    const sunrise = new Date(sunData.properties.sunrise.time);
    const sunset = new Date(sunData.properties.sunset.time);
    const solarNoon = new Date(sunData.properties.solarnoon.time);
    const solarMidnight = new Date(sunData.properties.solarmidnight.time);

    // Determine which phase we're in by comparing times
    let phase, progressInPhase;

    // Calculate next solar midnight (for night calculations)
    let nextSolarMidnight = new Date(solarMidnight);
    if (nextSolarMidnight < sunrise) {
      nextSolarMidnight.setDate(nextSolarMidnight.getDate() + 1);
    }

    // Calculate previous solar midnight (for pre-dawn calculations)
    let prevSolarMidnight = new Date(solarMidnight);
    if (prevSolarMidnight > sunrise) {
      prevSolarMidnight.setDate(prevSolarMidnight.getDate() - 1);
    }

    // Calculate sunrise transition (10% of the time from sunrise to noon)
    const sunriseDuration = (solarNoon.getTime() - sunrise.getTime()) * 0.1;
    const sunriseEnd = new Date(sunrise.getTime() + sunriseDuration);

    // Calculate sunset transition (10% of the time from noon to sunset)
    const sunsetDuration = (sunset.getTime() - solarNoon.getTime()) * 0.1;
    const sunsetStart = new Date(sunset.getTime() - sunsetDuration);

    // Define morning and afternoon boundaries
    const morningEnd = new Date(solarNoon.getTime() - (solarNoon.getTime() - sunrise.getTime()) * 0.2); // 80% from sunrise to noon
    const afternoonStart = new Date(solarNoon.getTime() + (sunset.getTime() - solarNoon.getTime()) * 0.2); // 20% from noon to sunset

    // Determine the current phase and calculate progress within that phase
    if (time >= prevSolarMidnight && time < sunrise) {
      // Pre-dawn (from previous solar midnight to sunrise)
      phase = DayPhase.PRE_DAWN;
      progressInPhase = (time.getTime() - prevSolarMidnight.getTime()) / (sunrise.getTime() - prevSolarMidnight.getTime());
    } else if (time >= sunrise && time < sunriseEnd) {
      // Sunrise
      phase = DayPhase.SUNRISE;
      progressInPhase = (time.getTime() - sunrise.getTime()) / sunriseDuration;
    } else if (time >= sunriseEnd && time < morningEnd) {
      // Morning
      phase = DayPhase.MORNING;
      progressInPhase = (time.getTime() - sunriseEnd.getTime()) / (morningEnd.getTime() - sunriseEnd.getTime());
    } else if (time >= morningEnd && time < afternoonStart) {
      // Midday
      phase = DayPhase.MIDDAY;
      progressInPhase = (time.getTime() - morningEnd.getTime()) / (afternoonStart.getTime() - morningEnd.getTime());
    } else if (time >= afternoonStart && time < sunsetStart) {
      // Afternoon
      phase = DayPhase.AFTERNOON;
      progressInPhase = (time.getTime() - afternoonStart.getTime()) / (sunsetStart.getTime() - afternoonStart.getTime());
    } else if (time >= sunsetStart && time < sunset) {
      // Sunset
      phase = DayPhase.SUNSET;
      progressInPhase = (time.getTime() - sunsetStart.getTime()) / sunsetDuration;
    } else {
      // Night (from sunset to next solar midnight)
      phase = DayPhase.NIGHT;
      progressInPhase = (time.getTime() - sunset.getTime()) / (nextSolarMidnight.getTime() - sunset.getTime());
    }

    // Calculate overall day progress (-0.25 to 1.25)
    const dayProgress = calculateOverallDayProgress(time, sunrise, sunset, prevSolarMidnight, nextSolarMidnight);

    return {
      phase: phase,
      progressInPhase: Math.min(1, Math.max(0, progressInPhase)), // Ensure progress is between 0 and 1
      dayProgress: dayProgress
    };
  }

  function setDayInfo(sunData, utcOffset) {
    const time = getDateWithOffset(utcOffset);
    const info = getCurrentDayInfo(sunData, time);

    // Calculate percentage for display (0-100%)
    const percentInPhase = Math.round(info.progressInPhase * 100);

    dayInfo = {
      time: time,
      phase: info.phase,
      progressInPhase: info.progressInPhase,
      percentInPhase: percentInPhase,
      dayProgress: info.dayProgress,
      isDay: info.phase !== DayPhase.NIGHT && info.phase !== DayPhase.PRE_DAWN,
      displayText: `${info.phase} (${percentInPhase}%)`
    };
  }

  function calculateOverallDayProgress(time, sunrise, sunset, prevMidnight, nextMidnight) {
    // Total day cycle duration
    const cycleDuration = nextMidnight.getTime() - prevMidnight.getTime();

    // Time since previous solar midnight
    let timeSinceMidnight = time.getTime() - prevMidnight.getTime();

    // Ensure positive value (handles case when time is before prevMidnight)
    if (timeSinceMidnight < 0) {
      const oneDayMs = 24 * 60 * 60 * 1000;
      timeSinceMidnight += oneDayMs;
    }

    // Calculate fraction of full cycle
    const cycleFraction = timeSinceMidnight / cycleDuration;

    // Map 0-1 cycle fraction to -0.25 to 1.25 range
    return -0.25 + (cycleFraction * 1.5);
  }

  $: if (location) {
    fetchLocationData();
  }

  $: if (data) {
    setDayInfo(data.sun_data, data.utc_offset);
  }

  /* ===== Style helper functions ===== */

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

  function getStarsOpacity(dayProgress) {
    if (dayProgress > 0.2 && dayProgress < 0.8)
      return 0;

    if (dayProgress < 0 || dayProgress > 1)
      return 1;

    if (dayProgress < 0.1)
      return 1 - (dayProgress / 0.1);

    // Dayprogress > 0.9
    return (dayProgress - 0.9) / 0.1;
  }

</script>

{#if dayInfo && !isLoading}
  <div
    style="background-color: {getSkyColor(dayInfo.dayProgress)};"
    class="sky-view"
  >
    <div class="sky"></div>

    <Stars opacity={getStarsOpacity(dayInfo.dayProgress)} />

    {#if dayInfo.dayProgress >= 0 && dayInfo.dayProgress <= 1}
      <Sun
        progress={dayInfo.dayProgress}
        width={width}
        height={height}
      />
    {/if}

    {#if dayInfo.dayProgress < 0 || dayInfo.dayProgress > 1}
      <Moon
        progress={(dayInfo.dayProgress + 0.5) % 1}
        width={width}
        height={height}
      />
    {/if}

    <div class="ground" style="background: {getGroundColor(dayInfo.dayProgress)};"></div>

    <div class="controls">
      <LocationSelector
        locations={locations}
        selected={location}
        onSelect={onLocationChange}
      />
    </div>

    <InfoPanel
      time={dayInfo.time}
      progress={dayInfo.dayProgress}
      phase={dayInfo.phase}
    />
  </div>
{/if}

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
