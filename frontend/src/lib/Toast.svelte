<script>
  import { createEventDispatcher, onMount } from 'svelte';

  export let message = '';
  export let type = 'info'; // 'info', 'success', 'warning', 'error'
  export let duration = 3000; // Time in ms before toast disappears
  export let position = 'top-end'; // 'top-end', 'top-center', 'top-start', 'bottom-end', 'bottom-center', 'bottom-start'

  const dispatch = createEventDispatcher();
  
  let visible = false;
  
  onMount(() => {
    visible = true;
    
    if (duration > 0) {
      const timer = setTimeout(() => {
        visible = false;
        dispatch('close');
      }, duration);
      
      return () => clearTimeout(timer);
    }
  });
  
  function close() {
    visible = false;
    dispatch('close');
  }
  
  // Map type to DaisyUI alert classes
  $: alertClass = {
    'info': 'alert-info',
    'success': 'alert-success',
    'warning': 'alert-warning',
    'error': 'alert-error'
  }[type] || 'alert-info';
</script>

{#if visible}
  <div class="toast toast-{position} z-50">
    <div class="alert {alertClass}">
      <span>{message}</span>
      <button class="btn btn-sm btn-ghost" on:click={close}>×</button>
    </div>
  </div>
{/if} 