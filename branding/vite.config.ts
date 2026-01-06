import path from 'path';
import { defineConfig, loadEnv, Plugin } from 'vite';
import { svelte } from '@sveltejs/vite-plugin-svelte';
import { VitePWA } from 'vite-plugin-pwa';
import { partytownVite } from '@qwik.dev/partytown/utils';
import { readFileSync, copyFileSync, existsSync, mkdirSync, readdirSync, statSync, writeFileSync } from 'fs';

// Read version from pubspec.yaml
function getVersionFromPubspec(): string {
  try {
    const pubspecPath = path.resolve(__dirname, '..', 'pubspec.yaml');
    const pubspecContent = readFileSync(pubspecPath, 'utf-8');
    const versionMatch = pubspecContent.match(/^version:\s*(.+)$/m);
    if (versionMatch) {
      // Extract version number (e.g., "1.0.45+988" -> "1.0.45")
      const version = versionMatch[1].split('+')[0];
      return version;
    }
  } catch (error) {
    console.warn('⚠️  Could not read version from pubspec.yaml:', error);
  }
  return '2.4.0'; // fallback version
}

// Plugin to make CSS non-render-blocking
function nonBlockingCSS(): Plugin {
  return {
    name: 'non-blocking-css',
    transformIndexHtml(html) {
      // Make CSS links non-render-blocking by using media="print" trick
      return html.replace(
        /<link([^>]*rel=["']stylesheet["'][^>]*)>/gi,
        (match, attrs) => {
          // Skip if already has onload or media attribute
          if (attrs.includes('onload') || attrs.includes('media=')) {
            return match;
          }
          // Add media="print" and onload to make it non-blocking
          return `<link${attrs} media="print" onload="this.media='all'; this.onload=null;"><noscript>${match}</noscript>`;
        }
      );
    },
  };
}

// Plugin to copy release folder and rn.shtml to dist
function copyReleaseFiles(): Plugin {
  return {
    name: 'copy-release-files',
    configureServer(server) {
      // Serve rn.shtml in development
      const rootDir = __dirname;
      const rnShtmlSource = path.join(rootDir, 'rn.shtml');
      
      server.middlewares.use('/rn.shtml', (req, res, next) => {
        if (existsSync(rnShtmlSource)) {
          const content = readFileSync(rnShtmlSource, 'utf-8');
          res.setHeader('Content-Type', 'text/html');
          res.end(content);
        } else {
          next();
        }
      });
    },
    writeBundle() {
      const rootDir = __dirname;
      const distDir = path.join(rootDir, 'dist');
      const releaseSource = path.join(rootDir, 'release');
      const releaseDest = path.join(distDir, 'release');
      const rnShtmlSource = path.join(rootDir, 'rn.shtml');
      const rnShtmlDest = path.join(distDir, 'rn.shtml');

      // Copy release folder
      if (existsSync(releaseSource)) {
        console.log('📦 Copying release folder to dist...');
        if (!existsSync(releaseDest)) {
          mkdirSync(releaseDest, { recursive: true });
        }
        
        const files = readdirSync(releaseSource);
        for (const file of files) {
          const sourcePath = path.join(releaseSource, file);
          const destPath = path.join(releaseDest, file);
          const stat = statSync(sourcePath);
          
          if (stat.isFile()) {
            copyFileSync(sourcePath, destPath);
            console.log(`  ✓ Copied ${file}`);
          }
        }
      } else {
        console.warn('⚠️  Release folder not found');
      }

      // Copy rn.shtml file
      if (existsSync(rnShtmlSource)) {
        console.log('📄 Copying rn.shtml to dist...');
        copyFileSync(rnShtmlSource, rnShtmlDest);
        console.log('  ✓ Copied rn.shtml');
      } else {
        console.warn('⚠️  rn.shtml file not found');
      }

      // Copy appcast files
      const appcastFiles = ['appcast-beta.xml', 'appcast.xml'];
      for (const appcastFile of appcastFiles) {
        const appcastSource = path.join(rootDir, appcastFile);
        const appcastDest = path.join(distDir, appcastFile);
        if (existsSync(appcastSource)) {
          console.log(`📄 Copying ${appcastFile} to dist...`);
          copyFileSync(appcastSource, appcastDest);
          console.log(`  ✓ Copied ${appcastFile}`);
        } else {
          console.warn(`⚠️  ${appcastFile} file not found`);
        }
      }
    }
  };
}

export default defineConfig(({ mode }) => {
    const env = loadEnv(mode, '.', '');
    const appVersion = getVersionFromPubspec();
    return {
      server: {
        port: 3000,
        host: '0.0.0.0',
      },
      plugins: [
        svelte(),
        nonBlockingCSS(),
        copyReleaseFiles(),
        VitePWA({
          registerType: 'autoUpdate',
          includeAssets: ['favicon.ico', 'apple-touch-icon.png', 'mask-icon.svg'],
          workbox: {
            globPatterns: ['**/*.{js,css,html,ico,png,svg,webp}'],
            globIgnores: ['**/*.{webm,mp4}'], // Exclude large video files from precache
            maximumFileSizeToCacheInBytes: 5 * 1024 * 1024, // 5MB limit
            runtimeCaching: [
              {
                urlPattern: /^https:\/\/fonts\.googleapis\.com\/.*/i,
                handler: 'CacheFirst',
                options: {
                  cacheName: 'google-fonts-stylesheets',
                  expiration: {
                    maxEntries: 10,
                    maxAgeSeconds: 60 * 60 * 24 * 365 // 1 year
                  },
                  cacheableResponse: {
                    statuses: [0, 200]
                  }
                }
              },
              {
                urlPattern: /^https:\/\/fonts\.gstatic\.com\/.*/i,
                handler: 'CacheFirst',
                options: {
                  cacheName: 'google-fonts-webfonts',
                  expiration: {
                    maxEntries: 10,
                    maxAgeSeconds: 60 * 60 * 24 * 365 // 1 year
                  },
                  cacheableResponse: {
                    statuses: [0, 200]
                  }
                }
              },
              {
                urlPattern: /\.(?:png|jpg|jpeg|webp|svg|gif)$/,
                handler: 'CacheFirst',
                options: {
                  cacheName: 'images',
                  expiration: {
                    maxEntries: 100,
                    maxAgeSeconds: 60 * 60 * 24 * 30 // 30 days
                  }
                }
              },
              {
                urlPattern: /\.(?:webm|mp4)$/,
                handler: 'CacheFirst',
                options: {
                  cacheName: 'videos',
                  expiration: {
                    maxEntries: 10,
                    maxAgeSeconds: 60 * 60 * 24 * 7 // 7 days
                  }
                }
              },
              {
                urlPattern: /^https:\/\/cdn\.jsdelivr\.net\/.*/i,
                handler: 'NetworkFirst',
                options: {
                  cacheName: 'jsdelivr-cdn',
                  expiration: {
                    maxEntries: 10,
                    maxAgeSeconds: 60 * 60 * 24 // 1 day
                  },
                  networkTimeoutSeconds: 3
                }
              }
            ]
          },
          manifest: {
            name: 'Visir - All-in-one Workspace',
            short_name: 'Visir',
            description: 'Visir connects your email, calendar, and chats into one intelligent timeline.',
            theme_color: '#1C1C1B',
            background_color: '#1C1C1B',
            id: '/',
            icons: [
              {
                src: '/assets/visir/visir_foreground.png',
                sizes: '192x192',
                type: 'image/png'
              },
              {
                src: '/assets/visir/visir_foreground.png',
                sizes: '512x512',
                type: 'image/png'
              }
            ]
          }
        }),
        partytownVite({
          dest: path.join(__dirname, 'dist', '~partytown')
        })
      ],
      define: {
        'process.env.API_KEY': JSON.stringify(env.GEMINI_API_KEY),
        'process.env.GEMINI_API_KEY': JSON.stringify(env.GEMINI_API_KEY),
        'import.meta.env.VITE_APP_VERSION': JSON.stringify(appVersion),
        'import.meta.env.VITE_GA4_ID': JSON.stringify(env.VITE_GA4_ID || ''),
      },
      resolve: {
        alias: {
          '@': path.resolve(__dirname, '.'),
        }
      },
      build: {
        rollupOptions: {
          output: {
            manualChunks: (id) => {
              // Svelte core
              if (id.includes('svelte') && !id.includes('node_modules')) {
                return 'svelte-core';
              }
              // Vendor chunks - more granular splitting
              if (id.includes('node_modules')) {
                if (id.includes('svelte') && !id.includes('svelte-spa-router')) {
                  return 'svelte-vendor';
                }
                if (id.includes('iconsax-svelte')) {
                  return 'icons-vendor';
                }
                if (id.includes('@fortawesome')) {
                  return 'fontawesome-vendor';
                }
                if (id.includes('@humanspeak') || id.includes('remark')) {
                  return 'markdown-vendor';
                }
                if (id.includes('@supabase')) {
                  return 'supabase-vendor';
                }
                if (id.includes('svelte-spa-router')) {
                  return 'router-vendor';
                }
                // Other node_modules
                return 'vendor';
              }
            },
            // Optimize chunk names for better caching
            chunkFileNames: 'assets/[name]-[hash].js',
            entryFileNames: 'assets/[name]-[hash].js',
            assetFileNames: (assetInfo) => {
              // Exclude large PNG files that have WebP alternatives
              if (assetInfo.name?.includes('visir_foreground') && assetInfo.name?.endsWith('.png')) {
                // Keep PNG for favicon, but don't duplicate in images folder
                if (assetInfo.name.includes('/visir/')) {
                  return 'assets/visir/[name]-[hash][extname]';
                }
              }
              if (assetInfo.name?.endsWith('.webp') || assetInfo.name?.endsWith('.png') || assetInfo.name?.endsWith('.jpg')) {
                return 'assets/images/[name]-[hash][extname]';
              }
              if (assetInfo.name?.endsWith('.webm') || assetInfo.name?.endsWith('.mp4')) {
                return 'assets/videos/[name]-[hash][extname]';
              }
              return 'assets/[name]-[hash][extname]';
            },
          },
        },
        chunkSizeWarningLimit: 600,
        minify: 'esbuild',
        cssMinify: true,
        sourcemap: false,
        target: 'esnext',
        assetsInlineLimit: 4096, // Inline assets smaller than 4kb
        reportCompressedSize: false, // Faster builds
        // Enable tree shaking
        treeshake: {
          moduleSideEffects: 'no-external',
        },
      },
    };
});
