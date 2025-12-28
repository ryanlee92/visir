<script lang="ts">
  import { onMount } from 'svelte';
  import { link } from '../lib/router';
  import Button from './Button.svelte';
  import { createScrollAnimation } from '../lib/animations';

  let sectionElement: HTMLElement;
  let contentElement: HTMLElement;

  onMount(() => {
    if (sectionElement) {
      createScrollAnimation(sectionElement, {
        threshold: 0.1,
        rootMargin: '0px 0px -100px 0px',
        once: true,
      });
    }

    if (contentElement) {
      createScrollAnimation(contentElement, {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px',
        once: true,
      });
    }
  });
</script>

<section class="py-24 relative overflow-hidden animate-ready" bind:this={sectionElement}>
  <!-- Background Gradients -->
  <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-visir-primary/10 rounded-full blur-[120px] pointer-events-none"></div>

  <div class="max-w-4xl mx-auto px-4 relative z-10 text-center animate-ready" bind:this={contentElement}>
    <h2 class="text-4xl md:text-5xl font-semibold font-display text-visir-text mb-6 tracking-tight">
      Ready to upgrade?<br/>
      Experience a <span class="text-visir-primary">new dimension</span> of productivity.
    </h2>
    <p class="text-xl text-visir-text-muted mb-10 font-sans font-light">
      Reclaim 2 hours of your week with Visir.
      Start now without any complex setup.
    </p>
    <div class="flex flex-col sm:flex-row gap-4 justify-center">
      <a href="/download" use:link>
        <Button size="lg" className="px-10 py-4 text-lg shadow-visir-primary/30 shadow-xl font-display font-medium">Get Started Free</Button>
      </a>
      <a href="/pricing" use:link>
        <Button variant="outline" size="lg" className="px-10 py-4 text-lg font-display font-medium">View Pricing</Button>
      </a>
    </div>
    <p class="mt-6 text-sm text-visir-text-muted font-sans font-light">
      No credit card required · 7-day free trial · Cancel anytime
    </p>
  </div>
</section>
