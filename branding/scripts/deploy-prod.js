#!/usr/bin/env node

/**
 * Production deployment script
 * Checks for environment variables and builds/deploys
 * Usage: npm run deploy:prod -- --url=YOUR_URL --key=YOUR_KEY
 * Or: VITE_SUPABASE_URL=url VITE_SUPABASE_ANON_KEY=key npm run deploy:prod
 */

import { execSync } from 'child_process';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { existsSync, readFileSync } from 'fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const rootDir = join(__dirname, '..');

// Parse command line arguments (support both --url=... and positional args)
const args = process.argv.slice(2);
let urlArg = args.find(arg => arg.startsWith('--url='))?.split('=')[1];
let keyArg = args.find(arg => arg.startsWith('--key='))?.split('=')[1];
let ga4Arg = args.find(arg => arg.startsWith('--ga4='))?.split('=')[1];

// Support positional arguments: npm run deploy:prod url key [ga4id]
if (!urlArg && args[0] && !args[0].startsWith('--')) {
  urlArg = args[0];
  keyArg = args[1];
  ga4Arg = args[2];
}

// Get environment variables from args, process.env, or .env file
let supabaseUrl = urlArg || process.env.VITE_SUPABASE_URL;
let supabaseKey = keyArg || process.env.VITE_SUPABASE_ANON_KEY;
let ga4Id = ga4Arg || process.env.VITE_GA4_ID;

console.log('🔍 Checking environment variables...');

// If not provided via args or env, check .env file
if (!supabaseUrl || !supabaseKey) {
  const envPath = join(rootDir, '.env');
  if (existsSync(envPath)) {
    console.log('✅ Using .env file');
    // Vite will automatically load .env file during build
    // No need to manually parse it
  } else {
    console.error('❌ Error: Environment variables not set');
    console.error('\nPlease provide environment variables in one of these ways:');
    console.error('  1. npm run dp (with .env file)');
    console.error('  2. npm run dp url key [ga4id]');
    console.error('  3. VITE_SUPABASE_URL=url VITE_SUPABASE_ANON_KEY=key VITE_GA4_ID=G-XXX npm run dp');
    console.error('  4. Create a .env file with VITE_SUPABASE_URL, VITE_SUPABASE_ANON_KEY, and VITE_GA4_ID');
    process.exit(1);
  }
} else {
  console.log('✅ Using environment variables from command line or shell');
  // Set environment variables for build
  process.env.VITE_SUPABASE_URL = supabaseUrl;
  process.env.VITE_SUPABASE_ANON_KEY = supabaseKey;
}

// Check for GA4 ID (from .env file or environment variable)
if (!ga4Id) {
  // Try to read from .env file if it exists
  const envPath = join(rootDir, '.env');
  if (existsSync(envPath)) {
    // Vite will load it automatically, but we can check if it's set
    const envContent = readFileSync(envPath, 'utf-8');
    const ga4Match = envContent.match(/VITE_GA4_ID=(.+)/);
    if (ga4Match) {
      ga4Id = ga4Match[1].trim();
    }
  }
}

if (ga4Id) {
  console.log('✅ GA4 ID found:', ga4Id.replace(/G-([A-Z0-9]{10})/, 'G-******'));
  process.env.VITE_GA4_ID = ga4Id;
} else {
  console.warn('⚠️  VITE_GA4_ID not set. GA4 tracking will be disabled.');
  console.warn('   You can set it in .env file or as an environment variable.');
}

console.log('\n🏗️  Building project...');
try {
  execSync('npm run build', { 
    stdio: 'inherit',
    cwd: rootDir,
    env: { ...process.env }
  });
} catch (error) {
  console.error('❌ Build failed');
  process.exit(1);
}

console.log('\n🚀 Deploying to Firebase...');
try {
  execSync('firebase deploy --only hosting:visir-app', {
    stdio: 'inherit',
    cwd: join(rootDir, '..'),
    env: { ...process.env }
  });
  console.log('\n✅ Deployment complete!');
} catch (error) {
  console.error('❌ Deployment failed');
  process.exit(1);
}

