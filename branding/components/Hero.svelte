<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { link } from '../lib/router';
  import Icon from './Icon.svelte';
  // Iconsax icons will be used via Icon component
  import Button from './Button.svelte';
  import appDemoDark from '../assets/app-demo-dark-optimized.webm';
  import appDemoLight from '../assets/app-demo-light-optimized.webm';
  import { createScrollAnimation } from '../lib/animations';

  let videoError = false;
  let isDark = true;
  let videoLoaded = false;
  let shouldLoadVideo = false;

  $: videoPath = isDark ? appDemoDark : appDemoLight;

  function checkTheme() {
    isDark = document.documentElement.classList.contains('dark');
  }

  let heroContent: HTMLElement;
  let videoContainer: HTMLElement;

  function handleVideoLoaded() {
    videoLoaded = true;
  }

  function handleVideoError() {
    videoError = true;
  }

  onMount(() => {
    checkTheme();
    const observer = new MutationObserver(checkTheme);
    observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['class']
    });

    // Add fade-in animation for hero content
    if (heroContent) {
      heroContent.classList.add('fade-in-up');
      heroContent.classList.add('visible');
    }

    // Add fade-in animation for video container with delay
    if (videoContainer) {
      setTimeout(() => {
        videoContainer.classList.add('fade-in-up');
        videoContainer.style.transitionDelay = '300ms';
        videoContainer.classList.add('visible');
      }, 100);
    }

    // Intersection Observer for video lazy loading
    if (!videoLoaded) {
      const videoContainerElement = document.querySelector('[data-video-container]');
      if (videoContainerElement) {
        const videoObserver = new IntersectionObserver(
          (entries) => {
            if (entries[0].isIntersecting) {
              shouldLoadVideo = true;
              videoObserver.disconnect();
            }
          },
          { rootMargin: '100px' }
        );
        videoObserver.observe(videoContainerElement);
      }
    } else {
      shouldLoadVideo = true;
    }

    // Initialize UnicornStudio with dynamic script loading
    if (!(window as any).UnicornStudio) {
      const script = document.createElement('script');
      script.src = "https://cdn.jsdelivr.net/gh/hiunicornstudio/unicornstudio.js@v1.5.3/dist/unicornStudio.umd.js";
      script.async = true;
      script.onload = () => {
        if ((window as any).UnicornStudio && typeof (window as any).UnicornStudio.init === 'function') {
           (window as any).UnicornStudio.init();
        }
      };
      document.head.appendChild(script);
    } else {
       // If script is already loaded, just init
       if (typeof (window as any).UnicornStudio.init === 'function') {
         (window as any).UnicornStudio.init();
       }
    }

    return () => {
      observer.disconnect();
    };
  });
</script>

<svelte:head>
</svelte:head>

<div class="relative w-full min-h-screen flex flex-col items-center justify-start overflow-hidden pt-24 lg:pt-32 bg-transparent" data-hero-section>
  <!-- Background Wrapper -->
  <div class="absolute top-0 left-0 right-0 w-full h-[200vh] z-0 opacity-40 pointer-events-none mix-blend-normal" style="mask-image: linear-gradient(to bottom, black 0%, black calc(100vh - 200px), rgba(0, 0, 0, 0.8) calc(100vh - 100px), rgba(0, 0, 0, 0.4) calc(100vh), rgba(0, 0, 0, 0.1) calc(100vh + 100px), transparent calc(100vh + 200px)); -webkit-mask-image: linear-gradient(to bottom, black 0%, black calc(100vh - 200px), rgba(0, 0, 0, 0.8) calc(100vh - 100px), rgba(0, 0, 0, 0.4) calc(100vh), rgba(0, 0, 0, 0.1) calc(100vh + 100px), transparent calc(100vh + 200px))">
    <div 
      data-us-project="jsaDRRNRuRVRmkdU1gwd"
      data-us-lazyload="true"
      data-us-production="true"
      data-us-dpi="1.0"
      data-us-fps="20"
      style="width: 100%; height: 100%"
    ></div>
  </div>

  <!-- Content -->
  <div class="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center flex flex-col items-center" bind:this={heroContent}>
    
    <!-- Glassy Tag -->
    <div class="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-visir-surface/30 border border-visir-outline/20 text-visir-primary text-xs font-medium uppercase tracking-wide mb-8 backdrop-blur-sm shadow-[0_0_15px_rgba(0,0,0,0.1)] hover:bg-visir-surface/50 transition-colors duration-200 cursor-default">
      <Icon name="Zap" size={14} color="var(--visir-primary)" className="text-visir-primary" />
      <span class="font-display tracking-wide text-visir-text">Your Brain, Just Organized by AI</span>
    </div>

    <h1 class="text-4xl sm:text-5xl lg:text-7xl font-medium font-display tracking-tight text-visir-text mb-6 leading-tight drop-shadow-lg">
      Your browser tabs are<br />
      <span class="text-transparent bg-clip-text bg-gradient-to-r from-indigo-400 via-purple-400 to-pink-400 {isDark ? 'drop-shadow-sm' : 'drop-shadow-lg'} {!isDark ? 'brightness-90 contrast-110' : ''}">
        killing your productivity.
      </span>
    </h1>
    
    <p class="max-w-4xl text-lg sm:text-xl text-visir-text-muted mb-10 leading-relaxed font-sans font-light drop-shadow-md">
      One Timeline for Everything. Finally. <br/>
      Email, Slack, and Tasks lived apart. We married them.
    </p>
    
    <div class="flex flex-col sm:flex-row gap-4 w-full sm:w-auto">
      <a href="/download" use:link>
        <Button size="lg" className="w-full sm:w-auto gap-2 group font-display font-medium">
          Get Started Free
          <Icon name="ArrowRight" size={18} className="group-hover:translate-x-1 transition-transform" />
        </Button>
      </a>
      <Button variant="secondary" size="lg" className="w-full sm:w-auto gap-2 font-display font-medium">
        <Icon name="PlayCircle" size={18} /> Watch Demo
      </Button>
    </div>

    <div class="mt-8 flex flex-col sm:flex-row items-center justify-center gap-4 sm:gap-6">
      <div class="flex items-center gap-2 text-base text-visir-text-muted font-light">
        <Icon name="CheckCircle2" size={18} color="#10b981" /> 
        <span class="font-medium">No credit card required</span>
      </div>
      <div class="flex items-center gap-2 text-base text-visir-text-muted font-light">
        <Icon name="CheckCircle2" size={18} color="#10b981" /> 
        <span class="font-medium">14-day free trial</span>
      </div>
      <div class="flex items-center gap-2 text-base text-visir-text-muted font-light">
        <Icon name="Shield" size={18} color="#10b981" /> 
        <span class="font-medium">Local-first, encrypted essentials</span>
      </div>
    </div>
  </div>

  <!-- Mockup Container - Enhanced Glassy Effect - Full Width -->
  <div class="mt-20 mb-16 w-full px-4 sm:px-6 lg:px-8 relative group perspective-1000 fade-in-up" data-video-container bind:this={videoContainer}>
    <div class="max-w-7xl mx-auto relative">
      <!-- Glow effect behind the mockup -->
      <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[90%] h-[90%] bg-visir-primary/20 blur-[100px] rounded-full pointer-events-none"></div>
      
      <!-- The Interface Mockup - Glassy with Video -->
      <div class="relative bg-transparent backdrop-blur-sm border border-white/10 rounded-2xl shadow-2xl overflow-hidden aspect-[16/10] w-full transform transition-transform duration-200 hover:scale-[1.01] hover:rotate-x-1 ring-1 ring-white/5" style="contain: layout style paint;">
        <!-- Placeholder to maintain aspect ratio before video loads -->
        <div class="absolute inset-0 w-full h-full bg-visir-surface/5" aria-hidden="true"></div>
        
        <!-- Video만 표시, mockup 제거 -->
        {#if !videoError && shouldLoadVideo}
          <div class="absolute inset-0 w-full h-full overflow-hidden bg-transparent" style="background-color: transparent">
            <video
              src={videoPath}
              autoplay
              loop
              muted
              playsinline
              preload="metadata"
              poster="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 1920 1080'%3E%3Crect fill='%231C1C1B' width='1920' height='1080'/%3E%3C/svg%3E"
              class="absolute inset-0 w-full h-full object-cover object-center {videoLoaded ? 'opacity-100' : 'opacity-0'} transition-opacity duration-200"
              style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; object-fit: cover; transform: scale(1.065); margin-top: 1%; filter: brightness(1.05) contrast(1.05); background-color: transparent; display: block; border: none; outline: none; box-shadow: none; appearance: none; -webkit-appearance: none"
              on:loadeddata={handleVideoLoaded}
              on:error={handleVideoError}
            ></video>
          </div>
        {/if}
      </div>
    </div>
  </div>
</div>

