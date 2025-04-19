<script>
  import { onMount } from 'svelte';

  export let opacity = 1;

  let starsContainer;
  const STAR_COUNT = 200;

  // Generate random stars on mount
  onMount(() => {
    for (let i = 0; i < STAR_COUNT; i++) {
      const star = document.createElement('div');
      star.className = 'star';

      // Random size (smaller stars are more common)
      const size = Math.random() * Math.random() * 2.5 + 0.5;
      star.style.width = `${size}px`;
      star.style.height = `${size}px`;

      // Random position
      star.style.left = `${Math.random() * 100}%`;
      star.style.top = `${Math.random() * 70}%`;

      // Random opacity and twinkle animation
      star.style.opacity = Math.random() * 0.7 + 0.3;
      star.style.animationDelay = `${Math.random() * 10}s`;
      star.style.animationDuration = `${3 + Math.random() * 7}s`;

      starsContainer.appendChild(star);
    }
  });
</script>

<div
  class="stars"
  bind:this={starsContainer}
  style="opacity: {opacity};"
></div>

<style>
  .stars {
    position: absolute;
    width: 100%;
    height: 100%;
    transition: opacity 2s ease;
    z-index: 5;
  }

  :global(.star) {
    position: absolute;
    background-color: white;
    border-radius: 50%;
    animation: twinkle ease-in-out infinite;
  }

  @keyframes twinkle {
    0% { opacity: var(--opacity, 0.5); }
    50% { opacity: 1; }
    100% { opacity: var(--opacity, 0.5); }
  }
</style>
