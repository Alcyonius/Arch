#!/usr/bin/env bash
set -euo pipefail

# -------------------------
# CONFIG
# -------------------------
REPO_NAME="Arch"
GITHUB_USER="Alcyonius"
REMOTE="git@github.com:$GITHUB_USER/$REPO_NAME.git"
FEATURE_BRANCHES=("feature/login" "feature/setup" "feature/cleanup")

# -------------------------
# INIT REPO
# -------------------------
if [ ! -d ".git" ]; then
    echo "📦 Initialising Git repo..."
    git init
fi

# -------------------------
# Add remote if missing
# -------------------------
if ! git remote | grep -q origin; then
    git remote add origin "$REMOTE"
    echo "🔗 Remote added: $REMOTE"
fi

# -------------------------
# Ensure main branch
# -------------------------
git checkout -B main

# Add + commit everything if needed
git add -A
if ! git diff --cached --quiet; then
    git commit -m "Initial commit"
else
    echo "✓ Nothing to commit"
fi

# Push main (force if needed)
git push -u origin main --force

# -------------------------
# Create dev branch
# -------------------------
git checkout -B dev
git push -u origin dev --force

# -------------------------
# Create feature branches
# -------------------------
for f in "${FEATURE_BRANCHES[@]}"; do
    git checkout -B "$f"
    git push -u origin "$f" --force
done

# -------------------------
# Set tracking upstream
# -------------------------
git branch --set-upstream-to=origin/main main || true

echo "✅ Branch setup complete!"
echo "Branches now on GitHub:"
git branch -a
echo ""
echo "🎯 GitHub Actions will auto-create PRs for dev & feature/* branches."
