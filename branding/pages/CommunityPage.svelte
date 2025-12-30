<script lang="ts">
  import { link } from '../lib/router';
  import Icon from '../components/Icon.svelte';
</script>

<div class="pt-32 pb-24 min-h-screen">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <!-- Hero -->
    <div class="text-center mb-20">
      <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-visir-primary/10 border border-visir-primary/20 text-visir-primary text-xs font-medium uppercase tracking-wide mb-8 backdrop-blur-md">
        <Icon name="Users" size={14} />
        <span class="font-display tracking-wide">Community</span>
      </div>
      <h1 class="text-4xl sm:text-6xl font-medium font-display tracking-tight text-visir-text mb-6">
        Join the Visir Community
      </h1>
      <p class="text-xl text-visir-text-muted max-w-2xl mx-auto font-light">
        Connect with other users, share tips, and get help from the community.
      </p>
    </div>

    <!-- Community Sections -->
    <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8 mb-16">
      <!-- Discord section commented out
      <div class="p-8 rounded-3xl bg-white/10 dark:bg-white/5 border border-white/20 dark:border-white/10 hover:border-visir-primary/30 transition-all backdrop-blur-xl shadow-lg">
        <div class="w-12 h-12 rounded-xl bg-visir-primary/10 text-visir-primary flex items-center justify-center mb-4">
          <Icon name="MessageSquare" size={24} />
        </div>
        <h3 class="text-xl font-display font-medium text-visir-text mb-3">Discord</h3>
        <p class="text-visir-text-muted font-light text-sm mb-4">
          Join our Discord server to chat with other users, ask questions, and share your workflows.
        </p>
        <a href="#" class="inline-flex items-center gap-2 text-visir-primary hover:text-visir-primary/80 transition-colors text-sm font-medium">
          Join Discord <Icon name="ArrowRight" size={16} />
        </a>
      </div>
      -->

      <div class="p-8 rounded-3xl bg-white/10 dark:bg-white/5 border border-white/20 dark:border-white/10 hover:border-visir-primary/30 transition-all backdrop-blur-xl shadow-lg">
        <div class="w-12 h-12 rounded-xl bg-visir-primary/10 text-visir-primary flex items-center justify-center mb-4">
          <Icon name="Sparkles" size={24} />
        </div>
        <h3 class="text-xl font-display font-medium text-visir-text mb-3">Feature Requests</h3>
        <p class="text-visir-text-muted font-light text-sm mb-4">
          Share your ideas and vote on features you'd like to see in Visir. Help shape the future of the product.
        </p>
        <a href="/feature-requests" use:link class="inline-flex items-center gap-2 text-visir-primary hover:text-visir-primary/80 transition-colors text-sm font-medium">
          View Requests <Icon name="ArrowRight" size={16} />
        </a>
      </div>

      <div class="p-8 rounded-3xl bg-white/10 dark:bg-white/5 border border-white/20 dark:border-white/10 hover:border-visir-primary/30 transition-all backdrop-blur-xl shadow-lg">
        <div class="w-12 h-12 rounded-xl bg-visir-primary/10 text-visir-primary flex items-center justify-center mb-4">
          <Icon name="HelpCircle" size={24} />
        </div>
        <h3 class="text-xl font-display font-medium text-visir-text mb-3">Help Center</h3>
        <p class="text-visir-text-muted font-light text-sm mb-4">
          Find answers to common questions, watch tutorials, and learn how to get the most out of Visir.
        </p>
        <a href="/help" use:link class="inline-flex items-center gap-2 text-visir-primary hover:text-visir-primary/80 transition-colors text-sm font-medium">
          Get Help <Icon name="ArrowRight" size={16} />
        </a>
      </div>
    </div>
  </div>
</div>
