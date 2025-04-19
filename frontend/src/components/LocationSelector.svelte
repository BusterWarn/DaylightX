<script>
  export let locations = [];
  export let selected = null;
  export let onSelect = () => {};

  // Handle location change
  function handleSelect(event) {
    const selectedLocation = locations.find(loc => loc.name === event.target.value);
    onSelect(selectedLocation);
  }
</script>

<div class="location-selector">
  <label for="location">Location:</label>
  <select id="location" value={selected.name} on:change={handleSelect}>
    {#each locations as location}
      <option value={location.name}>{location.name}</option>
    {/each}
  </select>
</div>

<style>
  .location-selector {
    background-color: rgba(0, 0, 0, 0.5);
    padding: 10px 15px;
    border-radius: 8px;
    display: flex;
    align-items: center;
    gap: 10px;
    color: white;
    font-size: 14px;
    backdrop-filter: blur(5px);
  }

  label {
    font-weight: 500;
  }

  select {
    background-color: rgba(255, 255, 255, 0.2);
    border: 1px solid rgba(255, 255, 255, 0.4);
    color: white;
    padding: 5px 10px;
    border-radius: 4px;
    outline: none;
    cursor: pointer;
    font-size: 14px;
  }

  select:hover {
    background-color: rgba(255, 255, 255, 0.3);
  }

  option {
    background-color: #222;
    color: white;
  }
</style>
