import { writable } from 'svelte/store';

// Router store
export const location = writable(window.location.pathname);
export const params = writable<Record<string, string>>({});

// Navigate function
export function navigate(path: string) {
  window.history.pushState({}, '', path);
  location.set(path);
}

// Link action for Svelte
export function link(node: HTMLAnchorElement) {
  function handleClick(e: MouseEvent) {
    const href = node.getAttribute('href');
    if (href && href.startsWith('/') && !href.startsWith('/#')) {
      e.preventDefault();
      navigate(href);
    }
  }

  node.addEventListener('click', handleClick);

  return {
    destroy() {
      node.removeEventListener('click', handleClick);
    }
  };
}

// Initialize router
if (typeof window !== 'undefined') {
  window.addEventListener('popstate', () => {
    location.set(window.location.pathname);
  });
}
