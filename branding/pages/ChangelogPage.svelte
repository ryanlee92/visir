<script lang="ts">
  import Icon from '../components/Icon.svelte';

  interface ChangelogEntry {
    version: string;
    sections: {
      platform: string;
      items: string[];
    }[];
  }

  function parseReleaseNotes(htmlContent: string): ChangelogEntry[] {
    const entries: ChangelogEntry[] = [];
    // Support both <h3> and <h4> for version headers
    const versionRegex = /<h[34]>(Version[^<]+)<\/h[34]>([\s\S]*?)(?=<h[34]>Version|$)/g;
    let match;
    
    while ((match = versionRegex.exec(htmlContent)) !== null) {
      const version = match[1].trim();
      const content = match[2];
      const sections: { platform: string; items: string[] }[] = [];
      const sectionRegex = /<section>([\s\S]*?)<\/section>/g;
      let sectionMatch;
      
      while ((sectionMatch = sectionRegex.exec(content)) !== null) {
        const sectionContent = sectionMatch[1];
        const platformMatch = sectionContent.match(/<h4>([^<]+)<\/h4>/);
        if (!platformMatch) continue;
        
        const platform = platformMatch[1].trim();
        const items: string[] = [];
        const liRegex = /<li>([\s\S]*?)<\/li>/g;
        let liMatch;
        
        while ((liMatch = liRegex.exec(sectionContent)) !== null) {
          const itemText = liMatch[1]
            .replace(/<[^>]+>/g, '')
            .replace(/\s+/g, ' ')
            .trim();
          if (itemText) {
            items.push(itemText);
          }
        }
        
        if (items.length > 0) {
          sections.push({ platform, items });
        }
      }
      
      if (sections.length > 0) {
        entries.push({ version, sections });
      }
    }
    
    return entries;
  }

  // Import rn.shtml at build time - Vite will detect changes and rebuild
  const rnModule = import.meta.glob('../rn.shtml', { 
    as: 'raw',
    eager: true 
  }) as Record<string, string>;

  let changelogData: ChangelogEntry[] = [];
  let expandedVersions = new Set<string>();

  function loadChangelog() {
    const rnPath = Object.keys(rnModule)[0];
    const content = rnPath ? rnModule[rnPath] : null;
    
    if (!content) {
      console.warn('Changelog file not found. Available keys:', Object.keys(rnModule));
      changelogData = [];
      expandedVersions = new Set();
      return;
    }
    
    try {
      const parsed = parseReleaseNotes(content);
      console.log('Parsed changelog entries:', parsed.length);
      changelogData = parsed;
      if (parsed.length > 0) {
        expandedVersions = new Set([parsed[0].version]);
      }
    } catch (error) {
      console.error('Failed to parse changelog:', error);
      changelogData = [];
      expandedVersions = new Set();
    }
  }

  // Load changelog immediately (no async needed since it's eager loaded)
  loadChangelog();

  function toggleVersion(version: string) {
    expandedVersions = new Set(expandedVersions);
    if (expandedVersions.has(version)) {
      expandedVersions.delete(version);
    } else {
      expandedVersions.add(version);
    }
    expandedVersions = expandedVersions;
  }
</script>

<div class="pt-32 pb-24 min-h-screen">
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="text-center mb-12">
      <h1 class="text-4xl sm:text-6xl font-medium font-display tracking-tight text-visir-text mb-6">
        Changelog
      </h1>
      <p class="text-xl text-visir-text-muted max-w-2xl mx-auto font-light">
        See what's new in Visir. We ship updates regularly to improve your productivity.
      </p>
    </div>

    {#if changelogData.length === 0}
      <div class="text-center py-20">
        <p class="text-visir-text-muted">No changelog entries found.</p>
      </div>
    {:else}
      <div class="space-y-4">
        {#each changelogData as entry}
          <div class="rounded-3xl bg-white/10 dark:bg-white/5 border border-white/20 dark:border-white/10 backdrop-blur-xl shadow-lg overflow-hidden">
            <button
              on:click={() => toggleVersion(entry.version)}
              class="w-full p-6 flex items-center justify-between hover:bg-white/5 transition-colors"
            >
              <h2 class="text-2xl font-display font-medium text-visir-text">{entry.version}</h2>
              {#if expandedVersions.has(entry.version)}
                <Icon name="ChevronUp" size={20} className="text-visir-text-muted" />
            {:else}
                <Icon name="ChevronDown" size={20} className="text-visir-text-muted" />
              {/if}
            </button>
            
            {#if expandedVersions.has(entry.version)}
              <div class="px-6 pb-6 space-y-6">
                {#each entry.sections as section}
                  <div>
                    <h3 class="text-lg font-display font-medium text-visir-text mb-3">{section.platform}</h3>
                    <ul class="space-y-2 ml-4">
                      {#each section.items as item}
                        <li class="text-visir-text-muted font-light leading-relaxed flex items-start gap-2">
                          <span class="text-visir-primary mt-1">•</span>
                          <span>{item}</span>
                        </li>
                      {/each}
                    </ul>
                  </div>
                {/each}
              </div>
            {/if}
          </div>
        {/each}
      </div>
    {/if}
  </div>
</div>
