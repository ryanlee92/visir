<script lang="ts">
  import { link } from '../lib/router';
  import Icon from '../components/Icon.svelte';
  import Button from '../components/Button.svelte';
</script>

<div class="pt-24 min-h-screen">
  <section class="relative px-4 sm:px-6 lg:px-8 pt-10 pb-20 text-center max-w-5xl mx-auto">
    <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-xs font-medium uppercase tracking-wide mb-8 backdrop-blur-md">
      <Icon name="Code" size={14} />
      <span class="font-display tracking-wide">For Developers</span>
    </div>
    <h1 class="text-4xl md:text-6xl font-medium font-display text-visir-text mb-6 leading-tight">
      Ship faster.<br />
      <span class="text-emerald-400">Stay organized.</span>
    </h1>
    <p class="text-xl text-visir-text-muted max-w-2xl mx-auto font-light mb-10">
      As a PM, you're managing features, user feedback, and stakeholder requests. Visir consolidates everything into one timeline, so you can prioritize what to build next without context switching.
    </p>
    <div class="flex justify-center gap-4">
      <a href="/signup" use:link>
        <Button size="lg" className="gap-2">Start Organizing <Icon name="ArrowRight" size={18}/></Button>
      </a>
    </div>
  </section>

  <section class="px-4 sm:px-6 lg:px-8 py-20 bg-visir-surface/5 border-y border-white/5">
    <div class="max-w-7xl mx-auto grid md:grid-cols-3 gap-8">
      <div class="p-6 rounded-3xl bg-white/10 dark:bg-white/5 border border-white/20 dark:border-white/10 hover:border-emerald-500/30 transition-colors backdrop-blur-xl shadow-lg">
        <div class="w-12 h-12 rounded-xl bg-emerald-500/10 text-emerald-400 flex items-center justify-center mb-4">
          <Icon name="CheckSquare" size={24} />
        </div>
        <h3 class="text-xl font-display font-medium text-visir-text mb-2">Feature Tracking</h3>
        <p class="text-visir-text-muted font-light text-sm">
          Turn user feedback emails into tasks instantly. Track feature requests, bug reports, and stakeholder asks all in one place. Never lose a great idea.
        </p>
      </div>
      <div class="p-6 rounded-3xl bg-white/10 dark:bg-white/5 border border-white/20 dark:border-white/10 hover:border-emerald-500/30 transition-colors backdrop-blur-xl shadow-lg">
        <div class="w-12 h-12 rounded-xl bg-emerald-500/10 text-emerald-400 flex items-center justify-center mb-4">
          <Icon name="Calendar" size={24} />
        </div>
        <h3 class="text-xl font-display font-medium text-visir-text mb-2">Sprint Planning</h3>
        <p class="text-visir-text-muted font-light text-sm">
          Drag tasks directly onto your calendar to plan sprints visually. See your capacity at a glance and ensure you're not overcommitting.
        </p>
      </div>
      <div class="p-6 rounded-3xl bg-white/10 dark:bg-white/5 border border-white/20 dark:border-white/10 hover:border-emerald-500/30 transition-colors backdrop-blur-xl shadow-lg">
        <div class="w-12 h-12 rounded-xl bg-emerald-500/10 text-emerald-400 flex items-center justify-center mb-4">
          <Icon name="Zap" size={24} />
        </div>
        <h3 class="text-xl font-display font-medium text-visir-text mb-2">AI-Powered Prioritization</h3>
        <p class="text-visir-text-muted font-light text-sm">
          Get intelligent suggestions on what to prioritize based on user feedback, stakeholder requests, and project deadlines.
        </p>
      </div>
    </div>
  </section>
</div>
