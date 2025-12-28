<script lang="ts">
  import Icon from './Icon.svelte';
</script>

<section class="py-24 relative overflow-hidden">
  <!-- Subtle Security Gradient Background -->
  <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[400px] bg-emerald-500/5 rounded-full blur-[120px] pointer-events-none"></div>

  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
    <div class="text-center max-w-3xl mx-auto mb-16">
      <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-xs font-medium uppercase tracking-wide mb-6 backdrop-blur-sm">
        <Icon name="Shield" size={14} />
        <span class="font-display tracking-wide">Uncompromising Privacy</span>
      </div>
      <h2 class="text-3xl md:text-5xl font-semibold font-display text-visir-text mb-6 tracking-tight drop-shadow-md">
        Your data stays <span class="text-emerald-400">yours</span>.
      </h2>
      <p class="text-lg text-visir-text-muted font-light leading-relaxed">
        We designed Visir with extreme security in mind. We don't need your data, so we built an architecture that makes it impossible for us to see it.
      </p>
    </div>

    <div class="grid md:grid-cols-3 gap-6">
      <!-- Card 1: Local Integrations -->
      <div class="p-8 rounded-3xl bg-white/10 dark:bg-white/5 backdrop-blur-sm border border-white/20 dark:border-white/10 hover:border-emerald-500/30 transition-transform duration-200 group hover:-translate-y-1 shadow-lg" style="contain: layout style paint;">
        <div class="w-12 h-12 rounded-2xl bg-emerald-500/10 flex items-center justify-center text-emerald-400 mb-6 group-hover:scale-110 transition-transform duration-300">
          <Icon name="Globe" size={24} />
        </div>
        <h3 class="text-xl font-medium font-display text-visir-text mb-4">Direct Client-Side Integrations</h3>
        <p class="text-visir-text-muted font-light text-sm leading-relaxed mb-4">
          When you connect Slack, Gmail, or Notion, Visir communicates directly from your device to their servers. 
        </p>
        <p class="text-visir-text-muted font-light text-sm leading-relaxed border-t border-white/5 pt-4">
          <span class="text-emerald-400 font-medium">No Middleman:</span> Your sensitive integration data never passes through Visir's servers. It stays strictly between you and your providers.
        </p>
      </div>

      <!-- Card 2: AI Privacy & BYOK -->
      <div class="p-8 rounded-3xl bg-white/10 dark:bg-white/5 backdrop-blur-sm border border-white/20 dark:border-white/10 hover:border-emerald-500/30 transition-transform duration-200 group hover:-translate-y-1 shadow-lg" style="contain: layout style paint;">
        <div class="w-12 h-12 rounded-2xl bg-emerald-500/10 flex items-center justify-center text-emerald-400 mb-6 group-hover:scale-110 transition-transform duration-300">
          <Icon name="Key" size={24} />
        </div>
        <h3 class="text-xl font-medium font-display text-visir-text mb-4">Private AI & BYO-Key</h3>
        <p class="text-visir-text-muted font-light text-sm leading-relaxed mb-4">
          AI features connect directly to providers (like OpenAI) without logging. We disable all data retention for training by default.
        </p>
        <p class="text-visir-text-muted font-light text-sm leading-relaxed border-t border-white/5 pt-4">
          <span class="text-emerald-400 font-medium">Total Control:</span> Want complete control? Use your own API key. Your data flows directly to your personal API console, completely bypassing our servers.
        </p>
      </div>

      <!-- Card 3: Encryption & Local Search -->
      <div class="p-8 rounded-3xl bg-white/10 dark:bg-white/5 backdrop-blur-sm border border-white/20 dark:border-white/10 hover:border-emerald-500/30 transition-transform duration-200 group hover:-translate-y-1 shadow-lg" style="contain: layout style paint;">
        <div class="w-12 h-12 rounded-2xl bg-emerald-500/10 flex items-center justify-center text-emerald-400 mb-6 group-hover:scale-110 transition-transform duration-300">
          <Icon name="Lock" size={24} />
        </div>
        <h3 class="text-xl font-medium font-display text-visir-text mb-4">End-to-End Encryption</h3>
        <p class="text-visir-text-muted font-light text-sm leading-relaxed mb-4">
          Any task created in Visir is fully encrypted before it hits our database. We physically cannot read your tasks.
        </p>
        <p class="text-visir-text-muted font-light text-sm leading-relaxed border-t border-white/5 pt-4">
          <span class="text-emerald-400 font-medium">Local Search:</span> We don't do server-side text search. We lazy-load your encrypted data by date and search securely on your local machine.
        </p>
      </div>
    </div>
  </div>
</section>
