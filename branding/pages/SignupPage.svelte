<script lang="ts">
  import { link } from '../lib/router';
  import Icon from '../components/Icon.svelte';
  import Button from '../components/Button.svelte';
</script>

<div class="pt-24 min-h-screen flex items-center justify-center p-4">
  <div class="w-full max-w-md relative">
    <!-- Card -->
    <div class="bg-visir-surface/10 backdrop-blur-xl border border-white/10 rounded-3xl p-8 shadow-2xl">
      <div class="text-center mb-8">
        <h1 class="text-2xl font-semibold font-display text-visir-text mb-2">Create your account</h1>
        <p class="text-visir-text-muted text-sm">Join thousands of high-performers on Visir.</p>
      </div>

      <form class="space-y-4">
        <div>
          <label class="block text-xs font-medium text-visir-text-muted mb-1.5 ml-1">Full Name</label>
          <div class="relative">
            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-visir-text-muted">
              <Icon name="User" size={16} />
            </div>
            <input 
              type="text" 
              class="block w-full pl-10 pr-3 py-2.5 bg-visir-bg/50 border border-visir-outline/30 rounded-xl text-visir-text placeholder-visir-text-muted/50 focus:outline-none focus:ring-2 focus:ring-visir-primary/50 focus:border-visir-primary/50 transition-all text-sm"
              placeholder="John Doe"
            />
          </div>
        </div>

        <div>
          <label class="block text-xs font-medium text-visir-text-muted mb-1.5 ml-1">Email Address</label>
          <div class="relative">
            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-visir-text-muted">
              <Icon name="Mail" size={16} />
            </div>
            <input 
              type="email" 
              class="block w-full pl-10 pr-3 py-2.5 bg-visir-bg/50 border border-visir-outline/30 rounded-xl text-visir-text placeholder-visir-text-muted/50 focus:outline-none focus:ring-2 focus:ring-visir-primary/50 focus:border-visir-primary/50 transition-all text-sm"
              placeholder="you@company.com"
            />
          </div>
        </div>
        
        <div>
          <label class="block text-xs font-medium text-visir-text-muted mb-1.5 ml-1">Password</label>
          <div class="relative">
            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-visir-text-muted">
              <Icon name="Lock" size={16} />
            </div>
            <input 
              type="password" 
              class="block w-full pl-10 pr-3 py-2.5 bg-visir-bg/50 border border-visir-outline/30 rounded-xl text-visir-text placeholder-visir-text-muted/50 focus:outline-none focus:ring-2 focus:ring-visir-primary/50 focus:border-visir-primary/50 transition-all text-sm"
              placeholder="••••••••"
            />
          </div>
        </div>

        <Button variant="primary" className="w-full gap-2 mt-2">
          Create Account <Icon name="ArrowRight" size={16} />
        </Button>
      </form>

      <div class="mt-6 text-center">
        <p class="text-sm text-visir-text-muted">
          Already have an account? 
          <a href="/login" use:link class="text-visir-primary hover:underline font-medium ml-1">Sign in</a>
        </p>
      </div>
    </div>
  </div>
</div>
