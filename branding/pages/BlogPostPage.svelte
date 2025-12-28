<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { link, params } from '../lib/router';
  import Icon from '../components/Icon.svelte';
  import SvelteMarkdown from '@humanspeak/svelte-markdown';
  import remarkGfm from 'remark-gfm';
  import ryanProfile from '../assets/ryan.webp';
  import { updateMetaTags, generateStructuredData } from '../lib/seo';

  $: slug = $params.slug || '';

  interface Heading {
    level: number;
    text: string;
    id: string;
  }

  interface HeadingNode extends Heading {
    children: HeadingNode[];
  }

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
      month: 'long', 
      day: 'numeric' 
    });
  }

  function generateId(text: string): string {
    return text
      .toLowerCase()
      .replace(/[^\w\s-]/g, '')
      .replace(/\s+/g, '-')
      .replace(/-+/g, '-')
      .trim();
  }

  function extractHeadings(content: string): Heading[] {
    const headingRegex = /^(#{1,3})\s+(.+)$/gm;
    const headings: Heading[] = [];
    let match;
    
    while ((match = headingRegex.exec(content)) !== null) {
      const level = match[1].length;
      const text = match[2].trim();
      const id = generateId(text);
      headings.push({ level, text, id });
    }
    
    return headings;
  }

  function buildHeadingTree(headings: Heading[]): HeadingNode[] {
    const tree: HeadingNode[] = [];
    const stack: HeadingNode[] = [];
    
    headings.forEach((heading) => {
      const node: HeadingNode = {
        ...heading,
        children: []
      };
      
      // 스택에서 현재 레벨보다 높은 레벨의 노드들을 제거
      while (stack.length > 0 && stack[stack.length - 1].level >= heading.level) {
        stack.pop();
      }
      
      if (stack.length === 0) {
        // 루트 레벨 노드
        tree.push(node);
      } else {
        // 부모 노드에 자식으로 추가
        stack[stack.length - 1].children.push(node);
      }
      
      stack.push(node);
    });
    
    return tree;
  }

  const blogModules = import.meta.glob('../assets/blog/*.md', { 
    as: 'raw',
    eager: true 
  }) as Record<string, string>;

  $: post = (() => {
    for (const [path, content] of Object.entries(blogModules)) {
      const { frontmatter, body } = parseFrontmatter(content);
      if (frontmatter.slug === slug) {
        return {
          title: frontmatter.title || '',
          date: frontmatter.date || '',
          readTime: frontmatter.readTime || '5 min read',
          author: frontmatter.author || 'Anonymous',
          image: frontmatter.image || '',
          category: frontmatter.category || 'General',
          content: body
        };
      }
    }
    return null;
  })();

  $: headings = post ? extractHeadings(post.content) : [];
  $: headingTree = buildHeadingTree(headings);

  // Update SEO when post is loaded
  $: if (post) {
    const seoData = {
      title: `${post.title} - Visir Blog`,
      description: post.content.substring(0, 160).replace(/\n/g, ' ').trim() + '...',
      keywords: `Visir blog, ${post.category}, productivity`,
      ogImage: post.image || 'https://visir.pro/assets/visir/visir_foreground.webp',
      ogType: 'article',
      canonical: `https://visir.pro/blog/${slug}`,
    };
    updateMetaTags(seoData);
    
    // Update structured data for blog post
    const existingStructuredData = document.querySelectorAll('script[type="application/ld+json"]');
    existingStructuredData.forEach(script => script.remove());
    
    // Blog post structured data
    const blogPostData = {
      '@context': 'https://schema.org',
      '@type': 'BlogPosting',
      headline: post.title,
      description: seoData.description,
      image: seoData.ogImage,
      datePublished: post.date,
      author: {
        '@type': 'Person',
        name: post.author,
      },
      publisher: {
        '@type': 'Organization',
        name: 'Visir',
        logo: {
          '@type': 'ImageObject',
          url: 'https://visir.pro/assets/visir/visir_foreground.webp',
          width: 512,
          height: 512,
        },
      },
      url: `https://visir.pro/blog/${slug}`,
    };
    
    // Breadcrumb for blog post
    const breadcrumbData = {
      '@context': 'https://schema.org',
      '@type': 'BreadcrumbList',
      itemListElement: [
        {
          '@type': 'ListItem',
          position: 1,
          name: 'Home',
          item: 'https://visir.pro',
        },
        {
          '@type': 'ListItem',
          position: 2,
          name: 'Blog',
          item: 'https://visir.pro/blog',
        },
        {
          '@type': 'ListItem',
          position: 3,
          name: post.title,
          item: `https://visir.pro/blog/${slug}`,
        },
      ],
    };
    
    // Add both structured data scripts
    [blogPostData, breadcrumbData].forEach(data => {
      const script = document.createElement('script');
      script.type = 'application/ld+json';
      script.textContent = JSON.stringify(data);
      document.head.appendChild(script);
    });
  }

  let activeHeading = '';
  let expandedHeadings = new Set<string>();
  let observer: IntersectionObserver | null = null;

  function toggleExpanded(id: string) {
    expandedHeadings = new Set(expandedHeadings);
    if (expandedHeadings.has(id)) {
      expandedHeadings.delete(id);
    } else {
      expandedHeadings.add(id);
    }
    expandedHeadings = expandedHeadings;
  }

  function scrollToHeading(id: string) {
    const element = document.getElementById(id);
    if (element) {
      const offset = 100;
      const elementPosition = element.getBoundingClientRect().top;
      const offsetPosition = elementPosition + window.pageYOffset - offset;
      window.scrollTo({
        top: offsetPosition,
        behavior: 'smooth'
      });
    }
  }

  function addIdsToHeadings() {
    // 마크다운 렌더링 후 헤딩에 ID 추가
    headings.forEach((heading) => {
      const allHeadings = document.querySelectorAll(`h1, h2, h3`);
      allHeadings.forEach((element) => {
        if (element.textContent?.trim() === heading.text && !element.id) {
          element.id = heading.id;
          element.classList.add('scroll-mt-24');
        }
      });
    });
  }

  onMount(() => {
    // 초기화 시 모든 헤딩을 expanded 상태로 설정
    if (headings.length > 0) {
      expandedHeadings = new Set(headings.map(h => h.id));
    }

    // 마크다운 렌더링 후 헤딩에 ID 추가
    setTimeout(() => {
      addIdsToHeadings();
      
      // Intersection Observer로 현재 보이는 섹션 추적
      if (headings.length === 0) return;

      const observerOptions = {
        rootMargin: '-20% 0px -70% 0px',
        threshold: 0
      };

      observer = new IntersectionObserver((entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            activeHeading = entry.target.id;
          }
        });
      }, observerOptions);

      headings.forEach((heading) => {
        const element = document.getElementById(heading.id);
        if (element) {
          observer?.observe(element);
        }
      });
    }, 200);
  });

  onDestroy(() => {
    if (observer) {
      headings.forEach((heading) => {
        const element = document.getElementById(heading.id);
        if (element) {
          observer?.unobserve(element);
        }
      });
      observer.disconnect();
    }
  });
</script>

{#if post}
  <div class="pt-32 pb-24 min-h-screen">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex gap-8">
        <!-- Table of Contents - Left Sidebar -->
        {#if headings.length > 0}
          <aside class="hidden lg:block w-64 flex-shrink-0">
            <div class="sticky top-20 pt-2 pb-10">
              <div class="bg-white/10 dark:bg-white/5 rounded-2xl border border-white/20 dark:border-white/10 p-6 backdrop-blur-xl shadow-lg flex flex-col" style="height: calc(100vh - 120px); max-height: calc(100vh - 120px);">
                <h2 class="text-sm font-semibold text-visir-text mb-4 uppercase tracking-wider flex-shrink-0">
                  Table of Contents
                </h2>
                <div class="relative flex-1 min-h-0 overflow-hidden" style="flex: 1 1 0%; min-height: 0;">
                  <nav class="space-y-2 overflow-y-auto overflow-x-hidden toc-scrollbar" style="height: 100%; position: relative; scrollbar-width: none; -ms-overflow-style: none; mask-image: linear-gradient(to bottom, transparent 0%, black 20px, black calc(100% - 20px), transparent 100%); -webkit-mask-image: linear-gradient(to bottom, transparent 0%, black 20px, black calc(100% - 20px), transparent 100%);">
                    <style>
                      :global(nav.toc-scrollbar) {
                        scrollbar-width: none !important;
                        -ms-overflow-style: none !important;
                      }
                      :global(nav.toc-scrollbar::-webkit-scrollbar) {
                        display: none !important;
                        width: 0 !important;
                        height: 0 !important;
                        background: transparent !important;
                      }
                      :global(nav.toc-scrollbar::-webkit-scrollbar-track) {
                        display: none !important;
                        background: transparent !important;
                      }
                      :global(nav.toc-scrollbar::-webkit-scrollbar-thumb) {
                        display: none !important;
                        background: transparent !important;
                      }
                    </style>
                    <div class="py-2">
                    {#each headingTree as node (node.id)}
                      {@const hasChildren = node.children.length > 0}
                      {@const isExpanded = expandedHeadings.has(node.id)}
                      {@const isActive = activeHeading === node.id}
                      <div>
                        <div class="flex items-center group">
                          <button
                            on:click={() => scrollToHeading(node.id)}
                            class="flex-1 text-left text-sm transition-colors duration-200 rounded-lg px-3 py-2 {isActive ? 'text-visir-primary bg-visir-primary/10 font-medium' : 'text-visir-text-muted hover:text-visir-text hover:bg-visir-surface/10'}"
                            style="padding-left: {(node.level - 1) * 6}px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 100%;"
                          >
                            {node.text}
                          </button>
                          {#if hasChildren}
                            <button
                              on:click|stopPropagation={() => toggleExpanded(node.id)}
                              class="flex-shrink-0 w-5 h-5 flex items-center justify-center rounded hover:bg-visir-surface/20 transition-colors"
                              aria-label={isExpanded ? 'Collapse' : 'Expand'}
                            >
                              {#if isExpanded}
                                <Icon name="ChevronDown" size={12} className="text-visir-text-muted" />
                              {:else}
                                <Icon name="ChevronRight" size={12} className="text-visir-text-muted" />
                              {/if}
                            </button>
                          {/if}
                        </div>
                        {#if hasChildren && isExpanded}
                          <div class="ml-3">
                            {#each node.children as child (child.id)}
                              {@const hasChildChildren = child.children.length > 0}
                              {@const isChildExpanded = expandedHeadings.has(child.id)}
                              {@const isChildActive = activeHeading === child.id}
                              <div>
                                <div class="flex items-center group">
                                  <button
                                    on:click={() => scrollToHeading(child.id)}
                                    class="flex-1 text-left text-sm transition-colors duration-200 rounded-lg px-3 py-2 {isChildActive ? 'text-visir-primary bg-visir-primary/10 font-medium' : 'text-visir-text-muted hover:text-visir-text hover:bg-visir-surface/10'}"
                                    style="padding-left: {(child.level - 1) * 6}px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 100%;"
                                  >
                                    {child.text}
                                  </button>
                                  {#if hasChildChildren}
                                    <button
                                      on:click|stopPropagation={() => toggleExpanded(child.id)}
                                      class="flex-shrink-0 w-5 h-5 flex items-center justify-center rounded hover:bg-visir-surface/20 transition-colors"
                                      aria-label={isChildExpanded ? 'Collapse' : 'Expand'}
                                    >
                                      {#if isChildExpanded}
                                        <Icon name="ChevronDown" size={12} className="text-visir-text-muted" />
                                      {:else}
                                        <Icon name="ChevronRight" size={12} className="text-visir-text-muted" />
                                      {/if}
                                    </button>
                                  {/if}
                                </div>
                                {#if hasChildChildren && isChildExpanded}
                                  <div class="ml-3">
                                    {#each child.children as grandchild (grandchild.id)}
                                      {@const isGrandchildActive = activeHeading === grandchild.id}
                                      <button
                                        on:click={() => scrollToHeading(grandchild.id)}
                                        class="flex-1 text-left text-sm transition-colors duration-200 rounded-lg px-3 py-2 {isGrandchildActive ? 'text-visir-primary bg-visir-primary/10 font-medium' : 'text-visir-text-muted hover:text-visir-text hover:bg-visir-surface/10'}"
                                        style="padding-left: {(grandchild.level - 1) * 6}px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 100%;"
                                      >
                                        {grandchild.text}
                                      </button>
                                    {/each}
                                  </div>
                                {/if}
                              </div>
                            {/each}
                          </div>
                        {/if}
                      </div>
                    {/each}
                    </div>
                  </nav>
                </div>
              </div>
            </div>
          </aside>
        {/if}

        <!-- Main Content -->
        <div class="flex-1 min-w-0">
          <div class="max-w-4xl mx-auto">
            <!-- Back Button -->
            <a href="/blog" use:link class="inline-flex items-center gap-2 text-visir-text-muted hover:text-visir-text transition-colors mb-8">
              <Icon name="ArrowLeft" size={18} />
              <span>Back to Blog</span>
            </a>

            <!-- Header -->
            <div class="mb-12">
              <div class="mb-6">
                <span class="px-3 py-1 rounded-full bg-visir-primary/10 text-visir-primary text-xs font-medium border border-visir-primary/20">
                  {post.category}
                </span>
              </div>
              <h1 class="text-4xl sm:text-5xl font-medium font-display tracking-tight text-visir-text mb-6">
                {post.title}
              </h1>
              <div class="flex items-center gap-6 text-sm text-visir-text-muted mb-8">
                <div class="flex items-center gap-2">
                  {#if post.author === 'Ryan Lee'}
                    <img src={ryanProfile} alt={post.author} class="w-8 h-8 rounded-full object-cover" />
                  {:else}
                    <div class="w-8 h-8 rounded-full bg-visir-surface flex items-center justify-center">
                      <Icon name="User" size={16} className="text-visir-text-muted"/>
                    </div>
                  {/if}
                  <span>{post.author}</span>
                </div>
                <div class="flex items-center gap-1">
                  <Icon name="Calendar" size={14} />
                  <span>{formatDate(post.date)}</span>
                </div>
                <div class="flex items-center gap-1">
                  <Icon name="Clock" size={14} />
                  <span>{post.readTime}</span>
                </div>
              </div>
              {#if post.image}
                <img src={post.image} alt={post.title} class="w-full h-64 object-cover rounded-2xl mb-8" />
              {/if}
            </div>

            <!-- Content -->
            <article class="markdown-content">
              <SvelteMarkdown source={post.content} remarkPlugins={[remarkGfm]} />
            </article>
          </div>
        </div>
      </div>
    </div>
  </div>
{:else}
  <div class="pt-32 pb-24 min-h-screen flex items-center justify-center">
    <div class="text-center">
      <h1 class="text-2xl font-display text-visir-text mb-4">Post not found</h1>
      <a href="/blog" use:link class="text-visir-primary hover:underline">Back to Blog</a>
    </div>
  </div>
{/if}
