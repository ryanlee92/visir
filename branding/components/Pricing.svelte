<script lang="ts">
  import Icon from './Icon.svelte';
</script>

<section class="py-12 relative">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="text-center mb-16">
      <h2 class="text-3xl md:text-5xl font-semibold font-display text-visir-text mb-6">
        Simple pricing <br />
        <span class="text-visir-text-muted">for maximum productivity.</span>
      </h2>
      <p class="text-lg text-visir-text-muted font-light">
        Start your 7-day free trial today. Cancel anytime.
      </p>
    </div>

    <div class="grid md:grid-cols-2 gap-8 max-w-4xl mx-auto">
      <!-- Pro Plan -->
      <div class="p-8 rounded-3xl bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 flex flex-col hover:border-white/30 dark:hover:border-white/20 transition-colors shadow-lg">
        <div class="mb-8">
          <h3 class="text-2xl font-semibold font-display text-visir-primary mb-2">Pro Plan</h3>
          <div class="flex items-baseline gap-1">
            <span class="text-4xl font-semibold text-visir-text">$14</span>
            <span class="text-visir-text-muted font-light">/month</span>
          </div>
          <p class="text-visir-text-muted font-light text-sm mt-2">Billed monthly</p>
        </div>
        
        <ul class="space-y-5 mb-8 flex-1">
          <li class="flex items-start gap-3 text-visir-text font-light">
            <div class="p-0.5 rounded-full bg-orange-500/10 text-orange-500 mt-0.5"><Icon name="CheckCircle2" size={16} /></div>
            <span>Unlimited integrations</span>
          </li>
          <li class="flex items-start gap-3 text-visir-text font-light">
            <div class="p-0.5 rounded-full bg-orange-500/10 text-orange-500 mt-0.5"><Icon name="CheckCircle2" size={16} /></div>
            <span>AI-based inbox suggestions</span>
          </li>
          <li class="flex items-start gap-3 text-visir-text font-light">
            <div class="p-0.5 rounded-full bg-orange-500/10 text-orange-500 mt-0.5"><Icon name="CheckCircle2" size={16} /></div>
            <span>Smart schedule insights</span>
          </li>
        </ul>
      </div>

      <!-- Ultra Plan -->
      <div class="p-8 rounded-3xl bg-visir-surface/10 backdrop-blur-xl border border-visir-primary/30 relative flex flex-col shadow-2xl shadow-visir-primary/5 hover:border-visir-primary/50 transition-colors group">
        <!-- Glow Effect -->
        <div class="absolute inset-0 bg-visir-primary/5 rounded-3xl blur-xl group-hover:bg-visir-primary/10 transition-colors pointer-events-none"></div>
        
        <div class="relative z-10 mb-8">
          <div class="flex justify-between items-start">
            <h3 class="text-2xl font-semibold font-display text-visir-primary mb-2">Ultra Plan</h3>
            <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full bg-visir-primary/20 text-visir-primary text-[10px] font-bold uppercase tracking-wider border border-visir-primary/20">
              <Icon name="Sparkles" size={10} /> Recommended
            </span>
          </div>
          <div class="flex items-baseline gap-1">
            <span class="text-4xl font-semibold text-visir-text">$24</span>
            <span class="text-visir-text-muted font-light">/month</span>
          </div>
          <p class="text-visir-text-muted font-light text-sm mt-2">Billed monthly</p>
        </div>

        <ul class="space-y-5 mb-8 flex-1 relative z-10">
          <li class="flex items-start gap-3 text-visir-text font-light">
            <div class="p-0.5 rounded-full bg-orange-500/10 text-orange-500 mt-0.5"><Icon name="CheckCircle2" size={16} /></div>
            <span>All features in Pro</span>
          </li>
          <li class="flex items-start gap-3 text-visir-text font-light">
            <div class="p-0.5 rounded-full bg-orange-500/10 text-orange-500 mt-0.5"><Icon name="CheckCircle2" size={16} /></div>
            <span>500K AI tokens monthly for AI-powered summaries and insights</span>
          </li>
          <li class="flex items-start gap-3 text-visir-text font-light">
            <div class="p-0.5 rounded-full bg-orange-500/10 text-orange-500 mt-0.5"><Icon name="CheckCircle2" size={16} /></div>
            <span>Priority support</span>
          </li>
        </ul>
      </div>
    </div>
  </div>
</section>
