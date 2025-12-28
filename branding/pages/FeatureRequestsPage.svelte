<script lang="ts">
  import { onMount } from 'svelte';
  import { link } from '../lib/router';
  import Icon from '../components/Icon.svelte';
  import { supabase, getVisitorId } from '../lib/supabase';

  interface FeatureRequest {
    id: string;
    title: string;
    description: string;
    category: 'ai' | 'integrations' | 'mobile' | 'desktop' | 'core' | 'other';
    upvotes_count: number;
    created_at: string;
    status?: 'under-review' | 'planned' | 'in-progress' | 'completed';
  }

  const categoryLabels = {
    ai: 'AI Features',
    integrations: 'Integrations',
    mobile: 'Mobile',
    desktop: 'Desktop',
    core: 'Core Features',
    other: 'Other',
  };

  const statusLabels = {
    'under-review': 'Under Review',
    'planned': 'Planned',
    'in-progress': 'In Progress',
    'completed': 'Completed',
  };

  let features: FeatureRequest[] = [];
  let selectedCategory = 'all';
  let sortBy: 'popular' | 'recent' = 'popular';
  let showSubmitForm = false;
  let upvotedIds = new Set<string>();
  let loading = true;
  let submitting = false;
  
  let formTitle = '';
  let formDescription = '';
  let formCategory: 'ai' | 'integrations' | 'mobile' | 'desktop' | 'core' | 'other' = 'core';

  const visitorId = getVisitorId();

  async function loadFeatureRequests() {
    try {
      loading = true;
      const { data, error } = await supabase
        .from('feature_requests')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) throw error;
      
      if (data) {
        features = data as FeatureRequest[];
      }
    } catch (error) {
      console.error('Error loading feature requests:', error);
    } finally {
      loading = false;
    }
  }

  async function loadUpvotedIds() {
    try {
      const { data, error } = await supabase
        .from('feature_request_upvotes')
        .select('feature_request_id')
        .eq('visitor_id', visitorId);

      if (error) throw error;
      
      if (data) {
        upvotedIds = new Set(data.map(item => item.feature_request_id));
      }
    } catch (error) {
      console.error('Error loading upvotes:', error);
    }
  }

  async function handleUpvote(id: string) {
    const isUpvoted = upvotedIds.has(id);
    
    try {
      if (isUpvoted) {
        const { error } = await supabase
          .from('feature_request_upvotes')
          .delete()
          .eq('feature_request_id', id)
          .eq('visitor_id', visitorId);

        if (error) throw error;

        upvotedIds.delete(id);
        await loadFeatureRequests();
      } else {
        const { error } = await supabase
          .from('feature_request_upvotes')
          .insert({
            feature_request_id: id,
            visitor_id: visitorId,
          });

        if (error) throw error;

        upvotedIds.add(id);
        await loadFeatureRequests();
      }
    } catch (error) {
      console.error('Error toggling upvote:', error);
    }
  }

  async function handleSubmit(e: Event) {
    e.preventDefault();
    
    if (!formTitle.trim() || !formDescription.trim()) {
      return;
    }

    try {
      submitting = true;
      const { error } = await supabase
        .from('feature_requests')
        .insert({
          title: formTitle.trim(),
          description: formDescription.trim(),
          category: formCategory,
          visitor_id: visitorId,
          status: 'under-review',
        });

      if (error) throw error;

      formTitle = '';
      formDescription = '';
      formCategory = 'core';
      showSubmitForm = false;

      await loadFeatureRequests();
    } catch (error) {
      console.error('Error submitting feature request:', error);
      alert('Failed to submit feature request. Please try again.');
    } finally {
      submitting = false;
    }
  }

  function formatDate(dateString: string) {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', { 
      year: 'numeric', 
      month: 'short', 
      day: 'numeric' 
    });
  }

  $: filteredAndSortedFeatures = (() => {
    let filtered = features;
    
    if (selectedCategory !== 'all') {
      filtered = filtered.filter(f => f.category === selectedCategory);
    }
    
    if (sortBy === 'popular') {
      filtered = [...filtered].sort((a, b) => b.upvotes_count - a.upvotes_count);
    } else {
      filtered = [...filtered].sort((a, b) => 
        new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
      );
    }
    
    return filtered;
  })();

  onMount(() => {
    loadFeatureRequests();
    loadUpvotedIds();
  });
</script>

<div class="pt-32 pb-24 min-h-screen">
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
    <!-- Header -->
    <div class="text-center mb-12">
      <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-visir-primary/10 border border-visir-primary/20 text-visir-primary text-xs font-medium uppercase tracking-wide mb-8 backdrop-blur-md">
        <Icon name="Sparkles" size={14} />
        <span class="font-display tracking-wide">Feature Requests</span>
      </div>
      <h1 class="text-4xl sm:text-6xl font-medium font-display tracking-tight text-visir-text mb-6">
        Shape the Future of Visir
      </h1>
      <p class="text-xl text-visir-text-muted max-w-2xl mx-auto font-light mb-8">
        Share your ideas and vote on features you'd like to see. Your feedback helps us prioritize what to build next.
      </p>
      <button
        on:click={() => showSubmitForm = !showSubmitForm}
        class="inline-flex items-center gap-2 px-6 py-3 rounded-full bg-visir-primary text-white hover:bg-visir-primary/90 transition-colors font-medium shadow-lg shadow-visir-primary/30"
      >
        <Icon name="Plus" size={18} />
        Submit Feature Request
      </button>
    </div>

    <!-- Submit Form -->
    {#if showSubmitForm}
      <div class="mb-12 p-8 rounded-3xl bg-white/10 dark:bg-white/5 border border-white/20 dark:border-white/10 backdrop-blur-xl shadow-lg">
        <h2 class="text-2xl font-display font-medium text-visir-text mb-6">Submit a Feature Request</h2>
        <form on:submit={handleSubmit} class="space-y-6">
          <div>
            <label class="block text-sm font-medium text-visir-text mb-2">Title</label>
            <input
              type="text"
              bind:value={formTitle}
              placeholder="What feature would you like to see?"
              class="w-full px-4 py-3 rounded-2xl bg-white/10 dark:bg-white/5 border border-white/20 dark:border-white/10 text-visir-text placeholder-visir-text-muted focus:outline-none focus:border-visir-primary/30 transition-colors backdrop-blur-xl"
              required
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-visir-text mb-2">Description</label>
            <textarea
              bind:value={formDescription}
              placeholder="Describe your feature request in detail..."
              rows={4}
              class="w-full px-4 py-3 rounded-2xl bg-white/10 dark:bg-white/5 border border-white/20 dark:border-white/10 text-visir-text placeholder-visir-text-muted focus:outline-none focus:border-visir-primary/30 transition-colors backdrop-blur-xl resize-none"
              required
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-visir-text mb-2">Category</label>
            <select
              bind:value={formCategory}
              class="w-full px-4 py-3 rounded-2xl bg-white/10 dark:bg-white/5 border border-white/20 dark:border-white/10 text-visir-text focus:outline-none focus:border-visir-primary/30 transition-colors backdrop-blur-xl"
            >
              <option value="core">Core Features</option>
              <option value="ai">AI Features</option>
              <option value="integrations">Integrations</option>
              <option value="mobile">Mobile</option>
              <option value="desktop">Desktop</option>
              <option value="other">Other</option>
            </select>
          </div>
          <div class="flex gap-4">
            <button
              type="submit"
              disabled={submitting}
              class="px-6 py-3 rounded-full bg-visir-primary text-white hover:bg-visir-primary/90 transition-colors font-medium disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {submitting ? 'Submitting...' : 'Submit Request'}
            </button>
            <button
              type="button"
              on:click={() => {
                showSubmitForm = false;
                formTitle = '';
                formDescription = '';
                formCategory = 'core';
              }}
              class="px-6 py-3 rounded-full bg-white/10 dark:bg-white/5 text-visir-text border border-white/20 dark:border-white/10 hover:border-visir-primary/30 transition-colors font-medium backdrop-blur-xl"
            >
              Cancel
            </button>
          </div>
        </form>
      </div>
    {/if}

    <!-- Filters and Sort -->
    <div class="flex flex-wrap items-center justify-between gap-4 mb-8">
      <div class="flex flex-wrap gap-2">
        <button
          on:click={() => selectedCategory = 'all'}
          class="px-4 py-2 rounded-full text-sm font-medium transition-all {selectedCategory === 'all' ? 'bg-visir-primary text-white shadow-lg shadow-visir-primary/30' : 'bg-white/10 dark:bg-white/5 text-visir-text-muted hover:text-visir-text border border-white/20 dark:border-white/10 backdrop-blur-xl shadow-sm'}"
        >
          All
        </button>
        {#each Object.entries(categoryLabels) as [key, label]}
          <button
            on:click={() => selectedCategory = key}
            class="px-4 py-2 rounded-full text-sm font-medium transition-all {selectedCategory === key ? 'bg-visir-primary text-white shadow-lg shadow-visir-primary/30' : 'bg-white/10 dark:bg-white/5 text-visir-text-muted hover:text-visir-text border border-white/20 dark:border-white/10 backdrop-blur-xl shadow-sm'}"
          >
            {label}
          </button>
        {/each}
      </div>

      <div class="flex items-center gap-2">
        <Icon name="Filter" size={16} className="text-visir-text-muted" />
        <button
          on:click={() => sortBy = 'popular'}
          class="px-4 py-2 rounded-full text-sm font-medium transition-all {sortBy === 'popular' ? 'bg-visir-primary text-white shadow-lg shadow-visir-primary/30' : 'bg-white/10 dark:bg-white/5 text-visir-text-muted hover:text-visir-text border border-white/20 dark:border-white/10 backdrop-blur-xl shadow-sm'}"
        >
          Most Popular
        </button>
        <button
          on:click={() => sortBy = 'recent'}
          class="px-4 py-2 rounded-full text-sm font-medium transition-all {sortBy === 'recent' ? 'bg-visir-primary text-white shadow-lg shadow-visir-primary/30' : 'bg-white/10 dark:bg-white/5 text-visir-text-muted hover:text-visir-text border border-white/20 dark:border-white/10 backdrop-blur-xl shadow-sm'}"
        >
          Most Recent
        </button>
      </div>
    </div>

    <!-- Loading State -->
    {#if loading}
      <div class="text-center py-12">
        <p class="text-visir-text-muted">Loading feature requests...</p>
      </div>
    {:else if filteredAndSortedFeatures.length === 0}
      <div class="text-center py-12">
        <p class="text-visir-text-muted">No feature requests found. Be the first to submit one!</p>
      </div>
    {:else}
      <div class="space-y-4">
        {#each filteredAndSortedFeatures as feature}
          {@const isUpvoted = upvotedIds.has(feature.id)}
          <div class="p-6 rounded-2xl bg-white/10 dark:bg-white/5 border border-white/20 dark:border-white/10 backdrop-blur-xl shadow-lg hover:border-visir-primary/30 transition-all">
            <div class="flex gap-4">
              <button
                on:click={() => handleUpvote(feature.id)}
                class="flex flex-col items-center gap-1 px-4 py-2 rounded-xl transition-all {isUpvoted ? 'bg-visir-primary/20 text-visir-primary border border-visir-primary/30' : 'bg-white/5 text-visir-text-muted border border-white/10 hover:bg-white/10 hover:text-visir-primary'}"
              >
                <Icon name="ChevronUp" size={20} className={isUpvoted ? 'fill-visir-primary' : ''} />
                <span class="text-sm font-semibold">{feature.upvotes_count}</span>
              </button>

              <div class="flex-1">
                <h3 class="text-xl font-display font-medium text-visir-text mb-2">
                  {feature.title}
                </h3>
                <p class="text-sm text-visir-text-muted font-light leading-relaxed mb-4">
                  {feature.description}
                </p>

                <div class="flex flex-wrap items-center gap-4">
                  <span class="px-3 py-1 rounded-full bg-white/5 text-visir-text-muted text-xs font-medium border border-white/10">
                    {categoryLabels[feature.category]}
                  </span>
                  {#if feature.status}
                    <span class="px-3 py-1 rounded-full text-xs font-medium {feature.status === 'completed' ? 'bg-emerald-500/20 text-emerald-400 border border-emerald-500/30' : feature.status === 'in-progress' ? 'bg-visir-primary/20 text-visir-primary border border-visir-primary/30' : feature.status === 'planned' ? 'bg-blue-500/20 text-blue-400 border border-blue-500/30' : 'bg-visir-text-muted/20 text-visir-text-muted border border-visir-text-muted/30'}">
                      {statusLabels[feature.status]}
                    </span>
                  {/if}
                  <div class="flex items-center gap-1 text-xs text-visir-text-muted">
                    <Icon name="Calendar" size={12} />
                    <span>{formatDate(feature.created_at)}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        {/each}
      </div>
    {/if}
  </div>
</div>
