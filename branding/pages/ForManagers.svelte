<script lang="ts">
  import { link } from '../lib/router';
  import Icon from '../components/Icon.svelte';
  import Button from '../components/Button.svelte';
</script>

<div class="pt-24 min-h-screen">
  <section class="relative px-4 sm:px-6 lg:px-8 pt-10 pb-20 text-center max-w-5xl mx-auto">
    <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-blue-500/10 border border-blue-500/20 text-blue-400 text-xs font-medium uppercase tracking-wide mb-8 backdrop-blur-md">
      <Icon name="Code" size={14} />
      <span class="font-display tracking-wide">For Managers</span>
    </div>
    <h1 class="text-4xl md:text-6xl font-medium font-display text-visir-text mb-6 leading-tight">
      Code with focus.<br />
      <span class="text-blue-400">Manage tasks effortlessly.</span>
    </h1>
    <p class="text-xl text-visir-text-muted max-w-2xl mx-auto font-light mb-10">
      As an engineer, you need to track PRs, code reviews, and technical tasks. Visir helps you stay organized so you can focus on building, not managing your todo list.
    </p>
    <div class="flex justify-center gap-4">
      <a href="/signup" use:link>
        <Button size="lg" className="gap-2">Start Coding Better <Icon name="ArrowRight" size={18}/></Button>
      </a>
    </div>
  </section>

  <section class="px-4 sm:px-6 lg:px-8 py-20 bg-visir-surface/5 border-y border-white/5">
    <div class="max-w-7xl mx-auto grid md:grid-cols-3 gap-8">
      <div class="p-6 rounded-3xl bg-white/10 dark:bg-white/5 border border-white/20 dark:border-white/10 backdrop-blur-xl shadow-lg">
        <div class="w-12 h-12 rounded-xl bg-blue-500/10 text-blue-400 flex items-center justify-center mb-4">
          <Icon name="CheckSquare" size={24} />
        </div>
        <h3 class="text-xl font-display font-medium text-visir-text mb-2">Technical Task Management</h3>
        <p class="text-visir-text-muted font-light text-sm">
          Track code reviews, bug fixes, and feature implementations in one place. Convert PR notifications to tasks and never lose track of what needs your attention.
        </p>
      </div>
      <div class="p-6 rounded-3xl bg-white/10 dark:bg-white/5 border border-white/20 dark:border-white/10 backdrop-blur-xl shadow-lg">
        <div class="w-12 h-12 rounded-xl bg-blue-500/10 text-blue-400 flex items-center justify-center mb-4">
          <Icon name="Calendar" size={24} />
        </div>
        <h3 class="text-xl font-display font-medium text-visir-text mb-2">Deep Work Protection</h3>
        <p class="text-visir-text-muted font-light text-sm">
          Block time for coding sessions on your calendar. Visir helps you protect your focus time and ensures you have dedicated hours for building.
        </p>
      </div>
      <div class="p-6 rounded-3xl bg-white/10 dark:bg-white/5 border border-white/20 dark:border-white/10 backdrop-blur-xl shadow-lg">
        <div class="w-12 h-12 rounded-xl bg-blue-500/10 text-blue-400 flex items-center justify-center mb-4">
          <Icon name="Zap" size={24} />
        </div>
        <h3 class="text-xl font-display font-medium text-visir-text mb-2">Context Switching Elimination</h3>
        <p class="text-visir-text-muted font-light text-sm">
          Reply to PR comments, review code, and manage tasks all within Visir. No more switching between GitHub, Slack, and your task manager.
        </p>
      </div>
    </div>
  </section>
</div>
