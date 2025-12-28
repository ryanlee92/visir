// Analytics utilities for GA4

declare global {
  interface Window {
    dataLayer: any[];
    gtag: (...args: any[]) => void;
  }
}

// Initialize dataLayer for GA4
export function initDataLayer() {
  if (typeof window !== 'undefined' && !window.dataLayer) {
    window.dataLayer = window.dataLayer || [];
  }
}

// Track page view for GA4
export function trackPageView(path: string, title?: string) {
  if (typeof window === 'undefined') return;
  
  initDataLayer();
  
  const ga4Id = import.meta.env.VITE_GA4_ID;
  
  if (!ga4Id) {
    return;
  }
  
  // Check if gtag is available
  if (!window.gtag) {
    setTimeout(() => trackPageView(path, title), 100);
    return;
  }
  
  // GA4 page view - send both event and config update
  try {
    // Send page_view event (recommended for GA4)
    window.gtag('event', 'page_view', {
      page_path: path,
      page_title: title || document.title,
    });
    
    // Also update config for SPA navigation tracking
    window.gtag('config', ga4Id, {
      page_path: path,
      page_title: title || document.title,
      send_page_view: true,
    });
  } catch (error) {
    // Silent fail
  }
}

// Track custom event
export function trackEvent(
  eventName: string,
  eventParams?: Record<string, any>
) {
  if (typeof window === 'undefined') return;
  
  initDataLayer();
  
  // GA4 event
  if (window.gtag) {
    window.gtag('event', eventName, eventParams || {});
  }
}

// Track button click
export function trackButtonClick(buttonName: string, location?: string) {
  trackEvent('button_click', {
    button_name: buttonName,
    location: location || window.location.pathname,
  });
}

// Track link click
export function trackLinkClick(linkUrl: string, linkText?: string) {
  trackEvent('link_click', {
    link_url: linkUrl,
    link_text: linkText,
    location: window.location.pathname,
  });
}

// Track download
export function trackDownload(platform: string) {
  trackEvent('download', {
    platform,
    location: window.location.pathname,
  });
}

// Track signup
export function trackSignup(method: string) {
  trackEvent('signup', {
    method,
    location: window.location.pathname,
  });
}

// Track CTA click
export function trackCTA(ctaName: string, location?: string) {
  trackEvent('cta_click', {
    cta_name: ctaName,
    location: location || window.location.pathname,
  });
}

// Set user properties
export function setUserProperties(properties: Record<string, any>) {
  if (typeof window === 'undefined') return;
  
  // GA4 user properties
  if (window.gtag) {
    window.gtag('set', 'user_properties', properties);
  }
}

// Identify user
export function identifyUser(userId: string, traits?: Record<string, any>) {
  if (typeof window === 'undefined') return;
  
  const ga4Id = import.meta.env.VITE_GA4_ID;
  
  // GA4 user ID
  if (window.gtag && ga4Id) {
    window.gtag('config', ga4Id, {
      user_id: userId,
      ...(traits && { user_properties: traits }),
    });
  }
}

