<script lang="ts">
  import { onMount } from 'svelte';
  import { link } from '../lib/router';
  import Icon from '../components/Icon.svelte';

  interface RoadmapItem {
    title: string;
    description: string;
    status: 'planned' | 'in-progress' | 'completed';
    category: 'ai' | 'integrations' | 'mobile' | 'desktop' | 'core';
    quarter?: string;
    icon?: 'custom';
    iconName?: string;
  }

  const roadmapItems: RoadmapItem[] = [
    // Completed
    {
      title: 'Agent Home',
      description: 'Get a summary of your inbox items and tasks that need your attention.',
      status: 'completed',
      category: 'ai',
      quarter: 'Q4 2024',
      icon: 'custom',
      iconName: 'home'
    },
    {
      title: 'Braindump Section',
      description: 'Quickly capture thoughts and ideas you don\'t want to forget.',
      status: 'completed',
      category: 'core',
      quarter: 'Q4 2024',
      icon: 'custom',
      iconName: 'braindump'
    },
    {
      title: 'Projects',
      description: 'Group your tasks and events by project with AI-powered suggestions.',
      status: 'completed',
      category: 'core',
      quarter: 'Q4 2024',
      icon: 'custom',
      iconName: 'folder'
    },
    {
      title: 'Outlook Integration',
      description: 'Full integration with Outlook Calendar and Mail.',
      status: 'completed',
      category: 'integrations',
      quarter: 'Q3 2024',
      icon: 'custom',
      iconName: 'outlook'
    },
    {
      title: 'Mobile Gestures',
      description: 'Swipe right to access mail and chat options. Long-press for drag-and-drop.',
      status: 'completed',
      category: 'mobile',
      quarter: 'Q4 2024',
      icon: 'custom',
      iconName: 'gesture'
    },
    
    // In Progress
    {
      title: 'GitHub Issues Integration',
      description: 'Connect your GitHub repositories and manage issues directly in Visir.',
      status: 'in-progress',
      category: 'integrations',
      quarter: 'Q1 2025',
      icon: 'custom',
      iconName: 'github'
    },
    {
      title: 'Notion Integration',
      description: 'Sync your Notion pages and databases with Visir for seamless workflow.',
      status: 'in-progress',
      category: 'integrations',
      quarter: 'Q1 2025',
      icon: 'custom',
      iconName: 'notion'
    },
    {
      title: 'Advanced AI Summaries',
      description: 'More intelligent context summaries and meeting preparation insights.',
      status: 'in-progress',
      category: 'ai',
      quarter: 'Q1 2025',
      icon: 'custom',
      iconName: 'ai-summary'
    },
    
    // Planned
    {
      title: 'Markdown Support',
      description: 'Native markdown editing and rendering throughout the app.',
      status: 'planned',
      category: 'core',
      quarter: 'Q2 2025',
      icon: 'custom',
      iconName: 'markdown'
    },
    {
      title: 'Custom Workflows',
      description: 'Create custom automation workflows with visual builder.',
      status: 'planned',
      category: 'core',
      quarter: 'Q2 2025',
      icon: 'custom',
      iconName: 'workflow'
    },
    {
      title: 'Team Collaboration',
      description: 'Share projects and collaborate with your team members.',
      status: 'planned',
      category: 'core',
      quarter: 'Q3 2025',
      icon: 'custom',
      iconName: 'team'
    },
    {
      title: 'Advanced Calendar Views',
      description: 'Multiple calendar views including week, month, and agenda.',
      status: 'planned',
      category: 'desktop',
      quarter: 'Q2 2025',
      icon: 'custom',
      iconName: 'calendar'
    },
    {
      title: 'Offline Mode',
      description: 'Full functionality available even without internet connection.',
      status: 'planned',
      category: 'mobile',
      quarter: 'Q2 2025',
      icon: 'custom',
      iconName: 'offline'
    },
    {
      title: 'API Access',
      description: 'Public API for developers to integrate Visir with their tools.',
      status: 'planned',
      category: 'core',
      quarter: 'Q3 2025',
      icon: 'custom',
      iconName: 'api'
    },
  ];

  const categoryIcons = {
    ai: 'Sparkles',
    integrations: 'Code',
    mobile: 'Smartphone',
    desktop: 'Monitor',
    core: 'Settings',
  };

  const categoryLabels = {
    ai: 'AI Features',
    integrations: 'Integrations',
    mobile: 'Mobile',
    desktop: 'Desktop',
    core: 'Core Features',
  };

  const statusLabels = {
    'planned': 'Planned',
    'in-progress': 'In Progress',
    'completed': 'Completed',
  };

  function getItemIcon(item: RoadmapItem): string {
    if (item.icon === 'custom' && item.iconName) {
      switch (item.iconName) {
        case 'outlook':
          // Microsoft/Outlook icon - using a simple square grid pattern
          return 'outlook-svg';
        case 'github':
          return 'Github';
        case 'notion':
          return 'FileText';
        case 'gesture':
          return 'ArrowRightLeft';
        case 'home':
          return 'Sparkles';
        case 'braindump':
          return 'FileText';
        case 'folder':
          return 'Folder';
        case 'ai-summary':
          return 'Sparkles';
        case 'markdown':
          return 'FileText';
        case 'workflow':
          return 'Settings';
        case 'team':
          return 'Users';
        case 'calendar':
          return 'Calendar';
        case 'offline':
          return 'Wifi';
        case 'api':
          return 'Code';
        default:
          return categoryIcons[item.category] || 'Sparkles';
      }
    }
    return categoryIcons[item.category] || 'Sparkles';
  }

  let selectedStatus: 'all' | 'planned' | 'in-progress' | 'completed' = 'all';
  let selectedCategory: string = 'all';
  let isDark = true;

  function checkTheme() {
    isDark = document.documentElement.classList.contains('dark');
  }

  onMount(() => {
    checkTheme();
    const observer = new MutationObserver(checkTheme);
    observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['class']
    });
    
    return () => observer.disconnect();
  });

  $: filteredItems = roadmapItems.filter(item => {
    const statusMatch = selectedStatus === 'all' || item.status === selectedStatus;
    const categoryMatch = selectedCategory === 'all' || item.category === selectedCategory;
    return statusMatch && categoryMatch;
  });

  $: groupedByStatus = {
    completed: filteredItems.filter(item => item.status === 'completed'),
    'in-progress': filteredItems.filter(item => item.status === 'in-progress'),
    planned: filteredItems.filter(item => item.status === 'planned'),
  };
</script>

<div class="pt-32 pb-24 min-h-screen">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <!-- Header -->
    <div class="text-center mb-16">
      <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-visir-primary/10 border border-visir-primary/20 text-visir-primary text-xs font-medium uppercase tracking-wide mb-8 backdrop-blur-md">
        <Icon name="Calendar" size={14} />
        <span class="font-display tracking-wide">Roadmap</span>
      </div>
      <h1 class="text-4xl sm:text-6xl font-medium font-display tracking-tight text-visir-text mb-6">
        What's Coming Next
      </h1>
      <p class="text-xl text-visir-text-muted max-w-2xl mx-auto font-light">
        See what we're building and help shape the future of Visir.
      </p>
    </div>

    <!-- Filters -->
    <div class="flex flex-wrap items-center justify-center gap-4 mb-12">
      <!-- Status Filter -->
      <div class="flex gap-2">
        <button
          on:click={() => selectedStatus = 'all'}
          class="px-4 py-2 rounded-full text-sm font-medium transition-all {selectedStatus === 'all' ? 'bg-visir-primary text-white shadow-lg shadow-visir-primary/30' : 'bg-white/10 dark:bg-white/5 text-visir-text-muted hover:text-visir-text border border-white/20 dark:border-white/10 backdrop-blur-xl shadow-sm'}"
        >
          All
        </button>
        <button
          on:click={() => selectedStatus = 'planned'}
          class="px-4 py-2 rounded-full text-sm font-medium transition-all flex items-center gap-2 {selectedStatus === 'planned' ? 'bg-visir-primary text-white shadow-lg shadow-visir-primary/30' : 'bg-white/10 dark:bg-white/5 text-visir-text-muted hover:text-visir-text border border-white/20 dark:border-white/10 backdrop-blur-xl shadow-sm'}"
        >
          <Icon name="Clock" size={14} /> Planned
        </button>
        <button
          on:click={() => selectedStatus = 'in-progress'}
          class="px-4 py-2 rounded-full text-sm font-medium transition-all flex items-center gap-2 {selectedStatus === 'in-progress' ? 'bg-visir-primary text-white shadow-lg shadow-visir-primary/30' : 'bg-white/10 dark:bg-white/5 text-visir-text-muted hover:text-visir-text border border-white/20 dark:border-white/10 backdrop-blur-xl shadow-sm'}"
        >
          <Icon name="Clock" size={14} className="animate-spin" /> In Progress
        </button>
        <button
          on:click={() => selectedStatus = 'completed'}
          class="px-4 py-2 rounded-full text-sm font-medium transition-all flex items-center gap-2 {selectedStatus === 'completed' ? 'bg-visir-primary text-white shadow-lg shadow-visir-primary/30' : 'bg-white/10 dark:bg-white/5 text-visir-text-muted hover:text-visir-text border border-white/20 dark:border-white/10 backdrop-blur-xl shadow-sm'}"
        >
          <Icon name="CheckCircle2" size={14} /> Completed
        </button>
      </div>

      <!-- Category Filter -->
      <div class="flex gap-2">
        <button
          on:click={() => selectedCategory = 'all'}
          class="px-4 py-2 rounded-full text-sm font-medium transition-all {selectedCategory === 'all' ? 'bg-visir-primary text-white shadow-lg shadow-visir-primary/30' : 'bg-white/10 dark:bg-white/5 text-visir-text-muted hover:text-visir-text border border-white/20 dark:border-white/10 backdrop-blur-xl shadow-sm'}"
        >
          All Categories
        </button>
        {#each Object.entries(categoryLabels) as [key, label]}
          {@const iconName = categoryIcons[key]}
          <button
            on:click={() => selectedCategory = key}
            class="px-4 py-2 rounded-full text-sm font-medium transition-all flex items-center gap-2 {selectedCategory === key ? 'bg-visir-primary text-white shadow-lg shadow-visir-primary/30' : 'bg-white/10 dark:bg-white/5 text-visir-text-muted hover:text-visir-text border border-white/20 dark:border-white/10 backdrop-blur-xl shadow-sm'}"
          >
            <Icon name={iconName} size={14} /> {label}
          </button>
        {/each}
      </div>
    </div>

    <!-- Roadmap Items -->
    <div class="space-y-12">
      <!-- Completed Section -->
      {#if (selectedStatus === 'all' || selectedStatus === 'completed') && groupedByStatus.completed.length > 0}
        <div>
          <div class="flex items-center gap-3 mb-6">
            <Icon name="CheckCircle2" size={24} className="text-emerald-500" />
            <h2 class="text-2xl font-display font-medium text-visir-text">Completed</h2>
            <span class="px-3 py-1 rounded-full bg-emerald-500/10 text-emerald-400 text-xs font-medium">
              {groupedByStatus.completed.length}
            </span>
          </div>
          <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {#each groupedByStatus.completed as item}
              {@const IconComponent = getItemIcon(item)}
              <div class="p-6 rounded-2xl bg-white/10 dark:bg-white/5 border border-white/20 dark:border-white/10 backdrop-blur-xl shadow-lg hover:border-emerald-500/30 transition-all">
                <div class="flex items-start justify-between mb-4">
                  <div class="w-10 h-10 rounded-xl bg-emerald-500/20 text-emerald-400 flex items-center justify-center">
                    {#if IconComponent === 'outlook-svg'}
                      {@html `<svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor"><path d="M7.5 7.5h3v3h-3v-3zm6 0h3v3h-3v-3zm-6 6h3v3h-3v-3zm6 0h3v3h-3v-3z"/></svg>`}
                    {:else if IconComponent}
                      <Icon name={IconComponent} size={20} />
                    {/if}
                  </div>
                  {#if item.quarter}
                    <span class="px-2 py-1 rounded-md bg-white/5 text-visir-text-muted text-xs font-medium">
                      {item.quarter}
                    </span>
                  {/if}
                </div>
                <h3 class="text-lg font-display font-medium text-visir-text mb-2">{item.title}</h3>
                <p class="text-sm text-visir-text-muted font-light">{item.description}</p>
              </div>
            {/each}
          </div>
        </div>
      {/if}

      <!-- In Progress Section -->
      {#if (selectedStatus === 'all' || selectedStatus === 'in-progress') && groupedByStatus['in-progress'].length > 0}
        <div>
          <div class="flex items-center gap-3 mb-6">
            <Icon name="Clock" size={24} className="text-visir-primary animate-spin" />
            <h2 class="text-2xl font-display font-medium text-visir-text">In Progress</h2>
            <span class="px-3 py-1 rounded-full bg-visir-primary/10 text-visir-primary text-xs font-medium">
              {groupedByStatus['in-progress'].length}
            </span>
          </div>
          <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {#each groupedByStatus['in-progress'] as item}
              {@const IconComponent = getItemIcon(item)}
              <div class="p-6 rounded-2xl bg-white/10 dark:bg-white/5 border border-white/20 dark:border-white/10 backdrop-blur-xl shadow-lg hover:border-visir-primary/30 transition-all">
                <div class="flex items-start justify-between mb-4">
                  <div class="w-10 h-10 rounded-xl text-visir-primary flex items-center justify-center" style="background-color: rgba(124, 93, 255, 0.2)">
                    {#if IconComponent === 'outlook-svg'}
                      {@html `<svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor"><path d="M7.5 7.5h3v3h-3v-3zm6 0h3v3h-3v-3zm-6 6h3v3h-3v-3zm6 0h3v3h-3v-3z"/></svg>`}
                    {:else if IconComponent}
                      <Icon name={IconComponent} size={20} />
                    {/if}
                  </div>
                  {#if item.quarter}
                    <span class="px-2 py-1 rounded-md bg-white/5 text-visir-text-muted text-xs font-medium">
                      {item.quarter}
                    </span>
                  {/if}
                </div>
                <h3 class="text-lg font-display font-medium text-visir-text mb-2">{item.title}</h3>
                <p class="text-sm text-visir-text-muted font-light">{item.description}</p>
              </div>
            {/each}
          </div>
        </div>
      {/if}

      <!-- Planned Section -->
      {#if (selectedStatus === 'all' || selectedStatus === 'planned') && groupedByStatus.planned.length > 0}
        <div>
          <div class="flex items-center gap-3 mb-6">
            <Icon name="Calendar" size={24} className="text-visir-text-muted" />
            <h2 class="text-2xl font-display font-medium text-visir-text">Planned</h2>
            <span class="px-3 py-1 rounded-full bg-visir-text-muted/10 text-visir-text-muted text-xs font-medium">
              {groupedByStatus.planned.length}
            </span>
          </div>
          <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {#each groupedByStatus.planned as item}
              {@const IconComponent = getItemIcon(item)}
              <div class="p-6 rounded-2xl bg-white/10 dark:bg-white/5 border border-white/20 dark:border-white/10 backdrop-blur-xl shadow-lg hover:border-visir-primary/30 transition-all">
                <div class="flex items-start justify-between mb-4">
                  <div class="w-10 h-10 rounded-xl text-visir-text-muted flex items-center justify-center" style="background-color: {isDark ? 'rgba(170, 170, 169, 0.2)' : 'rgba(94, 94, 94, 0.2)'}">
                    {#if IconComponent === 'outlook-svg'}
                      {@html `<svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor"><path d="M7.5 7.5h3v3h-3v-3zm6 0h3v3h-3v-3zm-6 6h3v3h-3v-3zm6 0h3v3h-3v-3z"/></svg>`}
                    {:else if IconComponent}
                      <Icon name={IconComponent} size={20} />
                    {/if}
                  </div>
                  {#if item.quarter}
                    <span class="px-2 py-1 rounded-md bg-white/5 text-visir-text-muted text-xs font-medium">
                      {item.quarter}
                    </span>
                  {/if}
                </div>
                <h3 class="text-lg font-display font-medium text-visir-text mb-2">{item.title}</h3>
                <p class="text-sm text-visir-text-muted font-light">{item.description}</p>
              </div>
            {/each}
          </div>
        </div>
      {/if}
    </div>

    <!-- CTA Section -->
    <div class="mt-20 pt-12 border-t border-white/5 text-center">
      <h3 class="text-2xl font-display font-medium text-visir-text mb-4">
        Have a Feature Request?
      </h3>
      <p class="text-visir-text-muted font-light mb-6 max-w-2xl mx-auto">
        Share your ideas and vote on features you'd like to see in Visir. Help shape the future of the product.
      </p>
      <div class="flex flex-col sm:flex-row gap-4 justify-center">
        <a
          href="/feature-requests"
          use:link
          class="inline-flex items-center gap-2 px-6 py-3 rounded-full bg-visir-primary text-white hover:bg-visir-primary/90 transition-colors font-medium shadow-lg shadow-visir-primary/30"
        >
          View Feature Requests <Icon name="ArrowRight" size={18} />
        </a>
        <a
          href="/changelog"
          use:link
          class="inline-flex items-center gap-2 px-6 py-3 rounded-full bg-white/10 dark:bg-white/5 text-visir-text border border-white/20 dark:border-white/10 hover:border-visir-primary/30 transition-colors font-medium backdrop-blur-xl shadow-lg"
        >
          View Changelog
        </a>
      </div>
    </div>
  </div>
</div>
