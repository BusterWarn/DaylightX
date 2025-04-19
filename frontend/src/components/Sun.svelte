<script>
  import { fade } from 'svelte/transition';

  export let progress = 0; // 0 = sunrise, 0.5 = noon, 1 = sunset
  export let width = 1000;
  export let height = 800;

  // Sun path configuration
  const sunPathHeight = 0.7; // Maximum height of sun's path (0-1)
  const sunSize = 80; // Sun diameter in pixels

  // Calculate sun position based on progress
  $: angle = Math.PI * progress;
  $: sunX = width * progress - (sunSize / 2);
  $: sunY = height * (1 - Math.sin(angle) * sunPathHeight) - (sunSize / 2);

  // Adjust sun glow based on height (higher = brighter)
  $: glowIntensity = Math.sin(angle) * 0.7 + 0.3;
  $: sunGlow = `0 0 ${30 * glowIntensity}px ${10 * glowIntensity}px rgba(255, 215, 0, ${0.7 * glowIntensity})`;

  // Calculate sun color based on time of day
  $: sunColor = getSunColor(progress);

  function getSunColor(prog) {
    // Cooler colors at sunrise/sunset, warmer at noon
    if (prog < 0.2) {
      // Sunrise: orange-yellow
      return `radial-gradient(circle, #ffff99 10%, #ffcc66 60%, #ff9933 100%)`;
    } else if (prog > 0.8) {
      // Sunset: orange-red
      return `radial-gradient(circle, #ffff80 10%, #ffcc00 60%, #ff6600 100%)`;
    } else {
      // Midday: bright yellow
      return `radial-gradient(circle, #ffffff 10%, #ffff66 60%, #ffcc00 100%)`;
    }
  }
</script>

<div
  class="sun"
  style="transform: translate({sunX}px, {sunY}px);
         background: {sunColor};
         box-shadow: {sunGlow};"
  transition:fade={{ duration: 2000 }}
>
  <div class="sun-rays"></div>
  <div class="sun-core"></div>
</div>

<style>
  .sun {
    position: absolute;
    width: 80px;
    height: 80px;
    border-radius: 50%;
    transition: transform 2s ease, box-shadow 2s ease, background 2s ease;
    z-index: 10;
    filter: brightness(1.2);
  }

  .sun-core {
    position: absolute;
    width: 70%;
    height: 70%;
    top: 15%;
    left: 15%;
    border-radius: 50%;
    background: radial-gradient(circle, rgba(255, 255, 255, 0.8) 0%, rgba(255, 255, 200, 0) 70%);
    mix-blend-mode: screen;
  }

  .sun-rays {
    position: absolute;
    width: 180%;
    height: 180%;
    top: -40%;
    left: -40%;
    border-radius: 50%;
    background: radial-gradient(circle, rgba(255, 255, 230, 0.8) 0%, rgba(255, 170, 0, 0.3) 40%, rgba(255, 170, 0, 0) 70%);
    animation: rotate 60s linear infinite;
  }

  .sun-rays::before {
    content: '';
    position: absolute;
    top: 0;
    bottom: 0;
    left: 0;
    right: 0;
    background: radial-gradient(circle, rgba(255, 255, 255, 0) 35%, rgba(255, 200, 100, 0.3) 40%, rgba(255, 160, 0, 0) 60%);
    border-radius: 50%;
    transform: rotate(45deg);
  }

  .sun::after {
    content: '';
    position: absolute;
    top: -30px;
    bottom: -30px;
    left: -30px;
    right: -30px;
    background: radial-gradient(circle, rgba(255, 255, 180, 0.5) 0%, rgba(255, 210, 0, 0.2) 50%, rgba(255, 210, 0, 0) 70%);
    border-radius: 50%;
    filter: blur(5px);
  }

  @keyframes rotate {
    from { transform: rotate(0deg); }
    to { transform: rotate(360deg); }
  }
</style>
