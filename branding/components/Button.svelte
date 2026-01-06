<script lang="ts">
  export let variant: 'primary' | 'secondary' | 'outline' | 'ghost' = 'primary';
  export let size: 'sm' | 'md' | 'lg' = 'md';
  export let className = '';
  
  $: variantClass = {
    primary: 'text-white dark:text-white border border-white/20 dark:border-white/10 backdrop-blur-xl button-primary',
    secondary: 'border border-white/20 dark:border-white/10 backdrop-blur-xl shadow-lg button-secondary',
    outline: 'border border-white/20 dark:border-white/10 backdrop-blur-xl shadow-lg button-outline',
    ghost: 'text-visir-text-muted dark:text-visir-text-muted hover:text-visir-text dark:hover:text-white hover:bg-white/10 dark:hover:bg-white/5 hover:backdrop-blur-sm'
  }[variant];
  
  $: buttonStyle = '';
  
  $: sizeClass = {
    sm: 'px-3 py-1.5 text-sm',
    md: 'px-5 py-2.5 text-sm',
    lg: 'px-8 py-3.5 text-base'
  }[size];
</script>

<button
  class="inline-flex items-center justify-center rounded-2xl font-medium transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-visir-bg active:scale-95 {variantClass} {sizeClass} {className}"
  {...$$restProps}
>
  <slot />
</button>

<style>
  :global(.button-primary) {
    /* Light mode: use darker primary color for better contrast */
    background: rgba(90, 63, 215, 0.7) !important;
    backdrop-filter: blur(12px) !important;
    -webkit-backdrop-filter: blur(12px) !important;
    box-shadow: 0 0 20px rgba(90, 63, 215, 0.4), inset 0 1px 0 rgba(255, 255, 255, 0.2) !important;
  }
  
  :global(.button-primary:hover) {
    background: rgba(90, 63, 215, 0.85) !important;
    box-shadow: 0 0 25px rgba(90, 63, 215, 0.5), inset 0 1px 0 rgba(255, 255, 255, 0.25) !important;
  }
  
  :global(.dark .button-primary) {
    /* Dark mode: use original brighter color */
    background: rgba(124, 93, 255, 0.8) !important;
    box-shadow: 0 0 20px rgba(124, 93, 255, 0.5), inset 0 1px 0 rgba(255, 255, 255, 0.2) !important;
  }
  
  :global(.dark .button-primary:hover) {
    background: rgba(124, 93, 255, 0.9) !important;
    box-shadow: 0 0 25px rgba(124, 93, 255, 0.6), inset 0 1px 0 rgba(255, 255, 255, 0.25) !important;
  }
  
  :global(.button-secondary) {
    background: rgba(255, 255, 255, 0.1) !important;
    backdrop-filter: blur(12px) !important;
    -webkit-backdrop-filter: blur(12px) !important;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1), inset 0 1px 0 rgba(255, 255, 255, 0.1) !important;
    color: #000000 !important;
  }
  
  :global(.button-secondary:hover) {
    background: rgba(255, 255, 255, 0.15) !important;
    box-shadow: 0 6px 12px rgba(0, 0, 0, 0.15), inset 0 1px 0 rgba(255, 255, 255, 0.15) !important;
  }
  
  :global(.dark .button-secondary) {
    background: rgba(255, 255, 255, 0.05) !important;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3), inset 0 1px 0 rgba(255, 255, 255, 0.05) !important;
    color: #FFFFFF !important;
  }
  
  :global(.dark .button-secondary:hover) {
    background: rgba(255, 255, 255, 0.1) !important;
    box-shadow: 0 6px 12px rgba(0, 0, 0, 0.4), inset 0 1px 0 rgba(255, 255, 255, 0.1) !important;
  }
  
  :global(.button-outline) {
    background: rgba(255, 255, 255, 0.1) !important;
    backdrop-filter: blur(12px) !important;
    -webkit-backdrop-filter: blur(12px) !important;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1), inset 0 1px 0 rgba(255, 255, 255, 0.1) !important;
    color: #000000 !important;
  }
  
  :global(.button-outline:hover) {
    background: rgba(255, 255, 255, 0.15) !important;
    box-shadow: 0 6px 12px rgba(0, 0, 0, 0.15), inset 0 1px 0 rgba(255, 255, 255, 0.15) !important;
  }
  
  :global(.dark .button-outline) {
    background: rgba(255, 255, 255, 0.05) !important;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3), inset 0 1px 0 rgba(255, 255, 255, 0.05) !important;
    color: #FFFFFF !important;
  }
  
  :global(.dark .button-outline:hover) {
    background: rgba(255, 255, 255, 0.1) !important;
    box-shadow: 0 6px 12px rgba(0, 0, 0, 0.4), inset 0 1px 0 rgba(255, 255, 255, 0.1) !important;
  }
</style>
