// Initialize Google Analytics 4 script dynamically
// Load GA4 without Partytown to avoid compatibility issues

let ga4Ready = false;
const ga4ReadyCallbacks: (() => void)[] = [];

export function onGA4Ready(callback: () => void) {
  if (ga4Ready) {
    callback();
  } else {
    ga4ReadyCallbacks.push(callback);
  }
}

export function initAnalytics(): Promise<void> {
  return new Promise((resolve, reject) => {
    if (typeof window === 'undefined') {
      resolve();
      return;
    }
    
    const ga4Id = import.meta.env.VITE_GA4_ID;
    
    if (!ga4Id) {
      resolve();
      return;
    }
    
    // Initialize GA4
    // Initialize dataLayer first
    window.dataLayer = window.dataLayer || [];
    
    // Define gtag function
    function gtag(...args: any[]) {
      window.dataLayer.push(args);
    }
    window.gtag = gtag;
    
    // Load GA4 initialization script
    const script = document.createElement('script');
    script.textContent = `
      window.dataLayer = window.dataLayer || [];
      function gtag(){dataLayer.push(arguments);}
      gtag('js', new Date());
      gtag('config', '${ga4Id}', {
        'send_page_view': false
      });
    `;
    document.head.appendChild(script);
    
    // Load GA4 library
    const gaScript = document.createElement('script');
    gaScript.src = `https://www.googletagmanager.com/gtag/js?id=${ga4Id}`;
    gaScript.async = true;
    gaScript.onload = () => {
      ga4Ready = true;
      // Execute all pending callbacks
      ga4ReadyCallbacks.forEach(callback => callback());
      ga4ReadyCallbacks.length = 0;
      resolve();
    };
    gaScript.onerror = () => {
      reject(new Error('Failed to load GA4 script'));
    };
    document.head.appendChild(gaScript);
  });
}

