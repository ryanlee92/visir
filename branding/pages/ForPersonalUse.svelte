<script lang="ts">
  import { link } from '../lib/router';
  import Icon from '../components/Icon.svelte';
  import Button from '../components/Button.svelte';
</script>

<div class="pt-24 min-h-screen">
  <section class="relative px-4 sm:px-6 lg:px-8 pt-10 pb-20 text-center max-w-5xl mx-auto">
    <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-pink-500/10 border border-pink-500/20 text-pink-400 text-xs font-medium uppercase tracking-wide mb-8 backdrop-blur-md">
      <Icon name="User" size={14} />
      <span class="font-display tracking-wide">For Freelancers</span>
    </div>
    <h1 class="text-4xl md:text-6xl font-medium font-display text-visir-text mb-6 leading-tight">
      Run your business.<br />
      <span class="text-pink-400">Stay organized.</span>
    </h1>
    <p class="text-xl text-visir-text-muted max-w-2xl mx-auto font-light mb-10">
      As a freelancer, you're managing clients, projects, and deadlines. Visir helps you track everything in one place, so you can focus on delivering great work—not managing spreadsheets.
    </p>
    <div class="flex justify-center gap-4">
      <a href="/signup" use:link>
        <Button size="lg" className="gap-2">Get Organized <Icon name="ArrowRight" size={18}/></Button>
      </a>
    </div>
  </section>

  <section class="px-4 sm:px-6 lg:px-8 py-20 bg-visir-surface/5 border-y border-white/5">
    <div class="max-w-7xl mx-auto grid md:grid-cols-3 gap-8">
      <div class="p-6 rounded-3xl bg-white/10 dark:bg-white/5 border border-white/20 dark:border-white/10 backdrop-blur-xl shadow-lg">
        <div class="w-12 h-12 rounded-xl bg-pink-500/10 text-pink-400 flex items-center justify-center mb-4">
          <Icon name="CheckSquare" size={24} />
        </div>
        <h3 class="text-xl font-display font-medium text-visir-text mb-2">Client Project Tracking</h3>
        <p class="text-visir-text-muted font-light text-sm">
          Manage all your client projects in one place. Convert client emails to tasks, track deadlines, and never miss a deliverable.
        </p>
      </div>
      <div class="p-6 rounded-3xl bg-white/10 dark:bg-white/5 border border-white/20 dark:border-white/10 backdrop-blur-xl shadow-lg">
        <div class="w-12 h-12 rounded-xl bg-pink-500/10 text-pink-400 flex items-center justify-center mb-4">
          <Icon name="Calendar" size={24} />
        </div>
        <h3 class="text-xl font-display font-medium text-visir-text mb-2">Time Blocking for Projects</h3>
        <p class="text-visir-text-muted font-light text-sm">
          Block time for each client project on your calendar. See your capacity at a glance and ensure you're not overcommitting.
        </p>
      </div>
      <div class="p-6 rounded-3xl bg-white/10 dark:bg-white/5 border border-white/20 dark:border-white/10 backdrop-blur-xl shadow-lg">
        <div class="w-12 h-12 rounded-xl bg-pink-500/10 text-pink-400 flex items-center justify-center mb-4">
          <Icon name="Zap" size={24} />
        </div>
        <h3 class="text-xl font-display font-medium text-visir-text mb-2">AI-Powered Client Communication</h3>
        <p class="text-visir-text-muted font-light text-sm">
          Get AI-powered suggestions for client emails and project updates. Draft professional responses faster and stay on top of all client communications.
        </p>
      </div>
    </div>
  </section>
</div>
