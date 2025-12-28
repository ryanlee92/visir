<script lang="ts">
  import { onMount } from 'svelte';

  export let src: string;
  export let alt: string;
  export let className: string = '';
  export let imgClass: string = '';
  export let eager: boolean = false;
  export let priority: 'auto' | 'high' | 'low' = 'auto';
  export let transition: boolean = true;
  export let sizes: string = '100vw';
  
  let loaded = false;
  let imgElement: HTMLImageElement;
  
  // Generate AVIF and WebP paths
  $: avifSrc = src.replace(/\.(webp|png|jpg|jpeg)$/i, '.avif');
  $: webpSrc = src.replace(/\.(png|jpg|jpeg)$/i, '.webp');
  $: originalExt = src.match(/\.(webp|png|jpg|jpeg|avif)$/i)?.[0] || '';
  $: hasAvif = originalExt !== '.avif';
  $: hasWebp = !['.webp', '.avif'].includes(originalExt);

  function handleLoad() {
    loaded = true;
  }

  function handleError(e: Event) {
    console.error('Image load failed:', src, e);
    loaded = true;
  }

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
  
  <picture>
    {#if hasAvif}
      <source srcset={avifSrc} type="image/avif" {sizes} />
    {/if}
    {#if hasWebp}
      <source srcset={webpSrc} type="image/webp" {sizes} />
    {/if}
    <img
      bind:this={imgElement}
      {src}
      {alt}
      {sizes}
      class={`${transition ? `transition-opacity duration-500 ${loaded ? 'opacity-100' : 'opacity-0'}` : ''} ${imgClass} relative z-10`}
      style="image-rendering: -webkit-optimize-contrast; image-rendering: crisp-edges; image-rendering: high-quality;"
      loading={eager ? 'eager' : 'lazy'}
      decoding="async"
      fetchpriority={priority}
      on:load={handleLoad}
      on:error={handleError}
    />
  </picture>
</div>

