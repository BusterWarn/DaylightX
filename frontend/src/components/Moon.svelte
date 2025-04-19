<script>
  import { fade } from 'svelte/transition';

  export let progress = 0; // 0 = moonrise, 0.5 = moon apex, 1 = moonset
  export let width = 1000;
  export let height = 800;

  // Moon path configuration
  const moonPathHeight = 0.6; // Maximum height of moon's path (0-1)
  const moonSize = 60; // Moon diameter in pixels

  // Calculate moon position based on progress
  $: angle = Math.PI * progress;
  $: moonX = width * progress - (moonSize / 2);
  $: moonY = height * (1 - Math.sin(angle) * moonPathHeight) - (moonSize / 2);

  // Calculate moon phase (simplified)
  // In a real application, we would calculate the actual moon phase based on date
  $: moonPhase = 0.5; // 0 = new moon, 0.5 = full moon, 1 = new moon again
</script>

<div
  class="moon"
  style="transform: translate({moonX}px, {moonY}px);"
  transition:fade={{ duration: 2000 }}
>
  <div class="moon-glow"></div>
  <div class="moon-surface"></div>
  <div class="moon-shadow" style="left: {(moonPhase > 0.5 ? (moonPhase - 0.5) * 200 : (0.5 - moonPhase) * -200)}%;"></div>
</div>

<style>
  .moon {
    position: absolute;
    width: 60px;
    height: 60px;
    border-radius: 50%;
    background-color: #f4f4ff;
    box-shadow: 0 0 20px 5px rgba(255, 255, 255, 0.3);
    transition: transform 2s ease;
    overflow: hidden;
    z-index: 10;
  }

  .moon-glow {
    position: absolute;
    width: 100%;
    height: 100%;
    border-radius: 50%;
    background: radial-gradient(circle, rgba(255, 255, 255, 0.9) 30%, rgba(220, 220, 255, 0.7) 70%, rgba(200, 200, 255, 0.5) 90%);
    filter: blur(1px);
  }

  .moon-surface {
    position: absolute;
    width: 100%;
    height: 100%;
    opacity: 0.6;
    background:
      radial-gradient(circle at 20% 30%, rgba(180, 180, 180, 0.3) 0%, rgba(180, 180, 180, 0) 7%),
      radial-gradient(circle at 70% 20%, rgba(180, 180, 180, 0.4) 0%, rgba(180, 180, 180, 0) 6%),
      radial-gradient(circle at 40% 80%, rgba(160, 160, 160, 0.5) 0%, rgba(160, 160, 160, 0) 8%),
      radial-gradient(circle at 60% 40%, rgba(160, 160, 160, 0.3) 0%, rgba(160, 160, 160, 0) 5%),
      radial-gradient(circle at 80% 50%, rgba(160, 160, 160, 0.4) 0%, rgba(160, 160, 160, 0) 6%),
      radial-gradient(circle at 10% 60%, rgba(140, 140, 140, 0.5) 0%, rgba(140, 140, 140, 0) 7%),
      radial-gradient(circle at 30% 10%, rgba(140, 140, 140, 0.3) 0%, rgba(140, 140, 140, 0) 6%),
      radial-gradient(circle at 50% 90%, rgba(120, 120, 120, 0.4) 0%, rgba(120, 120, 120, 0) 8%);
  }

  .moon-shadow {
    position: absolute;
    top: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 20, 0.8);
    border-radius: 50%;
    transition: left 20s ease;
    box-shadow: inset -5px 0 10px rgba(0, 0, 0, 0.5);
  }
</style>
