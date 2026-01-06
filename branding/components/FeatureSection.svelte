<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import Icon from './Icon.svelte';
  import type { Feature } from '../types';
  import Image from './Image.svelte';
  import { createScrollAnimation } from '../lib/animations';
  import unifiedInboxDark from '../assets/unified-inbox-dark.webp';
  import unifiedInboxLight from '../assets/unified-inbox-light.webp';
  import aiAssistantDark from '../assets/ai-assistant-dark.webp';
  import aiAssistantLight from '../assets/ai-assistant-light.webp';
  import mailDark from '../assets/mail_dark.webp';
  import mailLight from '../assets/mail_light.webp';
  import chatDark from '../assets/chat_dark.webp';
  import chatLight from '../assets/chat_light.webp';
  import taskDark from '../assets/task_dark.webp';
  import taskLight from '../assets/task_light.webp';
  import calendarDark from '../assets/calendar_dark.webp';
  import calendarLight from '../assets/calendar_light.webp';
  import mobileHomeDark from '../assets/mobile/mobile_home_dark.webp';
  import mobileHomeLight from '../assets/mobile/mobile_home_light.webp';
  import mobileMailDark from '../assets/mobile/mobile_mail_dark.webp';
  import mobileMailLight from '../assets/mobile/mobile_mail_light.webp';
  import mobileChatDark from '../assets/mobile/mobile_chat_dark.webp';
  import mobileChatLight from '../assets/mobile/mobile_chat_light.webp';
  import mobileTaskDark from '../assets/mobile/mobile_task_dark.webp';
  import mobileTaskLight from '../assets/mobile/mobile_task_light.webp';
  import mobileCalDark from '../assets/mobile/mobile_cal_dark.webp';
  import mobileCalLight from '../assets/mobile/mobile_cal_light.webp';

  export let feature: Feature;
  export let index: number = 0; // Index from parent loop

  const isRight = feature.imagePosition === 'right';
  const isMobile = feature.visualType === 'mobile';
  let isDark = true;
  let currentMobileIndex = 0;
  let imageContainer: HTMLDivElement;
  
  const cardSizes = {
    mail: Math.random() * 10 + 60,
    chat: Math.random() * 10 + 60,
    task: Math.random() * 10 + 60,
    calendar: Math.random() * 10 + 60,
  };
  
  const mobileScreenshots = [
    { dark: mobileHomeDark, light: mobileHomeLight, name: 'Home' },
    { dark: mobileMailDark, light: mobileMailLight, name: 'Mail' },
    { dark: mobileChatDark, light: mobileChatLight, name: 'Chat' },
    { dark: mobileTaskDark, light: mobileTaskLight, name: 'Task' },
    { dark: mobileCalDark, light: mobileCalLight, name: 'Calendar' },
  ];

  function getIconName(iconName: string): string {
    const iconMap: Record<string, string> = {
      'Sms': 'MessageSquare',
      'Cpu': 'Cpu',
      'Monitor': 'Monitor',
      'Devices': 'Smartphone',
    };
    return iconMap[iconName] || 'MessageSquare';
  }

  $: iconName = getIconName(feature.icon);

  function checkTheme() {
    isDark = document.documentElement.classList.contains('dark');
  }

  let intervalId: ReturnType<typeof setInterval> | null = null;
  let sectionElement: HTMLElement;
  let textElement: HTMLElement;
  let imageElement: HTMLElement;
  let cleanupAnimations: (() => void)[] = [];

  onMount(() => {
    checkTheme();
    const observer = new MutationObserver(checkTheme);
    observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['class']
    });

    if (isMobile && feature.title.includes("Mobile Experience")) {
      intervalId = setInterval(() => {
        currentMobileIndex = (currentMobileIndex + 1) % mobileScreenshots.length;
      }, 5000);
    }

    // Add scroll animations
    if (sectionElement) {
      const cleanup1 = createScrollAnimation(sectionElement, {
        threshold: 0.1,
        rootMargin: '0px 0px -100px 0px',
        once: true,
      });
      cleanupAnimations.push(cleanup1);
    }

    if (textElement) {
      const cleanup2 = createScrollAnimation(textElement, {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px',
        once: true,
      });
      cleanupAnimations.push(cleanup2);
    }

    if (imageElement) {
      const cleanup3 = createScrollAnimation(imageElement, {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px',
        once: true,
      });
      cleanupAnimations.push(cleanup3);
    }

    return () => {
      observer.disconnect();
      if (intervalId) clearInterval(intervalId);
      cleanupAnimations.forEach(cleanup => cleanup());
    };
  });

  function handlePrev() {
    currentMobileIndex = (currentMobileIndex - 1 + mobileScreenshots.length) % mobileScreenshots.length;
  }

  function handleNext() {
    currentMobileIndex = (currentMobileIndex + 1) % mobileScreenshots.length;
  }

  function handleDotClick(index: number) {
    currentMobileIndex = index;
  }

  $: unifiedImage = feature.title.includes("Never Alt-Tab") ? (isDark ? unifiedInboxDark : unifiedInboxLight) : null;
  $: aiImage = feature.title.includes("Your Brain") ? (isDark ? aiAssistantDark : aiAssistantLight) : null;
  $: isVerticalApps = feature.title.includes("Native Power");
  $: mailImage = isVerticalApps ? (isDark ? mailDark : mailLight) : null;
  $: chatImage = isVerticalApps ? (isDark ? chatDark : chatLight) : null;
  $: taskImage = isVerticalApps ? (isDark ? taskDark : taskLight) : null;
  $: calendarImage = isVerticalApps ? (isDark ? calendarDark : calendarLight) : null;
</script>

<section class="py-24 lg:py-32 relative overflow-hidden animate-ready" bind:this={sectionElement} style="contain: layout style paint;">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="flex flex-col {isRight ? 'lg:flex-row' : 'lg:flex-row-reverse'} items-center gap-12 lg:gap-20">
      
      <!-- Text Content -->
      <div class="flex-1 space-y-8 relative z-10 animate-ready" bind:this={textElement}>
        <div class="flex justify-center lg:justify-start">
          <div class="inline-flex items-center justify-center p-3 rounded-2xl bg-visir-surface/30 text-visir-primary backdrop-blur-sm border border-white/10 shadow-lg">
            <Icon name={iconName} size={32} />
          </div>
        </div>
        <h2 class="text-3xl md:text-4xl font-semibold font-display text-visir-text leading-tight drop-shadow-sm text-center lg:text-left">
          {feature.title}
        </h2>
        <p class="text-lg text-visir-text-muted leading-relaxed font-sans font-light text-center lg:text-left">
          {feature.description}
        </p>
        
        {#if feature.benefits}
          <ul class="space-y-4 mt-6">
            {#each feature.benefits as benefit}
              <li class="flex items-start gap-3 group">
                <div class="w-1.5 h-1.5 rounded-full bg-visir-primary mt-2.5 shadow-[0_0_8px_rgba(124,93,255,0.8)] group-hover:scale-150 transition-transform duration-200 flex-shrink-0"></div>
                <span class="text-visir-text-muted font-sans font-light group-hover:text-visir-text transition-colors duration-200 text-base">{benefit}</span>
              </li>
            {/each}
          </ul>
        {/if}
      </div>

      <!-- Visual Content -->
      <div class="flex-1 w-full perspective-1000" bind:this={imageContainer}>
        <div class="relative rounded-3xl border border-white/10 {isDark ? 'bg-visir-surface/5' : 'bg-white/30'} backdrop-blur-sm p-3 shadow-2xl overflow-hidden group card-hover hover:border-visir-primary/20 {isRight ? 'rotate-y-[-5deg] rotate-x-[2deg]' : 'rotate-y-[5deg] rotate-x-[2deg]'} hover:rotate-0" bind:this={imageElement} style="contain: layout style paint;">
          <div class="absolute inset-0 bg-gradient-to-tr from-white/5 via-transparent to-transparent opacity-50 group-hover:opacity-100 transition-opacity duration-200 pointer-events-none"></div>
          
          <div class="aspect-[4/3] {isDark ? 'bg-black/20' : 'bg-white/60'} backdrop-blur-sm rounded-2xl overflow-visible relative border border-white/5 shadow-inner flex items-center justify-center" style="contain: layout style paint;">
            <div class="absolute top-0 left-0 w-full h-full bg-[radial-gradient(ellipse_at_top,_var(--tw-gradient-stops))] from-visir-primary/10 via-transparent to-transparent pointer-events-none"></div>
            
            {#if isMobile && feature.title.includes("Command Center")}
              <!-- Mobile Screenshots Carousel -->
              <div class="relative z-10 w-full h-full flex items-center justify-center">
                <button
                  on:click={handlePrev}
                  class="absolute left-[10%] z-20 p-3 rounded-full bg-visir-surface/30 hover:bg-visir-surface/50 border border-white/10 transition-transform duration-200 hover:scale-110 shadow-lg backdrop-blur-sm"
                  aria-label="Previous screenshot"
                >
                  <Icon name="ChevronLeft" size={24} className="text-visir-text" />
                </button>

                <div class="relative bg-black border-[8px] {isDark ? 'border-white/40' : 'border-black/60'} rounded-[3rem] shadow-2xl flex flex-col overflow-hidden backdrop-blur-sm ring-1 ring-white/10" style="aspect-ratio: 9/19.5; max-width: 240px; width: 100%; max-height: 520px; margin-bottom: 10px; contain: layout style paint;">
                  <div class="absolute top-3 left-1/2 -translate-x-1/2 w-20 h-6 bg-black rounded-full z-30 shadow-sm"></div>
                  
                  <div class="flex-1 w-full relative overflow-hidden bg-black">
                    <Image 
                      src={isDark ? mobileScreenshots[currentMobileIndex].dark : mobileScreenshots[currentMobileIndex].light}
                      alt="{mobileScreenshots[currentMobileIndex].name} Interface"
                      className="w-full h-full"
                      imgClass="object-contain"
                      sizes="(max-width: 480px) 240px, 392px"
                      width="392"
                      height="852"
                      eager={true}
                      transition={false}
                    />
                  </div>

                  <div class="h-1 w-20 bg-white/20 rounded-full mx-auto mb-1 absolute bottom-1 left-1/2 -translate-x-1/2 z-30"></div>
                </div>

                <div class="absolute bottom-3 right-3 z-50 px-3 py-1.5 rounded-full bg-black/60 backdrop-blur-sm border border-white/20 shadow-lg">
                  <span class="text-xs font-medium text-white uppercase tracking-wider">
                    {mobileScreenshots[currentMobileIndex].name}
                  </span>
                </div>

                <button
                  on:click={handleNext}
                  class="absolute right-[10%] z-20 p-3 rounded-full bg-visir-surface/30 hover:bg-visir-surface/50 border border-white/10 transition-transform duration-200 hover:scale-110 shadow-lg backdrop-blur-sm"
                  aria-label="Next screenshot"
                >
                  <Icon name="ChevronRight" size={24} className="text-visir-text" />
                </button>

                <div class="absolute bottom-[-3rem] left-1/2 -translate-x-1/2 flex gap-2">
                  {#each mobileScreenshots as _, index}
                    <button
                      on:click={() => handleDotClick(index)}
                      class="transition-all duration-200 rounded-full {index === currentMobileIndex ? 'w-8 h-2 bg-visir-primary' : 'w-2 h-2 bg-visir-text-muted/40 hover:bg-visir-text-muted/60'}"
                      aria-label="Go to {mobileScreenshots[index].name} screenshot"
                    />
                  {/each}
                </div>
              </div>
            {:else if isMobile}
              <!-- Mobile Phone Mockup (fallback) -->
              <div class="relative z-10 w-[200px] h-[360px] sm:w-[240px] sm:h-[420px] bg-black border-[8px] {isDark ? 'border-white/40' : 'border-black/60'} rounded-[3rem] shadow-2xl flex flex-col overflow-hidden backdrop-blur-sm ring-1 ring-white/10" style="contain: layout style paint;">
                <div class="absolute top-3 left-1/2 -translate-x-1/2 w-20 h-6 bg-black rounded-full z-20 shadow-sm flex items-center justify-center gap-1.5">
                  <div class="w-1.5 h-1.5 rounded-full bg-visir-primary/30 animate-pulse"></div>
                  <div class="w-8 h-1 rounded-full bg-visir-surface/20"></div>
                </div>
                
                <div class="flex-1 bg-visir-surface/10 w-full flex flex-col p-4 relative pt-12">
                  <div class="flex justify-between items-center text-[8px] text-visir-text-muted mb-4 px-1 absolute top-3 w-full left-0 px-5">
                    <span class="font-semibold">9:41</span>
                    <div class="flex gap-1">
                      <div class="w-3 h-1.5 bg-visir-text-muted rounded-[1px]"></div>
                      <div class="w-3 h-1.5 bg-visir-text-muted rounded-[1px]"></div>
                      <div class="w-4 h-1.5 border border-visir-text-muted rounded-[2px] relative"><div class="absolute inset-0.5 bg-visir-text-muted"></div></div>
                    </div>
                  </div>

                  <div class="flex-1 flex flex-col items-center justify-start gap-3 w-full">
                    <div class="w-full flex items-center justify-between mb-2">
                      <span class="text-xs font-bold text-visir-text">Inbox</span>
                      <div class="w-6 h-6 rounded-full bg-visir-surface/30"></div>
                    </div>

                    <div class="w-full space-y-2">
                      {#each Array(4) as _, i}
                        <div class="h-12 bg-white/5 rounded-xl w-full border border-white/5 flex items-center px-3 gap-2 {i > 0 ? `opacity-${100 - i * 20}` : ''}">
                          <div class="w-6 h-6 rounded-full {i === 0 ? 'bg-visir-primary/20 border border-visir-primary/30' : 'bg-visir-text-muted/10 border border-visir-text-muted/20'}"></div>
                          <div class="flex-1 space-y-1">
                            <div class="h-1.5 bg-visir-text/20 rounded-full" style="width: {['66%', '75%', '50%', '66%'][i]}"></div>
                            {#if i < 3}
                              <div class="h-1.5 bg-visir-text/10 rounded-full" style="width: {['50%', '33%', '25%'][i]}"></div>
                            {/if}
                          </div>
                        </div>
                      {/each}
                    </div>
                  </div>

                  <div class="absolute bottom-16 right-4 w-10 h-10 bg-visir-primary rounded-full shadow-lg flex items-center justify-center text-white shadow-visir-primary/30">
                    <Icon name="Plus" size={20} />
                  </div>
                  
                  <div class="absolute bottom-0 left-0 w-full h-14 bg-visir-bg/80 backdrop-blur-sm border-t border-white/10 flex items-center justify-around px-2 z-10">
                    <div class="w-8 h-8 rounded-lg flex items-center justify-center bg-visir-primary/10 text-visir-primary">
                      <Icon name={iconName} size={16} />
                    </div>
                    <div class="w-8 h-8 rounded-lg flex items-center justify-center text-visir-text-muted opacity-50"><div class="w-4 h-4 rounded-sm bg-current"></div></div>
                    <div class="w-8 h-8 rounded-lg flex items-center justify-center text-visir-text-muted opacity-50"><div class="w-4 h-4 rounded-sm bg-current"></div></div>
                  </div>

                  <div class="h-1 w-20 bg-white/20 rounded-full mx-auto mb-1 absolute bottom-1 left-1/2 -translate-x-1/2 z-20"></div>
                </div>
              </div>
            {:else if unifiedImage}
              <!-- Desktop Mockup - Unified Inbox -->
              <div class="w-full h-full relative overflow-hidden rounded-lg">
                <Image 
                  src={unifiedImage} 
                  alt="Unified Inbox Interface" 
                  className="w-full h-full"
                  imgClass="object-cover object-left-top"
                  sizes="(max-width: 768px) 100vw, (max-width: 1280px) 50vw, 616px"
                  width="616"
                  height="504"
                  eager={index < 2}
                  priority={index < 2 ? 'high' : 'auto'}
                />
              </div>
            {:else if aiImage}
              <!-- Desktop Mockup - AI Assistant -->
              <div class="w-full h-full relative overflow-hidden rounded-lg">
                <Image 
                  src={aiImage} 
                  alt="AI Executive Assistant Interface" 
                  className="w-full h-full"
                  imgClass="object-cover object-left-top"
                  sizes="(max-width: 768px) 100vw, (max-width: 1280px) 50vw, 616px"
                  width="616"
                  height="461"
                  eager={index < 2}
                  priority={index < 2 ? 'high' : 'auto'}
                />
              </div>
            {:else if isVerticalApps && mailImage && chatImage && taskImage && calendarImage}
              <!-- Desktop Mockup - Vertical Apps -->
              <div class="w-full h-full relative overflow-visible rounded-lg flex items-center justify-center">
                <div class="absolute top-[0%] left-[5%] max-w-[50%] rounded-xl overflow-visible shadow-2xl transform rotate-[14deg] hover:top-[10%] hover:left-[-2%] hover:right-[-2%] hover:max-w-none hover:w-[104%] hover:h-full hover:rotate-0 hover:z-50 transition-transform duration-300 z-10 group cursor-pointer" style="contain: layout style paint;">
                  <div class="relative rounded-xl border-2 border-white/20 bg-visir-surface/30 backdrop-blur-sm">
                    <Image 
                      src={mailImage} 
                      alt="Mail Interface" 
                      className="block rounded-xl"
                      imgClass="max-w-full h-auto"
                      eager={index < 2}
                      priority={index < 2 ? 'high' : 'auto'}
                    />
                    <div class="absolute bottom-2 left-2 px-2 py-1 rounded-md bg-black/60 backdrop-blur-sm text-[10px] font-medium text-white opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none">Mail</div>
                  </div>
                </div>
                
                <div class="absolute top-[4%] right-[1%] max-w-[62%] rounded-xl overflow-visible shadow-2xl transform rotate-[-16deg] hover:top-[10%] hover:left-[-2%] hover:right-[-2%] hover:max-w-none hover:w-[104%] hover:h-full hover:rotate-0 hover:z-50 transition-transform duration-300 z-20 group cursor-pointer" style="contain: layout style paint;">
                  <div class="relative rounded-xl border-2 border-white/20 bg-visir-surface/30 backdrop-blur-sm">
                    <Image 
                      src={chatImage} 
                      alt="Chat Interface" 
                      className="block rounded-xl"
                      imgClass="max-w-full h-auto"
                      eager={index < 2}
                      priority={index < 2 ? 'high' : 'auto'}
                    />
                    <div class="absolute bottom-2 left-2 px-2 py-1 rounded-md bg-black/60 backdrop-blur-sm text-[10px] font-medium text-white opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none">Chat</div>
                  </div>
                </div>
                
                <div class="absolute bottom-[4%] left-[1%] max-w-[68%] rounded-xl overflow-visible shadow-2xl transform rotate-[-15deg] hover:bottom-auto hover:top-[10%] hover:left-[-2%] hover:right-[-2%] hover:max-w-none hover:w-[104%] hover:h-full hover:rotate-0 hover:z-50 transition-transform duration-300 z-30 group cursor-pointer" style="contain: layout style paint;">
                  <div class="relative rounded-xl border-2 border-white/20 bg-visir-surface/30 backdrop-blur-sm">
                    <Image 
                      src={taskImage} 
                      alt="Task Interface" 
                      className="block rounded-xl"
                      imgClass="max-w-full h-auto"
                      eager={index < 2}
                      priority={index < 2 ? 'high' : 'auto'}
                    />
                    <div class="absolute bottom-2 left-2 px-2 py-1 rounded-md bg-black/60 backdrop-blur-sm text-[10px] font-medium text-white opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none">Task</div>
                  </div>
                </div>
                
                <div class="absolute bottom-[0%] right-[5%] max-w-[58%] rounded-xl overflow-visible shadow-2xl transform rotate-[-3deg] hover:bottom-auto hover:top-[10%] hover:left-[-2%] hover:right-[-2%] hover:max-w-none hover:w-[104%] hover:h-full hover:rotate-0 hover:z-50 transition-transform duration-300 z-40 group cursor-pointer" style="contain: layout style paint;">
                  <div class="relative rounded-xl border-2 border-white/20 bg-visir-surface/30 backdrop-blur-sm">
                    <Image 
                      src={calendarImage} 
                      alt="Calendar Interface" 
                      className="block rounded-xl"
                      imgClass="max-w-full h-auto"
                      eager={index < 2}
                      priority={index < 2 ? 'high' : 'auto'}
                    />
                    <div class="absolute bottom-2 left-2 px-2 py-1 rounded-md bg-black/60 backdrop-blur-sm text-[10px] font-medium text-white opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none">Calendar</div>
                  </div>
                </div>
              </div>
            {:else}
              <!-- Default Fallback -->
              <div class="w-3/4 h-3/4 border border-dashed border-white/10 rounded-xl flex flex-col items-center justify-center text-visir-text-muted backdrop-blur-sm bg-white/5 shadow-2xl relative z-10">
                <Icon name={iconName} size={64} className="opacity-30 mb-4 text-visir-text" />
                <span class="text-xs uppercase tracking-widest font-semibold opacity-50 font-display">Interface Mockup</span>
              </div>
            {/if}
          </div>
        </div>
      </div>

    </div>
  </div>
</section>
