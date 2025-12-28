<script lang="ts">
  import Icon from '../components/Icon.svelte';

  let searchQuery = '';
  let expandedCategory: string | null = null;

  const categories = [
    {
      title: 'Getting Started',
      iconName: 'Book',
      articles: [
        { title: 'How to set up your first workspace', slug: 'setup-workspace' },
        { title: 'Connecting your email accounts', slug: 'connect-email' },
        { title: 'Setting up calendar integrations', slug: 'calendar-setup' },
        { title: 'Creating your first task', slug: 'create-task' },
      ]
    },
    {
      title: 'Features',
      iconName: 'Video',
      articles: [
        { title: 'Using time blocking', slug: 'time-blocking' },
        { title: 'AI assistant overview', slug: 'ai-assistant' },
        { title: 'Keyboard shortcuts', slug: 'shortcuts' },
        { title: 'Mobile app guide', slug: 'mobile-guide' },
      ]
    },
    {
      title: 'Troubleshooting',
      iconName: 'FileText',
      articles: [
        { title: 'Sync issues', slug: 'sync-issues' },
        { title: 'Email not loading', slug: 'email-loading' },
        { title: 'Calendar events missing', slug: 'calendar-missing' },
        { title: 'Performance issues', slug: 'performance' },
      ]
    },
  ];

  function toggleCategory(title: string) {
    expandedCategory = expandedCategory === title ? null : title;
  }
</script>

<div class="pt-32 pb-24 min-h-screen">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <!-- Hero -->
    <div class="text-center mb-16">
      <h1 class="text-4xl sm:text-6xl font-medium font-display tracking-tight text-visir-text mb-6">
        Help Center
      </h1>
      <p class="text-xl text-visir-text-muted max-w-2xl mx-auto font-light mb-8">
        Find answers to your questions and learn how to get the most out of Visir.
      </p>
      
      <!-- Search -->
      <div class="max-w-2xl mx-auto relative">
        <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none text-visir-text-muted">
          <Icon name="Search" size={20} />
        </div>
        <input
          type="text"
          bind:value={searchQuery}
          placeholder="Search for help..."
          class="w-full pl-12 pr-4 py-4 rounded-2xl bg-white/10 dark:bg-white/5 border border-white/20 dark:border-white/10 text-visir-text placeholder-visir-text-muted focus:outline-none focus:border-visir-primary/30 transition-colors backdrop-blur-xl shadow-lg"
        />
      </div>
    </div>

    <!-- Categories -->
    <div class="space-y-4">
      {#each categories as category}
        <div class="rounded-3xl bg-white/10 dark:bg-white/5 border border-white/20 dark:border-white/10 backdrop-blur-xl shadow-lg overflow-hidden">
          <button
            on:click={() => toggleCategory(category.title)}
            class="w-full p-6 flex items-center justify-between hover:bg-white/5 transition-colors"
          >
            <div class="flex items-center gap-4">
              <div class="w-12 h-12 rounded-xl bg-visir-primary/10 text-visir-primary flex items-center justify-center">
                <Icon name={category.iconName} size={24} />
              </div>
              <div class="text-left">
                <h3 class="text-xl font-display font-medium text-visir-text mb-1">{category.title}</h3>
                <p class="text-sm text-visir-text-muted">{category.articles.length} articles</p>
              </div>
            </div>
            <Icon name="ChevronDown" size={20} className="text-visir-text-muted transition-transform {expandedCategory === category.title ? 'rotate-180' : ''}" />
          </button>
          
          {#if expandedCategory === category.title}
            <div class="px-6 pb-6 space-y-2">
              {#each category.articles as article}
                <a
                  href="/help/{article.slug}"
                  class="block p-4 rounded-xl bg-white/5 hover:bg-white/10 transition-colors text-visir-text hover:text-visir-primary"
                >
                  {article.title}
                </a>
              {/each}
            </div>
          {/if}
        </div>
      {/each}
    </div>
  </div>
</div>
