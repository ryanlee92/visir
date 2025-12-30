<script lang="ts">
  import { onMount } from 'svelte';
  import { location, params } from './lib/router';
  import Navbar from './components/Navbar.svelte';
  import Footer from './components/Footer.svelte';
  import MeshBackground from './components/MeshBackground.svelte';
  import LandingPage from './pages/LandingPage.svelte';
  import { getSEOForRoute, updateMetaTags, generateAllStructuredData } from './lib/seo';
import { trackPageView, initDataLayer } from './lib/analytics';
import { initAnalytics } from './lib/init-analytics';
  
  // Lazy load pages
  const PricingPage = () => import('./pages/PricingPage.svelte');
  const DownloadPage = () => import('./pages/DownloadPage.svelte');
  const BlogPage = () => import('./pages/BlogPage.svelte');
  const BlogPostPage = () => import('./pages/BlogPostPage.svelte');
  const LoginPage = () => import('./pages/LoginPage.svelte');
  const SignupPage = () => import('./pages/SignupPage.svelte');
  const ForFounders = () => import('./pages/ForFounders.svelte');
  const ForDevelopers = () => import('./pages/ForDevelopers.svelte');
  const ForManagers = () => import('./pages/ForManagers.svelte');
  const ForPersonalUse = () => import('./pages/ForPersonalUse.svelte');
  const CommunityPage = () => import('./pages/CommunityPage.svelte');
  const HelpCenterPage = () => import('./pages/HelpCenterPage.svelte');
  const ChangelogPage = () => import('./pages/ChangelogPage.svelte');
  const RoadmapPage = () => import('./pages/RoadmapPage.svelte');
  const FeatureRequestsPage = () => import('./pages/FeatureRequestsPage.svelte');
  const PrivacyPage = () => import('./pages/PrivacyPage.svelte');
  const TermsOfServicePage = () => import('./pages/TermsOfServicePage.svelte');
  const IntegrationsPage = () => import('./pages/IntegrationsPage.svelte');
  const IntegrationPage = () => import('./pages/IntegrationPage.svelte');
  const IntegrationFailedPage = () => import('./pages/IntegrationFailedPage.svelte');

  // Route definitions
  const routes: Record<string, any> = {
    '/': LandingPage,
    '/pricing': PricingPage,
    '/download': DownloadPage,
    '/blog': BlogPage,
    '/blog/:slug': BlogPostPage,
    '/login': LoginPage,
    '/signup': SignupPage,
    '/founders': ForFounders,
    '/developers': ForDevelopers,
    '/managers': ForManagers,
    '/personal': ForPersonalUse,
    '/community': CommunityPage,
    '/help': HelpCenterPage,
    '/changelog': ChangelogPage,
    '/roadmap': RoadmapPage,
    '/feature-requests': FeatureRequestsPage,
    '/privacy': PrivacyPage,
    '/terms': TermsOfServicePage,
    '/integrations': IntegrationsPage,
    '/integration': IntegrationPage,
    '/integration/failed': IntegrationFailedPage,
  };

  // Match route with params
  function matchRoute(path: string): { component: any; params: Record<string, string> } | null {
    // Exact match
    if (routes[path]) {
      return { component: routes[path], params: {} };
    }

    // Try to match with params (e.g., /blog/:slug)
    for (const [route, component] of Object.entries(routes)) {
      if (route.includes(':')) {
        const routeParts = route.split('/');
        const pathParts = path.split('/');
        
        if (routeParts.length === pathParts.length) {
          const matchedParams: Record<string, string> = {};
          let matches = true;
          
          for (let i = 0; i < routeParts.length; i++) {
            if (routeParts[i].startsWith(':')) {
              matchedParams[routeParts[i].slice(1)] = pathParts[i];
            } else if (routeParts[i] !== pathParts[i]) {
              matches = false;
              break;
            }
          }
          
          if (matches) {
            return { component, params: matchedParams };
          }
        }
      }
    }

    return null;
  }

  let currentComponent: any = LandingPage;
  let currentParams: Record<string, string> = {};
  let loading = false;
  let previousPath = '';

  function isLazyComponent(component: any): boolean {
    // Check if it's a lazy loaded component (dynamic import function)
    // Lazy components are arrow functions that return import()
    // Direct imports are Svelte component classes
    if (typeof component !== 'function') return false;
    
    // Check function source code for dynamic import pattern
    const funcStr = component.toString();
    const isDynamicImport = funcStr.includes('import(') && funcStr.includes('return');
    
    // Also check if it's one of our known lazy components
    const lazyComponents = [PricingPage, DownloadPage, BlogPage, BlogPostPage, LoginPage, SignupPage, 
                           ForFounders, ForDevelopers, ForManagers, ForPersonalUse, 
                           CommunityPage, HelpCenterPage, ChangelogPage, RoadmapPage, 
                           FeatureRequestsPage, PrivacyPage, TermsOfServicePage, IntegrationsPage,
                           IntegrationPage, IntegrationFailedPage];
    
    return lazyComponents.includes(component) || isDynamicImport;
  }

  async function loadComponent(match: { component: any; params: Record<string, string> }, shouldScrollToTop: boolean = false) {
    if (isLazyComponent(match.component)) {
      // Lazy loaded component (dynamic import)
      loading = true;
      try {
        const module = await match.component();
        currentComponent = module.default;
        currentParams = match.params;
        params.set(match.params);
        if (shouldScrollToTop) {
          requestAnimationFrame(() => {
            document.documentElement.style.scrollBehavior = 'auto';
            document.documentElement.scrollTop = 0;
            document.body.scrollTop = 0;
            document.documentElement.style.scrollBehavior = '';
          });
        }
      } catch (error) {
        console.error('Failed to load component:', error);
        currentComponent = LandingPage;
        currentParams = {};
        params.set({});
        if (shouldScrollToTop) {
          requestAnimationFrame(() => {
            document.documentElement.style.scrollBehavior = 'auto';
            document.documentElement.scrollTop = 0;
            document.body.scrollTop = 0;
            document.documentElement.style.scrollBehavior = '';
          });
        }
      } finally {
        loading = false;
      }
    } else {
      // Direct import component
      currentComponent = match.component;
      currentParams = match.params;
      params.set(match.params);
      if (shouldScrollToTop) {
        // Use setTimeout to ensure DOM is updated
        setTimeout(() => {
          document.documentElement.style.scrollBehavior = 'auto';
          document.documentElement.scrollTop = 0;
          document.body.scrollTop = 0;
          window.scrollTo(0, 0);
          document.documentElement.style.scrollBehavior = '';
        }, 0);
      }
    }
  }

  function handleRouteChange(path: string) {
    console.log('Route changed to:', path);
    const match = matchRoute(path);
    console.log('Route match:', match);
    
    // Check if path actually changed (not just hash change)
    const pathWithoutHash = path.split('#')[0];
    const pathChanged = previousPath !== pathWithoutHash;
    const shouldScrollToTop = pathChanged && !window.location.hash;
    previousPath = pathWithoutHash;
    
    // Update SEO meta tags
    if (pathChanged) {
      const seoData = getSEOForRoute(pathWithoutHash, $params);
      updateMetaTags(seoData);
      
      // Track page view
      trackPageView(pathWithoutHash, seoData.title);
      
      // Update structured data (remove all existing JSON-LD scripts)
      const existingStructuredData = document.querySelectorAll('script[type="application/ld+json"]');
      existingStructuredData.forEach(script => script.remove());
      
      // Generate all structured data (main + breadcrumbs + howto, etc.)
      const structuredDataList = generateAllStructuredData(seoData, pathWithoutHash);
      structuredDataList.forEach(data => {
        const script = document.createElement('script');
        script.type = 'application/ld+json';
        script.textContent = JSON.stringify(data);
        document.head.appendChild(script);
      });
    }
    
    if (match) {
      loadComponent(match, shouldScrollToTop);
    } else {
      console.log('No match found, defaulting to landing page');
      currentComponent = LandingPage;
      currentParams = {};
      params.set({});
      if (shouldScrollToTop) {
        requestAnimationFrame(() => {
          document.documentElement.style.scrollBehavior = 'auto';
          document.documentElement.scrollTop = 0;
          document.body.scrollTop = 0;
          document.documentElement.style.scrollBehavior = '';
        });
      }
    }
  }

  // Reactive statement for route changes
  $: handleRouteChange($location);

  // Handle hash scrolling
  function handleHashChange() {
    const hash = window.location.hash;
    if (hash) {
      setTimeout(() => {
        const element = document.getElementById(hash.replace('#', ''));
        if (element) {
          const offset = 100;
          const elementPosition = element.getBoundingClientRect().top;
          const offsetPosition = elementPosition + window.pageYOffset - offset;
          window.scrollTo({
            top: offsetPosition,
            behavior: 'smooth'
          });
        }
      }, 100);
    }
  }

  onMount(async () => {
    // Initialize analytics scripts
    try {
      await initAnalytics();
    } catch (error) {
      // Silent fail
    }
    initDataLayer();
    
    // Initialize previous path
    previousPath = window.location.pathname;
    
    // Ensure location store is initialized
    if ($location !== window.location.pathname) {
      location.set(window.location.pathname);
    }
    
    // Initial SEO setup
    const initialSEO = getSEOForRoute(window.location.pathname, {});
    updateMetaTags(initialSEO);
    
    // Track initial page view after GA4 is ready
    // Wait a bit to ensure GA4 script is fully loaded
    setTimeout(() => {
      trackPageView(window.location.pathname, initialSEO.title);
    }, 500);
    
    // Initial structured data
    const initialStructuredDataList = generateAllStructuredData(initialSEO, window.location.pathname);
    initialStructuredDataList.forEach(data => {
      const script = document.createElement('script');
      script.type = 'application/ld+json';
      script.textContent = JSON.stringify(data);
      document.head.appendChild(script);
    });
    
    // Initial route will be handled by reactive statement
    // But we can also handle it here for immediate load
    handleRouteChange(window.location.pathname);

    // Initial hash check
    handleHashChange();

    // Listen for hash changes
    window.addEventListener('hashchange', handleHashChange);

    return () => {
      window.removeEventListener('hashchange', handleHashChange);
    };
  });
</script>

<div class="min-h-screen text-visir-text relative">
  <MeshBackground />
  <Navbar />
  <main class="relative z-10">
    {#if loading}
      <div class="flex items-center justify-center min-h-screen">
        <div class="text-visir-text-muted">Loading...</div>
      </div>
    {:else if currentComponent}
      <svelte:component this={currentComponent} params={currentParams} />
    {/if}
  </main>
  <Footer />
</div>
