<script lang="ts">
  import Icon from '../components/Icon.svelte';
  // FontAwesome icons are not used - using SVG icons instead
  import Button from '../components/Button.svelte';

  function handleDownload(url: string) {
    // Create a temporary anchor element and click it to trigger browser's native download
    const link = document.createElement('a');
    link.href = url;
    link.style.display = 'none';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  }

  // Import rn.shtml at build time to get the latest version
  const rnModule = import.meta.glob('../rn.shtml', { 
    as: 'raw',
    eager: true 
  }) as Record<string, string>;

  // Parse version from rn.shtml (first version header)
  function getLatestVersion(): string {
    const rnPath = Object.keys(rnModule)[0];
    const content = rnPath ? rnModule[rnPath] : null;
    
    if (!content) {
      return import.meta.env.VITE_APP_VERSION || '2.0.0'; // fallback
    }
    
    // Match first version header (h3 or h4)
    const versionMatch = content.match(/<h[34]>(Version[^<]+)<\/h[34]>/);
    if (versionMatch) {
      // Extract version number (e.g., "Version 2.0.0+1010" -> "2.0.0")
      const fullVersion = versionMatch[1].replace(/Version\s+/i, '').trim();
      // Return only the part before "+"
      return fullVersion.split('+')[0];
    }
    
    return import.meta.env.VITE_APP_VERSION || '2.0.0'; // fallback
  }

  const latestVersion = getLatestVersion();
</script>

<div class="pt-32 pb-24 min-h-screen relative">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center relative z-10">
    
    <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-visir-surface/30 border border-visir-outline/20 text-visir-primary text-xs font-medium uppercase tracking-wide mb-8 backdrop-blur-xl">
      <Icon name="Download" size={14} />
      <span class="font-display tracking-wide">Version {latestVersion} Live</span>
    </div>

    <h1 class="text-4xl sm:text-6xl font-medium font-display tracking-tight text-visir-text mb-6">
      Download Visir
    </h1>
    <p class="text-xl text-visir-text-muted max-w-2xl mx-auto mb-16 font-light">
      The command center for high-performance professionals. <br/>
      Available on all your devices.
    </p>

    <div class="max-w-4xl mx-auto">
      <!-- Desktop Section Title -->
      <div class="text-left mb-6 ml-1">
        <h2 class="text-lg font-semibold text-visir-text font-display">Desktop</h2>
      </div>

      <!-- Desktop Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-16">
        <!-- macOS -->
        <div class="group relative p-8 rounded-3xl bg-visir-surface/10 hover:bg-visir-surface/20 backdrop-blur-xl border-2 border-white/10 dark:border-white/10 hover:border-black/60 dark:hover:border-white/40 transition-all duration-300 text-left shadow-lg hover:shadow-xl hover:shadow-black/20 dark:hover:shadow-white/20 cursor-pointer">
          <div class="relative z-10">
            <div class="w-12 h-12 rounded-2xl bg-black dark:bg-white text-white dark:text-black flex items-center justify-center mb-6 shadow-md">
              <svg class="w-6 h-6" viewBox="0 0 24 24" fill="currentColor">
                <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-1.02.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
              </svg>
            </div>
            <h3 class="text-2xl font-semibold font-display text-visir-text mb-2">macOS</h3>
            <p class="text-visir-text-muted font-light text-sm mb-6">Requires macOS 11.0 or later.</p>
            
            <div class="flex flex-col gap-3 mb-6">
              <button 
                type="button"
                on:click={() => handleDownload('https://visir.pro/release/visir-setup.zip')}
              >
                <Button variant="primary" className="w-full justify-center">
                  <span>Download for macOS</span>
                </Button>
              </button>
            </div>

            <!-- Installation Steps -->
            <div class="border-t border-white/10 pt-6 space-y-4">
              <h4 class="text-sm font-semibold text-visir-text mb-3">Installation Steps:</h4>
              <div class="space-y-3">
                <div class="flex items-start gap-3">
                  <div class="flex-shrink-0 w-6 h-6 rounded-full bg-visir-surface/30 border border-white/10 flex items-center justify-center text-xs font-semibold text-visir-text">
                    1
                  </div>
                  <p class="text-sm text-visir-text-muted font-light leading-relaxed">
                    <button 
                      type="button"
                      on:click={() => handleDownload('https://visir.pro/release/visir-setup.zip')}
                      class="text-visir-primary hover:underline font-medium cursor-pointer bg-transparent border-none p-0"
                    >Download</button> the ZIP file
                  </p>
                </div>
                <div class="flex items-start gap-3">
                  <div class="flex-shrink-0 w-6 h-6 rounded-full bg-visir-surface/30 border border-white/10 flex items-center justify-center text-xs font-semibold text-visir-text">
                    2
                  </div>
                  <p class="text-sm text-visir-text-muted font-light leading-relaxed">
                    Unzip the downloaded file
                  </p>
                </div>
                <div class="flex items-start gap-3">
                  <div class="flex-shrink-0 w-6 h-6 rounded-full bg-visir-surface/30 border border-white/10 flex items-center justify-center text-xs font-semibold text-visir-text">
                    3
                  </div>
                  <p class="text-sm text-visir-text-muted font-light leading-relaxed">
                    Move the Visir file to the Applications folder
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Windows -->
        <div class="group relative p-8 rounded-3xl bg-visir-surface/10 hover:bg-visir-surface/20 backdrop-blur-xl border-2 border-white/10 hover:border-blue-500/50 transition-all duration-300 text-left shadow-lg hover:shadow-xl hover:shadow-blue-500/10 cursor-pointer">
          <div class="relative z-10">
            <div class="w-12 h-12 rounded-2xl bg-[#0078D4] text-white flex items-center justify-center mb-6 shadow-md">
              <svg class="w-6 h-6" viewBox="0 0 24 24" fill="currentColor">
                <path d="M3 12V6.75l6-1.32v6.48L3 12zm17-9v8.75l-10 .15V5.21L20 3zM3 13l6 .09v7.81l-6-1.15V13zm17 .25V22l-10-1.8v-7.15l10 .2z"/>
              </svg>
            </div>
            <h3 class="text-2xl font-semibold font-display text-visir-text mb-2">Windows</h3>
            <p class="text-visir-text-muted font-light text-sm mb-6">Windows 10 and 11 supported.</p>
            
            <div class="flex flex-col gap-3 mb-6">
              <button 
                type="button"
                on:click={() => handleDownload('https://visir.pro/release/visir-setup.exe')}
              >
                <Button variant="primary" className="w-full justify-center">
                  <span>Download for Windows</span>
                </Button>
              </button>
            </div>

            <!-- Installation Steps -->
            <div class="border-t border-white/10 pt-6 space-y-4">
              <h4 class="text-sm font-semibold text-visir-text mb-3">Installation Steps:</h4>
              <div class="space-y-3">
                <div class="flex items-start gap-3">
                  <div class="flex-shrink-0 w-6 h-6 rounded-full bg-visir-surface/30 border border-white/10 flex items-center justify-center text-xs font-semibold text-visir-text">
                    1
                  </div>
                  <p class="text-sm text-visir-text-muted font-light leading-relaxed">
                    <button 
                      type="button"
                      on:click={() => handleDownload('https://visir.pro/release/visir-setup.exe')}
                      class="text-visir-primary hover:underline font-medium cursor-pointer bg-transparent border-none p-0"
                    >Download</button> the EXE file
                  </p>
                </div>
                <div class="flex items-start gap-3">
                  <div class="flex-shrink-0 w-6 h-6 rounded-full bg-visir-surface/30 border border-white/10 flex items-center justify-center text-xs font-semibold text-visir-text">
                    2
                  </div>
                  <p class="text-sm text-visir-text-muted font-light leading-relaxed">
                    Run the installer
                  </p>
                </div>
                <div class="flex items-start gap-3">
                  <div class="flex-shrink-0 w-6 h-6 rounded-full bg-visir-surface/30 border border-white/10 flex items-center justify-center text-xs font-semibold text-visir-text">
                    3
                  </div>
                  <p class="text-sm text-visir-text-muted font-light leading-relaxed">
                    Follow the installation wizard
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Mobile Section Title -->
      <div class="text-left mb-6 ml-1">
        <h2 class="text-lg font-semibold text-visir-text font-display">Mobile App</h2>
      </div>

      <!-- Mobile Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <!-- iOS -->
        <div class="group relative p-8 rounded-3xl bg-visir-surface/10 hover:bg-visir-surface/20 backdrop-blur-xl border-2 border-white/10 dark:border-white/10 hover:border-black/60 dark:hover:border-white/40 transition-all duration-300 text-left flex flex-col md:flex-row gap-6 items-center md:items-start shadow-lg hover:shadow-xl hover:shadow-black/20 dark:hover:shadow-white/20 cursor-pointer">
          <div class="flex-1 w-full relative z-10">
            <div class="w-12 h-12 rounded-2xl bg-black dark:bg-white text-white dark:text-black flex items-center justify-center mb-6 shadow-md">
              <svg class="w-6 h-6" viewBox="0 0 24 24" fill="currentColor">
                <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-1.02.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
              </svg>
            </div>
            <h3 class="text-2xl font-semibold font-display text-visir-text mb-2">iOS</h3>
            <p class="text-visir-text-muted font-light text-sm mb-6">Capture tasks and view your schedule on the go.</p>
            <a href="https://apps.apple.com/kr/app/id6471948579" target="_blank" rel="noopener noreferrer">
              <Button variant="outline" className="w-full justify-center group text-sm">
                App Store
              </Button>
            </a>
          </div>
          <!-- QR Code -->
          <div class="bg-white p-3 rounded-xl border-2 border-white/20 shadow-lg shrink-0 relative z-10">
            <img src="https://api.qrserver.com/v1/create-qr-code/?size=120x120&data=https://apps.apple.com/kr/app/id6471948579" alt="iOS QR Code" class="w-28 h-28 mix-blend-multiply opacity-90" />
            <p class="text-[10px] text-black/60 text-center mt-2 font-medium uppercase tracking-wide">Scan to Install</p>
          </div>
        </div>

        <!-- Android -->
        <div class="group relative p-8 rounded-3xl bg-visir-surface/10 hover:bg-visir-surface/20 backdrop-blur-xl border-2 border-white/10 hover:border-green-500/50 transition-all duration-300 text-left flex flex-col md:flex-row gap-6 items-center md:items-start shadow-lg hover:shadow-xl hover:shadow-green-500/10 cursor-pointer">
          <div class="flex-1 w-full relative z-10">
            <div class="w-12 h-12 rounded-2xl bg-[#3DDC84] text-black flex items-center justify-center mb-6 shadow-md">
              <svg class="w-6 h-6" viewBox="0 0 24 24" fill="currentColor">
                <path d="M17.523 15.3414c-.5511 0-.9993-.4486-.9993-.9997s.4482-.9993.9993-.9993c.5506 0 .9993.4486.9993.9993.0001.5511-.4486.9997-.9993.9997m-11.046 0c-.5511 0-.9993-.4486-.9993-.9997s.4482-.9993.9993-.9993c.5506 0 .9993.4486.9993.9993 0 .5511-.4486.9997-.9993.9997m11.4045-6.02l1.9973-3.4592a.416.416 0 00-.1521-.5676.416.416 0 00-.5676.1521l-2.0223 3.503C15.5902 8.2439 13.8533 7.8508 12 7.8508s-3.5902.3931-5.1349 1.1157L4.8429 5.4634a.4161.4161 0 00-.5676-.1521.4157.4157 0 00-.1521.5676l1.9973 3.4592C2.6889 11.186.8532 13.2177.8532 15.7404v.9225c0 .2768.2232.5.5.5h22.2931c.2768 0 .5-.2232.5-.5v-.9225c0-2.5227-1.8357-4.5537-4.2687-5.419"/>
              </svg>
            </div>
            <h3 class="text-2xl font-semibold font-display text-visir-text mb-2">Android</h3>
            <p class="text-visir-text-muted font-light text-sm mb-6">Your pocket executive assistant.</p>
            <a href="https://play.google.com/store/apps/details?id=com.wavetogether.fillin" target="_blank" rel="noopener noreferrer">
              <Button variant="outline" className="w-full justify-center group text-sm">
                Google Play
              </Button>
            </a>
          </div>
          <!-- QR Code -->
          <div class="bg-white p-3 rounded-xl border-2 border-white/20 shadow-lg shrink-0 relative z-10">
            <img src="https://api.qrserver.com/v1/create-qr-code/?size=120x120&data=https://play.google.com/store/apps/details?id=com.wavetogether.fillin" alt="Android QR Code" class="w-28 h-28 mix-blend-multiply opacity-90" />
            <p class="text-[10px] text-black/60 text-center mt-2 font-medium uppercase tracking-wide">Scan to Install</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
