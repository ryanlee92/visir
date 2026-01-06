<script lang="ts">
  import { onMount } from 'svelte';
  import { link, location } from '../lib/router';
  import Icon from './Icon.svelte';
  import Button from './Button.svelte';
  import type { NavItem } from '../types';
  import visirLogo32 from '../assets/visir/visir_foreground-32.webp';

  const navItems: NavItem[] = [
    { label: 'Features', href: '/#features' },
    { label: 'Pricing', href: '/pricing' },
    { label: 'Download', href: '/download' },
    { label: 'Blog', href: '/blog' },
  ];

  let isScrolled = false;
  let isMobileMenuOpen = false;
  let isDark = true;
  
  $: currentLocation = $location;
  
  // Reactive check for theme changes
  $: isDark = document.documentElement.classList.contains('dark');

  onMount(() => {
    // Check initial theme
    isDark = document.documentElement.classList.contains('dark');
    
    // Watch for theme changes
    const observer = new MutationObserver(() => {
      isDark = document.documentElement.classList.contains('dark');
    });
    observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['class']
    });

    let ticking = false;
    const handleScroll = () => {
      if (!ticking) {
        window.requestAnimationFrame(() => {
          isScrolled = window.scrollY > 20;
          ticking = false;
        });
        ticking = true;
      }
    };
    window.addEventListener('scroll', handleScroll, { passive: true });
    
    return () => {
      window.removeEventListener('scroll', handleScroll);
      observer.disconnect();
    };
  });

  function toggleTheme() {
    if (isDark) {
      document.documentElement.classList.remove('dark');
      localStorage.theme = 'light';
      isDark = false;
    } else {
      document.documentElement.classList.add('dark');
      localStorage.theme = 'dark';
      isDark = true;
    }
  }

  function isActiveLink(path: string): boolean {
    if (path.startsWith('/#')) return false;
    return currentLocation === path;
  }

  function handleHashClick(e: MouseEvent, href: string) {
    if (href.startsWith('/#')) {
      const hash = href.replace('/', '');
      if (currentLocation !== '/') {
        e.preventDefault();
        window.location.href = href;
      } else {
        e.preventDefault();
        const element = document.getElementById(hash.replace('#', ''));
        if (element) {
          // Use requestAnimationFrame to batch DOM reads and avoid forced reflow
          requestAnimationFrame(() => {
            const offset = 100;
            const elementPosition = element.getBoundingClientRect().top;
            const offsetPosition = elementPosition + window.pageYOffset - offset;
            window.scrollTo({
              top: offsetPosition,
              behavior: 'smooth'
            });
          });
        }
      }
    }
  }

  function handleLogoClick(e: MouseEvent) {
    e.preventDefault();
    window.location.href = '/';
  }
</script>

<nav class="fixed top-0 left-0 right-0 z-50 transition-opacity duration-200 {isScrolled ? (isDark ? 'bg-[#1C1C1B]/70 shadow-sm border-b border-white/[0.02] navbar-scrolled' : 'bg-white/90 shadow-sm border-b border-black/[0.02] navbar-scrolled') : 'bg-transparent border-b border-transparent'}" style="contain: layout style paint;">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="flex items-center justify-between h-16">
      <!-- Logo -->
      <a 
        href="/"
        use:link
        class="flex-shrink-0 flex items-center gap-2 cursor-pointer"
        on:click={handleLogoClick}
      >
        <img 
          src={visirLogo32} 
          alt="Visir Logo" 
          class="h-8 w-8 object-contain"
          sizes="32px"
          loading="eager"
          fetchpriority="high"
          decoding="async"
          on:error={(e) => {
            const img = e.currentTarget;
            img.style.display = 'none';
            const parent = img.parentElement;
            if (parent && !parent.querySelector('span')) {
              const span = document.createElement('span');
              span.className = 'text-2xl font-semibold font-cookie text-visir-text';
              span.textContent = 'Visir';
              parent.appendChild(span);
            }
          }}
        />
        <span class="text-2xl font-semibold font-cookie tracking-tight text-visir-text">Visir</span>
      </a>

      <!-- Desktop Nav -->
      <div class="hidden md:flex items-center gap-8">
        <div class="flex items-baseline space-x-8">
          {#each navItems as item}
            {@const active = isActiveLink(item.href)}
            <a
              href={item.href}
              use:link
              on:click={(e) => handleHashClick(e, item.href)}
              class="transition-colors px-3 py-2 rounded-xl text-sm font-normal hover:font-medium hover:bg-visir-surface/30 {active ? 'text-visir-primary font-medium bg-visir-surface/10' : 'text-visir-text-muted hover:text-visir-text'}"
            >
              {item.label}
            </a>
          {/each}
        </div>
      </div>

      <!-- CTA Buttons & Theme Toggle -->
      <div class="hidden md:flex items-center gap-4">
        <button 
          on:click={toggleTheme}
          class="p-2 rounded-full text-visir-text-muted hover:text-visir-text hover:bg-visir-surface/30 transition-colors"
          aria-label="Toggle theme"
        >
          {#if isDark}
            <Icon name="Sun" size={20} />
          {:else}
            <Icon name="Moon" size={20} />
          {/if}
        </button>
        <a href="/download" use:link>
          <Button variant="primary" size="sm">Get Started Free</Button>
        </a>
      </div>

      <!-- Mobile menu button -->
      <div class="md:hidden flex items-center gap-4">
        <button 
          on:click={toggleTheme}
          class="p-2 rounded-full text-visir-text-muted hover:text-visir-text hover:bg-visir-surface/30 transition-colors"
        >
          {#if isDark}
            <Icon name="Sun" size={20} />
          {:else}
            <Icon name="Moon" size={20} />
          {/if}
        </button>
        <button
          on:click={() => isMobileMenuOpen = !isMobileMenuOpen}
          class="inline-flex items-center justify-center p-2 rounded-xl text-visir-text-muted hover:text-visir-text hover:bg-visir-surface/30 focus:outline-none"
        >
          {#if isMobileMenuOpen}
            <Icon name="X" size={24} />
          {:else}
            <Icon name="Menu" size={24} />
          {/if}
        </button>
      </div>
    </div>
  </div>

  <!-- Mobile Menu -->
  {#if isMobileMenuOpen}
    <div class="md:hidden bg-visir-bg/60 backdrop-blur-sm border-b border-visir-outline/10 h-screen transition-opacity duration-200">
      <div class="px-2 pt-2 pb-3 space-y-1 sm:px-3">
        {#each navItems as item}
          <a
            href={item.href}
            use:link
            on:click={(e) => {
              isMobileMenuOpen = false;
              handleHashClick(e, item.href);
            }}
            class="block px-3 py-4 rounded-xl text-lg font-normal {isActiveLink(item.href) ? 'text-visir-primary bg-visir-surface/10' : 'text-visir-text-muted hover:text-visir-text'}"
          >
            {item.label}
          </a>
        {/each}
        <div class="mt-8 pt-8 border-t border-visir-outline/10 flex flex-col gap-4 px-3">
          <a href="/download" use:link on:click={() => isMobileMenuOpen = false}>
            <Button variant="primary" className="w-full justify-center">Get Started Free</Button>
          </a>
        </div>
      </div>
    </div>
  {/if}
</nav>

<style>
  .navbar-scrolled {
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
  }
</style>
