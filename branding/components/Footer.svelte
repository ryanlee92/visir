<script lang="ts">
  import { link, location } from '../lib/router';

  $: currentLocation = $location;

  function handleHashClick(e: MouseEvent, href: string) {
    if (href.startsWith('/#')) {
      const hash = href.replace('/', '');
      if (currentLocation !== '/') {
        e.preventDefault();
        window.location.href = href;
      } else {
        e.preventDefault();
        const element = document.getElementById(hash.replace('#', ''));
        if (element) {
          // Use requestAnimationFrame to batch DOM reads and avoid forced reflow
          requestAnimationFrame(() => {
            const offset = 100;
            const elementPosition = element.getBoundingClientRect().top;
            const offsetPosition = elementPosition + window.pageYOffset - offset;
            window.scrollTo({
              top: offsetPosition,
              behavior: 'smooth'
            });
          });
        }
      }
    }
  }
</script>

<footer class="relative z-50 bg-visir-bg border-t border-visir-outline/20 pt-20 pb-10">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="flex flex-col md:flex-row gap-8 md:gap-12 mb-16">
      <!-- Brand Column -->
      <div class="flex-shrink-0 pr-8">
        <div class="flex items-center gap-2 mb-6">
          <img 
            src="/assets/visir/visir_foreground-32.webp" 
            alt="Visir Logo" 
            class="h-8 w-8 object-contain"
            sizes="32px"
            loading="lazy"
            decoding="async"
          />
          <span class="text-2xl font-semibold font-cookie text-visir-text">Visir</span>
        </div>
        <p class="text-visir-text-muted text-sm leading-relaxed mb-6 font-sans font-light max-w-sm">
          The command center for high-performance professionals. Visir consolidates your tools into a single, intelligent timeline.
        </p>
        <!-- Social links commented out
        <div class="flex gap-4">
          <a href="https://twitter.com" target="_blank" rel="noopener noreferrer" aria-label="Twitter" class="w-8 h-8 flex items-center justify-center rounded-full bg-visir-surface/50 text-visir-text-muted hover:text-visir-primary hover:bg-visir-surface transition-colors duration-200">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
              <path d="M23 3a10.9 10.9 0 01-3.14 1.53 4.48 4.48 0 00-7.86 3v1A10.66 10.66 0 013 4s-4 9 5 13a11.64 11.64 0 01-7 2c9 5 20 0 20-11.5a4.5 4.5 0 00-.08-.83A7.72 7.72 0 0023 3z"/>
            </svg>
          </a>
          <a href="https://github.com" target="_blank" rel="noopener noreferrer" aria-label="GitHub" class="w-8 h-8 flex items-center justify-center rounded-full bg-visir-surface/50 text-visir-text-muted hover:text-visir-text hover:bg-visir-surface transition-all">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
              <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
            </svg>
          </a>
          <a href="https://linkedin.com" target="_blank" rel="noopener noreferrer" aria-label="LinkedIn" class="w-8 h-8 flex items-center justify-center rounded-full bg-visir-surface/50 text-visir-text-muted hover:text-blue-500 hover:bg-visir-surface transition-colors duration-200">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
              <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/>
            </svg>
          </a>
          <a href="https://instagram.com" target="_blank" rel="noopener noreferrer" aria-label="Instagram" class="w-8 h-8 flex items-center justify-center rounded-full bg-visir-surface/50 text-visir-text-muted hover:text-pink-500 hover:bg-visir-surface transition-colors duration-200">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
              <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/>
            </svg>
          </a>
        </div>
        -->
      </div>
      
      <!-- Link Columns - Right Aligned -->
      <div class="flex flex-wrap gap-8 md:gap-12 md:ml-auto">
        <div>
          <h3 class="text-visir-text font-semibold mb-4 font-display">Product</h3>
          <ul class="space-y-3 text-sm text-visir-text-muted font-sans font-light">
            <li><a href="/#features" use:link on:click={(e) => handleHashClick(e, '/#features')} class="hover:text-visir-primary transition-colors">Features</a></li>
            <li><a href="/integrations" use:link class="hover:text-visir-primary transition-colors">Integrations</a></li>
            <li><a href="/pricing" use:link class="hover:text-visir-primary transition-colors">Pricing</a></li>
            <li><a href="/download" use:link class="hover:text-visir-primary transition-colors">Download</a></li>
            <li><a href="/changelog" use:link class="hover:text-visir-primary transition-colors">Changelog</a></li>
            <li><a href="/roadmap" use:link class="hover:text-visir-primary transition-colors">Roadmap</a></li>
          </ul>
        </div>

        <div>
          <h3 class="text-visir-text font-semibold mb-4 font-display">Resources</h3>
          <ul class="space-y-3 text-sm text-visir-text-muted font-sans font-light">
            <li><a href="/blog" use:link class="hover:text-visir-primary transition-colors">Blog</a></li>
            <!-- <li><a href="/community" use:link class="hover:text-visir-primary transition-colors">Community</a></li> -->
            <li><a href="/help" use:link class="hover:text-visir-primary transition-colors">Help Center</a></li>
          </ul>
        </div>

        <div>
          <h3 class="text-visir-text font-semibold mb-4 font-display">Use Cases</h3>
          <ul class="space-y-3 text-sm text-visir-text-muted font-sans font-light">
            <li><a href="/founders" use:link class="hover:text-visir-primary transition-colors">For Executives</a></li>
            <li><a href="/developers" use:link class="hover:text-visir-primary transition-colors">For Product Managers</a></li>
            <li><a href="/managers" use:link class="hover:text-visir-primary transition-colors">For Engineers</a></li>
            <li><a href="/personal" use:link class="hover:text-visir-primary transition-colors">For Freelancers</a></li>
          </ul>
        </div>
      </div>
    </div>
    
    <div class="border-t border-visir-outline/20 pt-8 flex flex-col md:flex-row justify-between items-center gap-4">
      <p class="text-visir-text-muted text-sm font-sans font-light">
        © {new Date().getFullYear()} Wave Corporation. All rights reserved.
      </p>
      <div class="flex gap-6 text-sm text-visir-text-muted font-sans font-light">
        <a href="/privacy" use:link class="flex items-center gap-1.5 hover:text-visir-text transition-colors">
          Privacy Policy
        </a>
        <a href="/terms" use:link class="flex items-center gap-1.5 hover:text-visir-text transition-colors">
          Terms of Service
        </a>
      </div>
    </div>
  </div>
</footer>
