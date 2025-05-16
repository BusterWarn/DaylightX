<script>
  import { onMount, onDestroy } from 'svelte';
  import { getLocations } from './lib/locations';
  import SkyView from './components/SkyView.svelte';

  const DEFAULT_TOP_LOCATION = "Umea, Sweden";
  const DEFAULT_BOT_LOCATION = "Stockholm, Sweden";

  // Initial state for two views
  let topLocation = DEFAULT_TOP_LOCATION;
  let bottomLocation = DEFAULT_BOT_LOCATION;
  let locations = [];
  let currentTime = new Date();
  let updateInterval;
  let windowWidth = 0;
  let windowHeight = 0;

  // Set up location for specific view
  function setTopLocation(location) {
    topLocation = location;
  }

  function setBottomLocation(location) {
    console.log('set bottom location', location);
    bottomLocation = location;
  }

  // Update application state
  function updateState() {
    currentTime = new Date();
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

  // Lifecycle hooks
  onMount(async () => {
    startUpdateCycle();
    locations = await getLocations();
  });

  onDestroy(() => {
    clearInterval(updateInterval);
  });
</script>

<svelte:window bind:innerWidth={windowWidth} bind:innerHeight={windowHeight} />

<div class="dual-view-container">
  <!-- Top view -->
  <div class="view-container top-view">
    <SkyView
      location={topLocation}
      locations={locations}
      onLocationChange={setTopLocation}
      width={windowWidth}
      height={windowHeight / 2}
    />
  </div>

  <!-- Divider -->
  <div class="divider"></div>

  <!-- Bottom view -->
  <div class="view-container bottom-view">
    <SkyView
      location={bottomLocation}
      locations={locations}
      onLocationChange={setBottomLocation}
      width={windowWidth}
      height={windowHeight / 2}
    />
  </div>
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

  .dual-view-container {
    display: flex;
    flex-direction: column;
    width: 100%;
    height: 100vh;
    overflow: hidden;
  }

  .view-container {
    position: relative;
    width: 100%;
    height: 50%;
    overflow: hidden;
  }

  .divider {
    height: 4px;
    background: rgba(255, 255, 255, 0.3);
    box-shadow: 0 0 10px rgba(255, 255, 255, 0.5);
    z-index: 100;
  }
</style>
