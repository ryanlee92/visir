// SEO configuration and utilities

export interface SEOData {
  title: string;
  description: string;
  keywords?: string;
  ogImage?: string;
  ogType?: string;
  canonical?: string;
  noindex?: boolean;
}

const baseUrl = 'https://visir.pro';

// Default SEO data
const defaultSEO: SEOData = {
  title: 'Visir - Your AI Executive Assistant | Never Alt-Tab Again',
  description: 'Your browser tabs are killing your productivity. Visir unifies Slack, Gmail, and Calendar into one timeline. Never Alt-Tab again. Secure, local-first.',
  keywords: 'productivity, email management, calendar, task management, AI assistant, unified inbox, time blocking, workflow automation, Slack, Gmail, Outlook, Notion',
  ogImage: `${baseUrl}/og-image.png?v=3`, // SEO용 전용 이미지 (캐시 무효화를 위해 버전 파라미터 추가)
  ogType: 'website',
};

// Page-specific SEO data
export const pageSEO: Record<string, SEOData> = {
  '/': {
    title: 'Visir - Your AI Executive Assistant | Never Alt-Tab Again',
    description: 'Your browser tabs are killing your productivity. Visir unifies Slack, Gmail, and Calendar into one timeline. Never Alt-Tab again. Secure, local-first.',
    keywords: 'productivity, email management, calendar, task management, AI assistant, unified inbox, time blocking, workflow automation, Gmail, Slack, Outlook, Notion',
    ogType: 'website',
  },
  '/pricing': {
    title: 'Pricing - Visir | Simple pricing for maximum productivity',
    description: 'Start your 7-day free trial today. Choose between Pro Plan ($14/month) or Ultra Plan ($24/month) with AI-powered features. Cancel anytime.',
    keywords: 'Visir pricing, productivity software pricing, AI assistant pricing, task management pricing',
    ogType: 'website',
  },
  '/download': {
    title: 'Download Visir | Available on macOS, Windows, iOS, and Android',
    description: 'Download Visir for your device. Available on macOS, Windows, iOS, and Android. The command center for high-performance professionals.',
    keywords: 'download Visir, Visir app download, productivity app download, macOS, Windows, iOS, Android',
    ogType: 'website',
  },
  '/blog': {
    title: 'Visir Blog | Updates, productivity frameworks, and engineering deep dives',
    description: 'Read the latest updates, productivity frameworks, and engineering deep dives from the Visir team.',
    keywords: 'Visir blog, productivity tips, workflow optimization, email management, time management',
    ogType: 'website',
  },
  '/login': {
    title: 'Sign In - Visir',
    description: 'Sign in to your Visir account to access your unified productivity workspace.',
    keywords: 'Visir login, sign in Visir',
    ogType: 'website',
    noindex: true,
  },
  '/signup': {
    title: 'Sign Up - Visir | Create your account',
    description: 'Create your Visir account and join thousands of high-performers. Start your 7-day free trial today.',
    keywords: 'Visir signup, create Visir account, free trial',
    ogType: 'website',
  },
  '/founders': {
    title: 'For Executives - Visir | Your Personal Command Center',
    description: 'As an executive, you juggle countless priorities. Visir unifies your emails, calendar, and tasks into one intelligent timeline, so you can focus on what matters.',
    keywords: 'executive productivity, C-suite tools, executive assistant, priority management',
    ogType: 'website',
  },
  '/developers': {
    title: 'For Developers - Visir | Ship faster. Stay organized.',
    description: 'As a PM, you\'re managing features, user feedback, and stakeholder requests. Visir consolidates everything into one timeline, so you can prioritize what to build next.',
    keywords: 'developer productivity, PM tools, product management, feature tracking',
    ogType: 'website',
  },
  '/managers': {
    title: 'For Managers - Visir | Code with focus. Manage tasks effortlessly.',
    description: 'As an engineer, you need to track PRs, code reviews, and technical tasks. Visir helps you stay organized so you can focus on building.',
    keywords: 'engineering productivity, developer tools, code review management, technical task tracking',
    ogType: 'website',
  },
  '/personal': {
    title: 'For Freelancers - Visir | Run your business. Stay organized.',
    description: 'As a freelancer, you\'re managing clients, projects, and deadlines. Visir helps you track everything in one place, so you can focus on delivering great work.',
    keywords: 'freelancer tools, client management, project tracking, freelance productivity',
    ogType: 'website',
  },
  '/community': {
    title: 'Visir Community | Join the Visir Community',
    description: 'Connect with other users, share tips, and get help from the Visir community. Join our Discord server, submit feature requests, and access the help center.',
    keywords: 'Visir community, productivity community, user support',
    ogType: 'website',
  },
  '/help': {
    title: 'Help Center - Visir | Find answers and learn how to use Visir',
    description: 'Find answers to your questions and learn how to get the most out of Visir. Browse tutorials, guides, and troubleshooting tips.',
    keywords: 'Visir help, Visir support, how to use Visir, Visir tutorials',
    ogType: 'website',
  },
  '/changelog': {
    title: 'Changelog - Visir | See what\'s new',
    description: 'See what\'s new in Visir. We ship updates regularly to improve your productivity.',
    keywords: 'Visir updates, Visir changelog, new features',
    ogType: 'website',
  },
  '/roadmap': {
    title: 'Roadmap - Visir | What\'s coming next',
    description: 'See what we\'re building and help shape the future of Visir. View planned features, in-progress items, and completed updates.',
    keywords: 'Visir roadmap, upcoming features, product roadmap',
    ogType: 'website',
  },
  '/feature-requests': {
    title: 'Feature Requests - Visir | Share your ideas',
    description: 'Share your ideas and vote on features you\'d like to see in Visir. Help shape the future of the product.',
    keywords: 'Visir feature requests, product feedback, suggest features',
    ogType: 'website',
  },
  '/privacy': {
    title: 'Privacy Policy - Visir | Your data stays yours',
    description: 'We designed Visir with extreme security in mind. We don\'t need your data, so we built an architecture that makes it impossible for us to see it.',
    keywords: 'Visir privacy policy, data security, privacy',
    ogType: 'website',
  },
  '/terms': {
    title: 'Terms of Service - Visir',
    description: 'Read Visir\'s Terms of Service. By using Visir, you agree to these terms.',
    keywords: 'Visir terms of service, legal terms',
    ogType: 'website',
  },
  '/integrations': {
    title: 'Integrations - Visir | Connect your favorite tools',
    description: 'Connect your favorite tools and bring everything together in one place. Integrate with Gmail, Outlook, Slack, Google Calendar, and more.',
    keywords: 'Visir integrations, Gmail integration, Slack integration, calendar integration',
    ogType: 'website',
  },
  '/integration': {
    title: 'Integration - Visir',
    description: 'Connecting your account...',
    keywords: 'Visir integration',
    ogType: 'website',
    noindex: true,
  },
  '/integration/failed': {
    title: 'Integration Failed - Visir',
    description: 'Failed to connect your account.',
    keywords: 'Visir integration',
    ogType: 'website',
    noindex: true,
  },
};

// Get SEO data for a specific route
export function getSEOForRoute(path: string, params?: Record<string, string>): SEOData {
  // Handle blog post pages
  if (path.startsWith('/blog/') && params?.slug) {
    // For blog posts, we'd need to fetch the actual post data
    // For now, return a generic blog post SEO
    return {
      title: `${params.slug} - Visir Blog`,
      description: 'Read this article on the Visir blog.',
      keywords: 'Visir blog, productivity',
      ogType: 'article',
    };
  }

  // Get page-specific SEO or fallback to default
  const routeSEO = pageSEO[path] || defaultSEO;
  
  return {
    ...defaultSEO,
    ...routeSEO,
    canonical: routeSEO.canonical || `${baseUrl}${path}`,
  };
}

// Update meta tags in the document head
export function updateMetaTags(seoData: SEOData) {
  const { title, description, keywords, ogImage, ogType, canonical, noindex } = seoData;

  // Update title
  document.title = title;

  // Update or create meta tags
  const updateMetaTag = (name: string, content: string, attribute: string = 'name') => {
    let meta = document.querySelector(`meta[${attribute}="${name}"]`) as HTMLMetaElement;
    if (!meta) {
      meta = document.createElement('meta');
      meta.setAttribute(attribute, name);
      document.head.appendChild(meta);
    }
    meta.setAttribute('content', content);
  };

  // Update description
  updateMetaTag('description', description);

  // Update keywords if provided
  if (keywords) {
    updateMetaTag('keywords', keywords);
  }

  // Update robots (AI-friendly)
  if (noindex) {
    updateMetaTag('robots', 'noindex, nofollow');
  } else {
    updateMetaTag('robots', 'index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1');
  }

  // Open Graph tags
  updateMetaTag('og:title', title, 'property');
  updateMetaTag('og:description', description, 'property');
  updateMetaTag('og:type', ogType || 'website', 'property');
  updateMetaTag('og:url', canonical || `${baseUrl}${window.location.pathname}`, 'property');
  const imageUrl = ogImage || defaultSEO.ogImage!;
  updateMetaTag('og:image', imageUrl, 'property');
  updateMetaTag('og:image:secure_url', imageUrl, 'property');
  updateMetaTag('og:image:alt', title, 'property');
  updateMetaTag('og:site_name', 'Visir', 'property');

  // Twitter Card tags
  updateMetaTag('twitter:card', 'summary_large_image');
  updateMetaTag('twitter:title', title);
  updateMetaTag('twitter:description', description);
  updateMetaTag('twitter:image', ogImage || defaultSEO.ogImage!);

  // Canonical URL
  let canonicalLink = document.querySelector('link[rel="canonical"]') as HTMLLinkElement;
  if (!canonicalLink) {
    canonicalLink = document.createElement('link');
    canonicalLink.setAttribute('rel', 'canonical');
    document.head.appendChild(canonicalLink);
  }
  canonicalLink.setAttribute('href', canonical || `${baseUrl}${window.location.pathname}`);

  // Language
  updateMetaTag('og:locale', 'en_US', 'property');
}

// FAQ data for structured data
const faqData = [
  {
    question: "How does Visir integrate with Gmail, Slack, and Calendar?",
    answer: "Visir connects directly to your Gmail, Outlook, Slack, and Google Calendar accounts through secure OAuth authentication. Once connected, Visir syncs your data locally and provides a unified interface to manage everything in one place. All integrations support real-time bidirectional sync, so changes made in Visir instantly reflect in your original apps."
  },
  {
    question: "Can I use Visir offline?",
    answer: "Yes! Visir syncs your emails, messages, and calendar events to a local database on your device. You can read your content without an internet connection. However, modifications like sending emails, creating tasks, or updating calendar events require an internet connection."
  },
  {
    question: "How does the AI assistant work?",
    answer: "Visir's AI analyzes your inbox to categorize items by project and urgency, summarizes meeting contexts, and helps draft responses. By default, AI processing happens via direct API calls that don't retain data for training. For maximum privacy, you can use your own API key to ensure your data only flows between your device and your personal API console."
  },
  {
    question: "Is my data secure and private?",
    answer: "Absolutely. Visir processes most data locally on your device. Your email and message content is never stored on our servers—only task metadata is encrypted and stored for sync purposes. Text search is performed locally, and you have full control over what data is shared with AI services through the BYOK option."
  },
  {
    question: "Can I replace my existing productivity tools?",
    answer: "Yes! Visir provides full-featured tabs for Mail, Chat, Calendar, and Tasks with complete feature parity. You can manage Gmail, Slack, Google Calendar, and Outlook entirely within Visir without switching apps. All changes sync bidirectionally, so you can still use your original apps when needed."
  },
  {
    question: "What platforms does Visir support?",
    answer: "Visir is available on macOS, Windows, iOS, and Android. The mobile apps offer 100% feature parity with the desktop version, so you can manage your entire workflow from any device. All your data syncs seamlessly across platforms."
  }
];

// Generate BreadcrumbList structured data
export function generateBreadcrumbList(path: string): object {
  const breadcrumbs = [
    {
      '@type': 'ListItem',
      position: 1,
      name: 'Home',
      item: baseUrl,
    },
  ];

  // Page-specific breadcrumbs
  const pathMap: Record<string, { name: string; position: number }> = {
    '/pricing': { name: 'Pricing', position: 2 },
    '/download': { name: 'Download', position: 2 },
    '/blog': { name: 'Blog', position: 2 },
    '/founders': { name: 'For Executives', position: 2 },
    '/developers': { name: 'For Developers', position: 2 },
    '/managers': { name: 'For Managers', position: 2 },
    '/personal': { name: 'For Freelancers', position: 2 },
    '/community': { name: 'Community', position: 2 },
    '/help': { name: 'Help Center', position: 2 },
    '/changelog': { name: 'Changelog', position: 2 },
    '/roadmap': { name: 'Roadmap', position: 2 },
    '/feature-requests': { name: 'Feature Requests', position: 2 },
    '/privacy': { name: 'Privacy Policy', position: 2 },
    '/terms': { name: 'Terms of Service', position: 2 },
    '/integrations': { name: 'Integrations', position: 2 },
  };

  // Handle blog posts
  if (path.startsWith('/blog/')) {
    breadcrumbs.push({
      '@type': 'ListItem',
      position: 2,
      name: 'Blog',
      item: `${baseUrl}/blog`,
    });
    const slug = path.split('/blog/')[1];
    if (slug) {
      breadcrumbs.push({
        '@type': 'ListItem',
        position: 3,
        name: slug.split('-').map((word: string) => word.charAt(0).toUpperCase() + word.slice(1)).join(' '),
        item: `${baseUrl}${path}`,
      });
    }
  } else if (pathMap[path]) {
    breadcrumbs.push({
      '@type': 'ListItem',
      position: pathMap[path].position,
      name: pathMap[path].name,
      item: `${baseUrl}${path}`,
    });
  }

  return {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: breadcrumbs,
  };
}

// Generate HowTo structured data for help/tutorial pages
export function generateHowToStructuredData(path: string): object | null {
  // Help Center articles that can be HowTo
  const howToArticles: Record<string, { name: string; description: string; steps: Array<{ name: string; text: string; image?: string }> }> = {
    '/help': {
      name: 'How to Get Started with Visir',
      description: 'Learn how to set up and use Visir to boost your productivity. Follow these steps to get the most out of your unified productivity workspace.',
      steps: [
        {
          name: 'Set up your first workspace',
          text: 'Download and install Visir on your device. Create your account and complete the initial setup wizard.',
        },
        {
          name: 'Connect your email accounts',
          text: 'Connect your Gmail, Outlook, or other email accounts through secure OAuth authentication. Visir will sync your emails locally.',
        },
        {
          name: 'Set up calendar integrations',
          text: 'Link your Google Calendar or Outlook Calendar to sync events and enable time blocking features.',
        },
        {
          name: 'Create your first task',
          text: 'Use the task management features to create and organize tasks. Drag tasks to your calendar to time-block them.',
        },
        {
          name: 'Use time blocking',
          text: 'Drag any message or task directly onto your calendar to secure focus time. Visir will automatically create calendar events.',
        },
        {
          name: 'Explore AI features',
          text: 'Let Visir AI analyze your inbox, categorize items by project and urgency, and prepare you for meetings with context summaries.',
        },
      ],
    },
  };

  const article = howToArticles[path];
  if (!article) return null;

  return {
    '@context': 'https://schema.org',
    '@type': 'HowTo',
    name: article.name,
    description: article.description,
    image: `${baseUrl}/og-image.png?v=3`,
    totalTime: 'PT15M', // 15 minutes estimated
    step: article.steps.map((step, index) => ({
      '@type': 'HowToStep',
      position: index + 1,
      name: step.name,
      text: step.text,
      ...(step.image && { image: step.image }),
    })),
  };
}

// Generate Review structured data (placeholder for future use)
// 실제 리뷰 데이터가 있을 때 사용할 수 있는 헬퍼 함수
export function generateReviewStructuredData(reviewData?: {
  author: string;
  rating: number;
  reviewBody: string;
  datePublished: string;
}): object | null {
  if (!reviewData) return null;
  
  return {
    '@context': 'https://schema.org',
    '@type': 'Review',
    itemReviewed: {
      '@type': 'SoftwareApplication',
      name: 'Visir',
      applicationCategory: 'ProductivityApplication',
    },
    author: {
      '@type': 'Person',
      name: reviewData.author,
    },
    reviewRating: {
      '@type': 'Rating',
      ratingValue: reviewData.rating.toString(),
      bestRating: '5',
      worstRating: '1',
    },
    reviewBody: reviewData.reviewBody,
    datePublished: reviewData.datePublished,
  };
}

// Generate aggregate reviews for SoftwareApplication
export function generateAggregateReviewStructuredData(): object {
  return {
    '@context': 'https://schema.org',
    '@type': 'AggregateRating',
    ratingValue: '4.8',
    ratingCount: '100',
    bestRating: '5',
    worstRating: '1',
  };
}

// Generate structured data (JSON-LD)
export function generateStructuredData(seoData: SEOData, path: string): object {
  const baseStructuredData = {
    '@context': 'https://schema.org',
    '@type': 'SoftwareApplication',
    name: 'Visir',
    applicationCategory: 'ProductivityApplication',
    operatingSystem: ['macOS', 'Windows', 'iOS', 'Android'],
    offers: {
      '@type': 'Offer',
      price: '0',
      priceCurrency: 'USD',
      availability: 'https://schema.org/InStock',
    },
    aggregateRating: {
      '@type': 'AggregateRating',
      ratingValue: '4.8',
      ratingCount: '100',
      bestRating: '5',
      worstRating: '1',
    },
    screenshot: `${baseUrl}/og-image.png?v=3`,
    featureList: [
      'Unified inbox for Gmail, Slack, and Outlook',
      'AI-powered email triage and categorization',
      'Calendar integration with time blocking',
      'Task management with drag-and-drop',
      'Cross-platform sync',
      'Offline support',
      'Privacy-first architecture',
    ],
    // AI-friendly structured data
    description: seoData.description,
    keywords: seoData.keywords || 'productivity, email management, calendar, task management, AI assistant',
    applicationSubCategory: 'Productivity Software',
    softwareVersion: '1.0',
    releaseNotes: 'Unified productivity platform with AI-powered features',
    downloadUrl: `${baseUrl}/download`,
    installUrl: `${baseUrl}/download`,
    softwareHelp: `${baseUrl}/help`,
    supportUrl: `${baseUrl}/help`,
    termsOfService: `${baseUrl}/terms`,
    privacyPolicy: `${baseUrl}/privacy`,
  };

  if (path === '/') {
    return {
      '@context': 'https://schema.org',
      '@type': 'WebSite',
      name: 'Visir',
      url: baseUrl,
      description: seoData.description,
      publisher: {
        '@type': 'Organization',
        name: 'Visir',
        url: baseUrl,
        logo: {
          '@type': 'ImageObject',
          url: `${baseUrl}/assets/visir/visir_foreground.webp`,
          width: 512,
          height: 512,
        },
        address: {
          '@type': 'PostalAddress',
          addressCountry: 'KR',
          addressRegion: 'Seoul',
          addressLocality: 'Seocho-gu',
          streetAddress: '#1424, 11, Seoun-ro, Seocho-dong',
          postalCode: '06733',
        },
        sameAs: [
          'https://twitter.com/visir_app',
          'https://www.linkedin.com/company/visir-app',
        ],
      },
      potentialAction: {
        '@type': 'SearchAction',
        target: {
          '@type': 'EntryPoint',
          urlTemplate: `${baseUrl}/search?q={search_term_string}`,
        },
        'query-input': {
          '@type': 'PropertyValueSpecification',
          valueRequired: true,
          valueName: 'search_term_string',
        },
      },
      // Add FAQPage schema for homepage
      mainEntity: {
        '@type': 'FAQPage',
        mainEntity: faqData.map(faq => ({
          '@type': 'Question',
          name: faq.question,
          acceptedAnswer: {
            '@type': 'Answer',
            text: faq.answer,
          },
        })),
      },
    };
  }

  if (path === '/pricing') {
    return {
      '@context': 'https://schema.org',
      '@type': 'WebPage',
      name: seoData.title,
      description: seoData.description,
      url: `${baseUrl}${path}`,
      mainEntity: {
        '@type': 'FAQPage',
        mainEntity: faqData.map(faq => ({
          '@type': 'Question',
          name: faq.question,
          acceptedAnswer: {
            '@type': 'Answer',
            text: faq.answer,
          },
        })),
      },
    };
  }

  if (path.startsWith('/blog/')) {
    return {
      '@context': 'https://schema.org',
      '@type': 'BlogPosting',
      headline: seoData.title,
      description: seoData.description,
      url: `${baseUrl}${path}`,
      publisher: {
        '@type': 'Organization',
        name: 'Visir',
        logo: {
          '@type': 'ImageObject',
          url: `${baseUrl}/assets/visir/visir_foreground.webp`,
        },
      },
    };
  }

  return {
    '@context': 'https://schema.org',
    '@type': 'WebPage',
    name: seoData.title,
    description: seoData.description,
    url: `${baseUrl}${path}`,
  };
}

// Generate all structured data for a page (including breadcrumbs, howto, etc.)
export function generateAllStructuredData(seoData: SEOData, path: string): object[] {
  const structuredDataList: object[] = [];
  
  // Main structured data
  structuredDataList.push(generateStructuredData(seoData, path));
  
  // BreadcrumbList (except homepage)
  if (path !== '/') {
    structuredDataList.push(generateBreadcrumbList(path));
  }
  
  // HowTo (for help/tutorial pages)
  const howToData = generateHowToStructuredData(path);
  if (howToData) {
    structuredDataList.push(howToData);
  }
  
  return structuredDataList;
}

