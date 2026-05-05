#!/usr/bin/env bash
set -e

REPO_NAME="Arch"
GITHUB_USER="Alcyonius"
REMOTE="git@github.com:$GITHUB_USER/$REPO_NAME.git"

echo "🚀 Setting up Git repo..."

cd ~/scripts

# -----------------------------
# Init repo if missing
# -----------------------------
if [ ! -d ".git" ]; then
  echo "📦 Initialising repo..."
  git init
fi

# -----------------------------
# Ensure main branch
# -----------------------------
git branch -M main

# -----------------------------
# Add remote if missing
# -----------------------------
if ! git remote | grep -q origin; then
  echo "🔗 Adding remote..."
  git remote add origin "$REMOTE"
else
  echo "✓ Remote already exists"
fi

# -----------------------------
# Add + commit (if needed)
# -----------------------------
git add -A

if ! git diff --cached --quiet; then
  git commit -m "Auto commit: setup/update"
else
  echo "✓ Nothing to commit"
fi

# -----------------------------
# Create branches
# -----------------------------
echo "🌿 Creating branches..."

git branch dev 2>/dev/null || echo "✓ dev exists"
git branch staging 2>/dev/null || echo "✓ staging exists"

# -----------------------------
# Push main (handle first push)
# -----------------------------
echo "📤 Pushing main..."

git push -u origin main || git push -u origin main --force

# -----------------------------
# Push other branches
# -----------------------------
git push origin dev || true
git push origin staging || true

# -----------------------------
# Set upstream tracking
# -----------------------------
git branch --set-upstream-to=origin/main main || true

echo "✅ Git setup complete!"
