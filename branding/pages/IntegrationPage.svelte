<script lang="ts">
  import { onMount } from 'svelte';

  let providerName = '';
  let providerIcon = '';
  let href = 'com.wavetogether.fillin://';

  function getQueryParams() {
    if (typeof window === 'undefined') {
      return {
        providerName: 'Unknown Provider',
        providerIcon: '',
        href: 'com.wavetogether.fillin://'
      };
    }
    
    const params = new URLSearchParams(window.location.search);
    const hrefParam = params.get('href');
    const urlDecodedHref = hrefParam ? decodeURIComponent(hrefParam) : 'com.wavetogether.fillin://';
    
    return {
      providerName: params.get('provider') || 'Unknown Provider',
      providerIcon: params.get('icon') || '',
      href: urlDecodedHref || 'com.wavetogether.fillin://'
    };
  }

  onMount(() => {
    const result = getQueryParams();
    providerName = result.providerName;
    providerIcon = result.providerIcon;
    href = result.href;

    // Immediately redirect to the app (matching web/integration/index.html behavior)
    if (href && href !== 'com.wavetogether.fillin://') {
      window.location.assign(href);
    }
  });
</script>

<div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-200 via-purple-200 to-pink-200 dark:from-blue-900 dark:via-purple-900 dark:to-pink-900">
  <div class="max-w-md w-full mx-4">
    <div class="bg-white/95 dark:bg-gray-900/95 backdrop-blur-xl rounded-3xl p-8 shadow-2xl border border-white/20 dark:border-white/10">
      <div class="text-center">
        <div class="flex items-center justify-center gap-3 mb-6">
          <span class="text-4xl">🔗</span>
          <span class="text-4xl">✅</span>
        </div>
        
        {#if providerIcon}
          <img 
            src={providerIcon} 
            alt={providerName} 
            class="w-16 h-16 rounded-2xl bg-gray-100 dark:bg-gray-800 p-2 mx-auto mb-4 shadow-lg object-contain"
          />
        {/if}
        
        <h1 class="text-2xl font-semibold font-display text-visir-text mb-2">
          {providerName}
        </h1>
        
        <p class="text-lg text-visir-text-muted mb-8 font-light">
          Successfully linked
        </p>
        
        <a 
          href={href} 
          class="inline-block px-8 py-4 bg-visir-primary text-white rounded-xl font-medium hover:bg-opacity-90 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:-translate-y-0.5"
        >
          Open Visir
        </a>
      </div>
    </div>
  </div>
</div>

