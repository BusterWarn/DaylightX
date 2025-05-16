<script>
  export let locations = [];
  export let selected = null;
  export let onSelect = () => {};

  // Handle location change
  function handleSelect(event) {
    const selectedLocation = locations.find(loc => loc === event.target.value);
    onSelect(selectedLocation);
  }
</script>

<div class="location-selector">
  <select id="location" value={selected} on:change={handleSelect}>
    {#each locations as location}
      <option value={location}>{location}</option>
    {/each}
  </select>
</div>

<style>
  .location-selector {
    background-color: rgba(0, 0, 0, 0.5);
    padding: 8px 12px;
    border-radius: 8px;
    display: flex;
    align-items: center;
    color: white;
    font-size: 14px;
    backdrop-filter: blur(5px);
    border: 1px solid rgba(255, 255, 255, 0.2);
  }

  select {
    background-color: rgba(255, 255, 255, 0.2);
    border: 1px solid rgba(255, 255, 255, 0.4);
    color: white;
    padding: 4px 8px;
    border-radius: 4px;
    outline: none;
    cursor: pointer;
    font-size: 14px;
    width: 120px;
  }

  select:hover {
    background-color: rgba(255, 255, 255, 0.3);
  }

  option {
    background-color: #222;
    color: white;
  }
</style>
