#!/bin/bash

# Build script that checks for environment variables
# Usage: ./scripts/build-with-env.sh

set -e

echo "🔍 Checking environment variables..."

if [ -z "$VITE_SUPABASE_URL" ] || [ -z "$VITE_SUPABASE_ANON_KEY" ]; then
  if [ ! -f .env ]; then
    echo "❌ Error: .env file not found and environment variables not set"
    echo "Please either:"
    echo "  1. Create a .env file with VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY"
    echo "  2. Or set environment variables before running this script"
    exit 1
  fi
  echo "✅ Using .env file"
else
  echo "✅ Using environment variables from shell"
fi

echo "🏗️  Building project..."
npm run build

echo "✅ Build complete!"

