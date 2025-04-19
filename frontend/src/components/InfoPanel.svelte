<script>
  export let time = new Date();
  export let location = { name: "Local" };
  export let progress = 0;
  export let phase = "";

  // Format time according to locale
  function formatTime(date) {
    return date.toLocaleTimeString(undefined, {
      hour: '2-digit',
      minute: '2-digit',
      hour12: true
    });
  }

  // Format progress as percentage
  function formatProgress(prog) {
    // Adjust range to 0-100 for day time
    if (prog < 0) {
      // Pre-dawn: 0-25%
      return Math.round((prog + 0.25) / 0.25 * 25);
    } else if (prog > 1) {
      // Night: 75-100%
      return Math.round(75 + (prog - 1) / 0.25 * 25);
    } else {
      // Day: 25-75%
      return Math.round(25 + prog * 50);
    }
  }
</script>

<div class="info-panel">
  <div class="info-content">
    <div class="info-row">
      <span class="info-label">Time:</span>
      <span class="info-value">{formatTime(time)}</span>
    </div>
    <div class="info-row">
      <span class="info-label">Day Progress:</span>
      <span class="info-value">{formatProgress(progress)}%</span>
    </div>
    <div class="info-row">
      <span class="info-label">Phase:</span>
      <span class="info-value">{phase}</span>
    </div>
  </div>
</div>

<style>
  .info-panel {
    position: absolute;
    top: 20px;
    right: 20px;
    background-color: rgba(0, 0, 0, 0.5);
    color: white;
    padding: 10px;
    border-radius: 8px;
    font-family: 'Helvetica Neue', Arial, sans-serif;
    backdrop-filter: blur(5px);
    border: 1px solid rgba(255, 255, 255, 0.2);
    min-width: 180px;
    z-index: 100;
  }

  .info-content {
    display: flex;
    flex-direction: column;
    gap: 4px;
  }

  .info-row {
    display: flex;
    justify-content: space-between;
    font-size: 14px;
  }

  .info-label {
    font-weight: 500;
    opacity: 0.9;
  }

  .info-value {
    font-weight: 400;
  }
</style>
