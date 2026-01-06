// Dropbox-style animation utilities
export interface ScrollAnimationOptions {
  threshold?: number;
  rootMargin?: string;
  once?: boolean;
}

export function createScrollAnimation(
  element: HTMLElement,
  options: ScrollAnimationOptions = {}
): () => void {
  const {
    threshold = 0.1,
    rootMargin = '0px 0px -100px 0px',
    once = true,
  } = options;

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('animate-in');
          entry.target.classList.remove('animate-out');
          
          if (once) {
            observer.unobserve(entry.target);
          }
        } else if (!once) {
          entry.target.classList.add('animate-out');
          entry.target.classList.remove('animate-in');
        }
      });
    },
    {
      threshold,
      rootMargin,
    }
  );

  element.classList.add('animate-ready');
  observer.observe(element);

  return () => {
    observer.disconnect();
  };
}

export function createParallaxEffect(
  element: HTMLElement,
  speed: number = 0.5
): () => void {
  let ticking = false;

  function updateParallax() {
    const rect = element.getBoundingClientRect();
    const scrolled = window.pageYOffset;
    const rate = scrolled * speed;
    
    element.style.transform = `translate3d(0, ${rate}px, 0)`;
    ticking = false;
  }

  function onScroll() {
    if (!ticking) {
      window.requestAnimationFrame(updateParallax);
      ticking = true;
    }
  }

  window.addEventListener('scroll', onScroll, { passive: true });
  
  // Initial update (deferred to avoid forced reflow on mount)
  requestAnimationFrame(updateParallax);

  return () => {
    window.removeEventListener('scroll', onScroll);
  };
}

export function createStaggerAnimation(
  elements: HTMLElement[],
  delay: number = 100
): () => void {
  const cleanupFunctions: (() => void)[] = [];

  elements.forEach((element, index) => {
    const cleanup = createScrollAnimation(element, {
      threshold: 0.1,
      rootMargin: '0px 0px -50px 0px',
      once: true,
    });
    
    element.style.setProperty('--stagger-delay', `${index * delay}ms`);
    cleanupFunctions.push(cleanup);
  });

  return () => {
    cleanupFunctions.forEach((cleanup) => cleanup());
  };
}

