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
  let dayProgress = 0;
  let dayPhase = '';

  /**
  * Creates a date with a specified hour and minute offset from local time
  * @param {Object} options - Options for time offset
  * @param {number} [options.hourOffset=0] - Hours to offset (positive or negative)
  * @param {number} [options.minuteOffset=0] - Minutes to offset (positive or negative)
  * @returns {Date} - New date object with the specified offset applied
  */
  function getTimeWithOffset({ hourOffset = 0, minuteOffset = 0 } = {}) {
    // Get current date
    const date = new Date();

    // Get current local hour and minute
    const localHours = date.getHours();
    const localMinutes = date.getMinutes();

    // Calculate new hour and minute with offset
    const newHours = (localHours + hourOffset + Math.floor((localMinutes + minuteOffset) / 60)) % 24;
    const newMinutes = (localMinutes + minuteOffset) % 60;

    // Handle negative minutes
    const adjustedHours = newHours + (newMinutes < 0 ? -1 : 0);
    const adjustedMinutes = newMinutes < 0 ? newMinutes + 60 : newMinutes;

    // Create a new date object
    const newDate = new Date(date);

    // Set the new hours and minutes
    newDate.setHours(adjustedHours < 0 ? adjustedHours + 24 : adjustedHours);
    newDate.setMinutes(adjustedMinutes);

    return newDate;
  }

  /**
  * Creates a date for the current day with specified hours and minutes from midnight,
  * with optional hour and minute offsets
  * @param {Object} options - Options for time specification
  * @param {number} [options.hours=0] - Base hours from midnight (0-23)
  * @param {number} [options.minutes=0] - Base minutes from midnight (0-59)
  * @param {number} [options.hourOffset=0] - Additional hours to offset (positive or negative)
  * @param {number} [options.minuteOffset=0] - Additional minutes to offset (positive or negative)
  * @returns {Date} - New date object set to the specified time on the current day
  */
  function getTimeOfDay({ hours = 0, minutes = 0, hourOffset = 0, minuteOffset = 0 } = {}) {
    // Create a new date for today
    const date = new Date();

    // Reset to midnight
    date.setHours(0, 0, 0, 0);

    // Calculate total minutes, including offsets
    const totalHours = hours + hourOffset;
    const totalMinutes = minutes + minuteOffset;

    // Calculate final hours and minutes, handling potential negative values
    let finalHours = totalHours + Math.floor(totalMinutes / 60);
    let finalMinutes = totalMinutes % 60;

    // Handle negative minutes
    if (finalMinutes < 0) {
      finalMinutes += 60;
      finalHours -= 1;
    }

    // Handle hour wrapping (keeping within same day)
    while (finalHours < 0) finalHours += 24;
    finalHours = finalHours % 24;

    // Set the time
    date.setHours(finalHours, finalMinutes);

    return date;
  }

  // Calculate sunrise and sunset times
  // For a real app, we would calculate the actual sunrise/sunset times
  // based on date and geographical coordinates. For now, we'll use simplified times.
  function calculateDayTimes(offset = 0) {
    return {
      sunriseTime: getTimeOfDay({ hours: 6, minutes: 0, hourOffset: offset }),
      sunsetTime: getTimeOfDay({ hours: 18, minutes: 0, hourOffset: offset })
    };
  }

  /**
  * Maps a time value from one range to another
  * @param {Date} time - The time to map
  * @param {Date} startTime - Start of the input range
  * @param {Date} endTime - End of the input range
  * @param {number} outMin - Start of the output range
  * @param {number} outMax - End of the output range
  * @returns {number} - Mapped value
  */
  function mapTimeRange(time, startTime, endTime, outMin, outMax) {
    const timeValue = time.getTime();
    const startValue = startTime.getTime();
    const endValue = endTime.getTime();

    // Calculate percentage within range
    const percentage = (timeValue - startValue) / (endValue - startValue);

    // Map to output range
    return outMin + percentage * (outMax - outMin);
  }

  /**
  * Determines the day phase based on day progress value
  * @param {number} progress - Day progress value (-0.25 to 1.25)
  * @returns {string} - Human-readable day phase
  */
  function getDayPhase(progress) {
    if (progress < 0) return "Night (pre-dawn)";
    if (progress < 0.1) return "Sunrise";
    if (progress < 0.4) return "Morning";
    if (progress < 0.6) return "Midday";
    if (progress < 0.9) return "Afternoon";
    if (progress < 1) return "Sunset";
    return "Night";
  }

  /**
  * Calculate sun position and day phase based on current time
  * @param {Object} location - Location information with timezone offset
  * @param {Date} sunriseTime - Today's sunrise time
  * @param {Date} sunsetTime - Today's sunset time
  * @returns {number} dayProgress (0-1.25)
  */
  function calculateDayProgress(location, sunriseTime, sunsetTime) {
    // Get current time adjusted for location's timezone
    const now = getTimeWithOffset({ hourOffset: location.offset });

    // Get midnight and next midnight for calculations
    const midnight = getTimeOfDay({});
    const nextMidnight = getTimeOfDay({ hours: 24 });

    // Calculate progress based on time of day
    if (now < sunriseTime) {
      // Before sunrise (night): -0.25 to 0
      return mapTimeRange(now, midnight, sunriseTime, -0.25, 0);
    } else if (now > sunsetTime) {
      // After sunset (night): 1 to 1.25
      return mapTimeRange(now, sunsetTime, nextMidnight, 1, 1.25);
    } else {
      // During day: 0 to 1
      return mapTimeRange(now, sunriseTime, sunsetTime, 0, 1);
    }
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
    currentTime = getTimeWithOffset({ hourOffset: location.offset });
    const { sunriseTime, sunsetTime } = calculateDayTimes();
    dayProgress = calculateDayProgress(location, sunriseTime, sunsetTime);
    dayPhase = getDayPhase(dayProgress);
  }

  // Initialize on mount
  onMount(() => {
    const { sunriseTime, sunsetTime } = calculateDayTimes();
    dayProgress = calculateDayProgress(location, sunriseTime, sunsetTime);
    dayPhase = getDayPhase(dayProgress);
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
