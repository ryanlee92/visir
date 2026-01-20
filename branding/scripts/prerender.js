import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import { launch } from 'puppeteer';

const __dirname = dirname(fileURLToPath(import.meta.url));
const distDir = join(__dirname, '..', 'dist');

// Routes to pre-render
const routes = [
  '/',
  '/pricing',
  '/download',
  '/blog',
  '/founders',
  '/developers',
  '/managers',
  '/personal',
  '/community',
  '/help',
  '/changelog',
  '/roadmap',
  '/feature-requests',
  '/privacy',
  '/terms',
  '/integrations',
];

async function prerender() {
  console.log('🚀 Starting pre-rendering...');

  const browser = await launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  try {
    for (const route of routes) {
      console.log(`📄 Pre-rendering ${route}...`);

      const page = await browser.newPage();
      const url = `http://localhost:4173${route}`;

      await page.goto(url, {
        waitUntil: 'networkidle0',
        timeout: 30000
      });

      // Wait for content to load
      await page.waitForSelector('#app', { timeout: 10000 });

      // Debug: Check if content is rendering
      const hasContent = await page.evaluate(() => {
        const app = document.querySelector('#app');
        console.log('App element:', app);
        console.log('App children:', app?.children.length);
        return app && app.children.length > 0;
      });

      if (!hasContent) {
        console.log('  ⚠️  Warning: App div is empty, waiting longer...');
        // Wait for any navbar or hero to appear as fallback
        try {
          await page.waitForSelector('nav, .hero, header', { timeout: 10000 });
          await page.evaluate(() => new Promise(resolve => setTimeout(resolve, 3000)));
        } catch (e) {
          console.log('  ⚠️  Warning: Could not find main content elements');
        }
      } else {
        // Additional wait for dynamic content
        await page.evaluate(() => new Promise(resolve => setTimeout(resolve, 2000)));
      }

      // Get the fully rendered HTML
      const html = await page.content();

      // Determine output path
      let outputPath;
      if (route === '/') {
        outputPath = join(distDir, 'index.html');
      } else {
        const routePath = join(distDir, route.slice(1));
        if (!existsSync(routePath)) {
          mkdirSync(routePath, { recursive: true });
        }
        outputPath = join(routePath, 'index.html');
      }

      // Write the pre-rendered HTML
      writeFileSync(outputPath, html, 'utf-8');
      console.log(`  ✓ Saved to ${outputPath}`);

      await page.close();
    }

    console.log('✅ Pre-rendering complete!');
  } catch (error) {
    console.error('❌ Pre-rendering failed:', error);
    process.exit(1);
  } finally {
    await browser.close();
  }
}

prerender();
