<script lang="ts">
  import { onMount } from 'svelte';
  import { link } from '../lib/router';
  import Icon from '../components/Icon.svelte';
  import Button from '../components/Button.svelte';

  let isDark = true;

  function checkTheme() {
    isDark = document.documentElement.classList.contains('dark');
  }

  onMount(() => {
    checkTheme();
    const observer = new MutationObserver(checkTheme);
    observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['class']
    });
    return () => observer.disconnect();
  });

  $: badgeClass = isDark 
    ? 'bg-amber-500/10 border-amber-500/20 text-amber-400'
    : 'bg-amber-500/20 border-amber-500/30 text-amber-600';
  $: headingClass = isDark ? 'text-amber-400' : 'text-amber-600';
  $: iconBgClass = isDark ? 'bg-amber-500/10 text-amber-400' : 'bg-amber-500/20 text-amber-600';
</script>

<div class="pt-24 min-h-screen">
  <!-- Hero -->
  <section class="relative px-4 sm:px-6 lg:px-8 pt-10 pb-20 text-center max-w-5xl mx-auto">
    <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-full {badgeClass} border text-xs font-medium uppercase tracking-wide mb-8 backdrop-blur-md">
      <Icon name="Crown" size={14} />
      <span class="font-display tracking-wide">For Executives</span>
    </div>
    <h1 class="text-4xl md:text-6xl font-medium font-display text-visir-text mb-6 leading-tight">
      Your Personal Command Center.<br />
      <span class={headingClass}>Master every priority.</span>
    </h1>
    <p class="text-xl text-visir-text-muted max-w-2xl mx-auto font-light mb-10">
      As an executive, you juggle countless priorities. Visir unifies your emails, calendar, and tasks into one intelligent timeline, so you can focus on what matters—not managing tools.
    </p>
    <div class="flex justify-center gap-4">
      <a href="/signup" use:link>
        <Button size="lg" className="gap-2">Start Managing Better <Icon name="ArrowRight" size={18}/></Button>
      </a>
    </div>
  </section>

  <!-- Feature Grid -->
  <section class="px-4 sm:px-6 lg:px-8 py-20 bg-visir-surface/5 border-y border-white/5">
    <div class="max-w-7xl mx-auto grid md:grid-cols-3 gap-8">
      <div class="p-6 rounded-3xl bg-white/10 dark:bg-white/5 border border-white/20 dark:border-white/10 backdrop-blur-xl shadow-lg">
        <div class="w-12 h-12 rounded-xl {iconBgClass} flex items-center justify-center mb-4">
          <Icon name="CheckSquare" size={24} />
        </div>
        <h3 class="text-xl font-display font-medium text-visir-text mb-2">Priority Management</h3>
        <p class="text-visir-text-muted font-light text-sm">
          See all your action items in one place. Drag emails to your calendar to time-block them, or convert them to tasks instantly. Never lose track of what needs your attention.
        </p>
      </div>
      <div class="p-6 rounded-3xl bg-white/10 dark:bg-white/5 border border-white/20 dark:border-white/10 backdrop-blur-xl shadow-lg">
        <div class="w-12 h-12 rounded-xl {iconBgClass} flex items-center justify-center mb-4">
          <Icon name="Calendar" size={24} />
        </div>
        <h3 class="text-xl font-display font-medium text-visir-text mb-2">Strategic Time Blocking</h3>
        <p class="text-visir-text-muted font-light text-sm">
          Block time for deep work, strategy sessions, and critical decisions. Visir helps you protect your calendar and ensures you have time for what truly matters.
        </p>
      </div>
      <div class="p-6 rounded-3xl bg-white/10 dark:bg-white/5 border border-white/20 dark:border-white/10 backdrop-blur-xl shadow-lg">
        <div class="w-12 h-12 rounded-xl {iconBgClass} flex items-center justify-center mb-4">
          <Icon name="Zap" size={24} />
        </div>
        <h3 class="text-xl font-display font-medium text-visir-text mb-2">AI-Powered Insights</h3>
        <p class="text-visir-text-muted font-light text-sm">
          Get intelligent summaries of your inbox, meeting prep, and priority suggestions. Let AI handle the triage so you can focus on execution.
        </p>
      </div>
    </div>
  </section>
</div>
