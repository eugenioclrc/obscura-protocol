<script lang="ts">
  import Toast from './Toast.svelte';
  import toasts, { removeToast } from './toastStore';
  
  interface ToastGroup {
    [position: string]: Array<{
      id: string;
      message: string;
      type: string;
      duration: number;
      position: string;
    }>;
  }
  
  // Group toasts by position
  $: groupedToasts = $toasts.reduce<ToastGroup>((acc, toast) => {
    if (!acc[toast.position]) {
      acc[toast.position] = [];
    }
    acc[toast.position].push(toast);
    return acc;
  }, {});
  
  // Handle toast close
  function handleClose(id: string): void {
    removeToast(id);
  }
</script>

{#each Object.entries(groupedToasts) as [position, positionToasts]}
  {#each positionToasts as toast (toast.id)}
    <Toast 
      message={toast.message} 
      type={toast.type} 
      duration={toast.duration} 
      position={position}
      on:close={() => handleClose(toast.id)} 
    />
  {/each}
{/each} 