<script lang="ts">
  import { link } from '../lib/router';
  import Icon from '../components/Icon.svelte';
  import ryanProfile from '../assets/ryan.webp';

  function parseFrontmatter(content: string): { frontmatter: Record<string, string>, body: string } {
    const frontmatterRegex = /^---\s*\n([\s\S]*?)\n---\s*\n([\s\S]*)$/;
    const match = content.match(frontmatterRegex);
    
    if (!match) {
      return { frontmatter: {}, body: content };
    }
    
    const frontmatterText = match[1];
    const body = match[2];
    const frontmatter: Record<string, string> = {};
    
    frontmatterText.split('\n').forEach(line => {
      const colonIndex = line.indexOf(':');
      if (colonIndex > 0) {
        const key = line.substring(0, colonIndex).trim();
        const value = line.substring(colonIndex + 1).trim().replace(/^["']|["']$/g, '');
        frontmatter[key] = value;
      }
    });
    
    return { frontmatter, body };
  }

  function formatDate(dateString: string): string {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', { 
      year: 'numeric', 
      month: 'short', 
      day: 'numeric' 
    });
  }

  const blogModules = import.meta.glob('../assets/blog/*.md', { 
    as: 'raw',
    eager: true 
  }) as Record<string, string>;

  interface BlogPost {
    title: string;
    excerpt: string;
    date: string;
    readTime: string;
    author: string;
    image: string;
    category: string;
    slug: string;
    content: string;
  }

  let selectedCategory: string | null = null;

  $: allPosts = (() => {
    const blogPosts: BlogPost[] = [];
    
    Object.entries(blogModules).forEach(([path, content]) => {
      const { frontmatter, body } = parseFrontmatter(content);
      
      if (frontmatter.title && frontmatter.slug) {
        blogPosts.push({
          title: frontmatter.title,
          excerpt: frontmatter.excerpt || '',
          date: frontmatter.date || '',
          readTime: frontmatter.readTime || '5 min read',
          author: frontmatter.author || 'Anonymous',
          image: frontmatter.image || '',
          category: frontmatter.category || 'General',
          slug: frontmatter.slug,
          content: body
        });
      }
    });
    
    return blogPosts.sort((a, b) => {
      const dateA = new Date(a.date).getTime();
      const dateB = new Date(b.date).getTime();
      return dateB - dateA;
    });
  })();

  $: categories = (() => {
    const categorySet = new Set<string>();
    allPosts.forEach(post => {
      if (post.category) {
        categorySet.add(post.category);
      }
    });
    return Array.from(categorySet).sort();
  })();

  $: posts = selectedCategory 
    ? allPosts.filter(post => post.category === selectedCategory)
    : allPosts;
</script>

<div class="pt-32 pb-24 min-h-screen">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="text-center mb-12">
      <h1 class="text-4xl sm:text-6xl font-medium font-display tracking-tight text-visir-text mb-6">
        The Visir Blog
      </h1>
      <p class="text-xl text-visir-text-muted max-w-2xl mx-auto font-light mb-8">
        Updates, productivity frameworks, and engineering deep dives.
      </p>
      
      <!-- Category Filter Buttons -->
      {#if categories.length > 0}
        <div class="flex flex-wrap items-center justify-center gap-3 mb-8">
          <button
            on:click={() => selectedCategory = null}
            class="px-4 py-2 rounded-full text-sm font-medium transition-all duration-200 {selectedCategory === null ? 'bg-visir-primary text-white shadow-lg shadow-visir-primary/30' : 'bg-white/10 dark:bg-white/5 text-visir-text-muted hover:bg-white/20 dark:hover:bg-white/10 hover:text-visir-text border border-white/20 dark:border-white/10 backdrop-blur-xl shadow-sm'}"
          >
            All
          </button>
          {#each categories as category}
            <button
              on:click={() => selectedCategory = category}
              class="px-4 py-2 rounded-full text-sm font-medium transition-all duration-200 {selectedCategory === category ? 'bg-visir-primary text-white shadow-lg shadow-visir-primary/30' : 'bg-white/10 dark:bg-white/5 text-visir-text-muted hover:bg-white/20 dark:hover:bg-white/10 hover:text-visir-text border border-white/20 dark:border-white/10 backdrop-blur-xl shadow-sm'}"
            >
              {category}
            </button>
          {/each}
        </div>
      {/if}
    </div>

    {#if posts.length === 0}
      <div class="text-center py-20">
        <p class="text-visir-text-muted">No blog posts found.</p>
        <p class="text-sm text-visir-text-muted mt-2">
          Add markdown files to <code class="bg-visir-surface/20 px-2 py-1 rounded">assets/blog/</code> folder
        </p>
      </div>
    {:else}
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        {#each posts as post}
          <a 
            href="/blog/{post.slug}"
            use:link
            class="group flex flex-col bg-white/10 dark:bg-white/5 rounded-3xl border border-white/20 dark:border-white/10 overflow-hidden hover:border-visir-primary/30 transition-transform duration-200 hover:-translate-y-1 backdrop-blur-sm shadow-lg"
            style="contain: layout style paint;"
          >
            <article class="flex flex-col h-full">
              <div class="relative h-48 overflow-hidden">
                <img 
                  src={post.image} 
                  alt={post.title} 
                  class="w-full h-full object-cover transition-transform duration-300 group-hover:scale-105"
                  loading="lazy"
                  decoding="async"
                />
                <div class="absolute top-4 left-4">
                  <span class="px-3 py-1 rounded-full bg-black/50 backdrop-blur-sm text-xs font-medium text-white border border-white/10">
                    {post.category}
                  </span>
                </div>
              </div>
              
              <div class="p-6 flex-1 flex flex-col">
                <div class="flex items-center gap-4 text-xs text-visir-text-muted mb-3 font-mono">
                  <span class="flex items-center gap-1"><Icon name="Calendar" size={12}/> {formatDate(post.date)}</span>
                  <span class="flex items-center gap-1"><Icon name="Clock" size={12}/> {post.readTime}</span>
                </div>
                
                <h2 class="text-xl font-semibold font-display text-visir-text mb-3 group-hover:text-visir-primary transition-colors">
                  {post.title}
                </h2>
                <p class="text-visir-text-muted text-sm leading-relaxed mb-6 font-light line-clamp-3">
                  {post.excerpt}
                </p>
                
                <div class="mt-auto flex items-center justify-between border-t border-white/5 pt-4">
                  <div class="flex items-center gap-2">
                    {#if post.author === 'Ryan Lee'}
                      <img 
                        src={ryanProfile} 
                        alt={post.author}
                        class="w-6 h-6 rounded-full object-cover"
                      />
                    {:else}
                      <div class="w-6 h-6 rounded-full bg-visir-surface flex items-center justify-center text-xs">
                        <Icon name="User" size={12} className="text-visir-text-muted"/>
                      </div>
                    {/if}
                    <span class="text-xs text-visir-text-muted">{post.author}</span>
                  </div>
                  <span class="text-visir-primary text-sm font-medium flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity -translate-x-2 group-hover:translate-x-0">
                    Read <Icon name="ArrowRight" size={14} />
                  </span>
                </div>
              </div>
            </article>
          </a>
        {/each}
      </div>
    {/if}
  </div>
</div>
