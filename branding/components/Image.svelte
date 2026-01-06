<script lang="ts">
  import { onMount } from 'svelte';

  export let src: string;
  export let alt: string;
  export let className: string = '';
  export let imgClass: string = '';
  export let eager: boolean = false;
  export let priority: 'auto' | 'high' | 'low' = 'auto';
  export let transition: boolean = true;
  export let sizes: string = '100vw'; // Default sizes for responsive images
  export let srcset: string = ''; // Optional srcset for responsive images
  export let width: number | string | undefined = undefined; // Image width for layout shift prevention
  export let height: number | string | undefined = undefined; // Image height for layout shift prevention
  
  // Start with loaded=false if we want skeletons, but for debugging/fixing let's trust the browser
  let loaded = false;
  let imgElement: HTMLImageElement;
  
  function handleLoad() {
    loaded = true;
  }

  function handleError(e: Event) {
    console.error('Image load failed:', src, e);
    // Maybe set a fallback or error state?
    // For now, force loaded to show *something* (even if broken image icon)
    loaded = true;
  }

  // Force check on mount and update
  $: if (imgElement && imgElement.complete) {
    if (imgElement.naturalWidth > 0) {
        loaded = true;
    }
  }
</script>

<div class={`relative overflow-hidden ${className}`}>
  <!-- Skeleton -->
  {#if transition}
    <div class={`absolute inset-0 bg-visir-surface/10 animate-pulse z-0 transition-opacity duration-300 ${loaded ? 'opacity-0' : 'opacity-100'}`}></div>
  {/if}
  
  <img
    bind:this={imgElement}
    {src}
    {alt}
    srcset={srcset || undefined}
    {sizes}
    width={width}
    height={height}
    class={`${transition ? `transition-opacity duration-500 ${loaded ? 'opacity-100' : 'opacity-0'}` : ''} ${imgClass} relative z-10`}
    style="image-rendering: -webkit-optimize-contrast; image-rendering: crisp-edges; image-rendering: high-quality;"
    loading={eager ? 'eager' : 'lazy'}
    decoding="async"
    fetchpriority={priority}
    on:load={handleLoad}
    on:error={handleError}
  />
</div>
