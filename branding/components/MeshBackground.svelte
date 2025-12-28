<script lang="ts">
  import { onMount, onDestroy } from 'svelte';

  let isDark = true;
  let noiseLoaded = false;
  let isScrolling = false;
  let isVisible = true;
  let scrollTimeout: ReturnType<typeof setTimeout> | null = null;
  let containerElement: HTMLDivElement;

  function checkTheme() {
    isDark = document.documentElement.classList.contains('dark');
  }

  function handleScroll() {
    if (!isScrolling) {
      isScrolling = true;
      document.documentElement.classList.add('scrolling');
    }
    
    if (scrollTimeout) {
      clearTimeout(scrollTimeout);
    }
    
    scrollTimeout = setTimeout(() => {
      isScrolling = false;
      document.documentElement.classList.remove('scrolling');
    }, 150);
  }

  onMount(() => {
    checkTheme();
    const observer = new MutationObserver(checkTheme);
    observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['class']
    });
    
    // Lazy load noise texture after initial render
    setTimeout(() => {
      noiseLoaded = true;
    }, 2000);
    
    // Intersection Observer to disable when not visible
    if (containerElement) {
      const visibilityObserver = new IntersectionObserver(
        (entries) => {
          isVisible = entries[0].isIntersecting;
          if (!isVisible) {
            document.documentElement.classList.add('mesh-hidden');
          } else {
            document.documentElement.classList.remove('mesh-hidden');
          }
        },
        { rootMargin: '50%' } // Disable when 50% out of viewport
      );
      visibilityObserver.observe(containerElement);
    }
    
    // Pause animations during scroll
    window.addEventListener('scroll', handleScroll, { passive: true });
    
    return () => {
      observer.disconnect();
      window.removeEventListener('scroll', handleScroll);
      if (scrollTimeout) {
        clearTimeout(scrollTimeout);
      }
    };
  });
</script>

<div bind:this={containerElement} class="fixed inset-0 z-0 overflow-hidden pointer-events-none" aria-hidden="true">
  <!-- Base Background Color -->
  <div class="absolute inset-0 transition-colors duration-300" style="background-color: var(--visir-background)"></div>
  
  <!-- Animated Mesh Blobs - Optimized for performance -->
  <div class="absolute inset-0 mesh-container" style="opacity: {isDark ? 0.08 : 0.15}">
    <!-- Blob 1: Primary (Purple) - Top Left (reduced size) -->
    <div 
      class="absolute top-[-15%] left-[-5%] w-[60vw] h-[60vw] rounded-full animate-blob-slow blob-1"
      style="background-color: rgba(124, 93, 255, 0.35)"
    ></div>
    
    <!-- Blob 2: Secondary (Blue) - Bottom Right (reduced size) -->
    <div 
      class="absolute bottom-[-15%] right-[-5%] w-[60vw] h-[60vw] rounded-full animate-blob-slower animation-delay-3000 blob-2"
      style="background-color: rgba(93, 133, 255, 0.35)"
    ></div>
  </div>
  
  <!-- Noise Overlay for texture - lazy loaded and reduced -->
  {#if noiseLoaded && isVisible}
    <div 
      class="absolute inset-0 noise-overlay"
      style="background-image: url(https://grainy-gradients.vercel.app/noise.svg); opacity: {isDark ? 0.03 : 0.02}"
    ></div>
  {/if}
</div>

<style>
  /* Optimized animations - simplified, no scale for better performance */
  @keyframes blob {
    0% { transform: translate3d(0px, 0px, 0); }
    50% { transform: translate3d(20px, -30px, 0); }
    100% { transform: translate3d(0px, 0px, 0); }
  }
  
  .mesh-container {
    /* Reduced blur significantly for better performance */
    filter: blur(20px);
    transform: translate3d(0, 0, 0);
    /* Create a new layer for better performance */
    isolation: isolate;
    /* Use contain to limit repaints */
    contain: strict;
    /* Reduce motion for users who prefer it */
  }
  
  @media (prefers-reduced-motion: reduce) {
    .mesh-container {
      filter: blur(15px);
    }
    .animate-blob-slow,
    .animate-blob-slower {
      animation: none;
    }
  }
  
  .blob-1,
  .blob-2 {
    /* Force GPU acceleration */
    transform: translate3d(0, 0, 0);
    /* No mix-blend-mode for better performance */
  }
  
  .animate-blob-slow {
    /* Slower animation, less frequent updates */
    animation: blob 30s infinite ease-in-out;
  }
  .animate-blob-slower {
    /* Even slower for subtle movement */
    animation: blob 40s infinite ease-in-out;
  }
  
  /* Pause animations during scroll for better performance */
  .scrolling .animate-blob-slow,
  .scrolling .animate-blob-slower {
    animation-play-state: paused;
  }
  
  /* Completely disable when not visible */
  .mesh-hidden .mesh-container {
    display: none;
  }
  
  .animation-delay-3000 {
    animation-delay: 3s;
  }
  
  .noise-overlay {
    /* Simplified filters */
    transform: translateZ(0);
    /* No complex filters for better performance */
  }
</style>
