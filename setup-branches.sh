#!/usr/bin/env bash
set -e

# --- Config ---
MAIN_BRANCH="main"
DEV_BRANCH="dev"
FEATURE_PREFIX="feature"

# --- Ensure we are in git repo ---
if [ ! -d ".git" ]; then
    echo "No git repo found. Initializing..."
    git init
fi

# --- Setup remote ---
GIT_REMOTE_URL="git@github.com:YOUR_USERNAME/YOUR_REPO.git"

if ! git remote | grep -q origin; then
    git remote add origin "$GIT_REMOTE_URL"
    echo "Added remote origin: $GIT_REMOTE_URL"
fi

# --- Create main branch ---
git checkout -B "$MAIN_BRANCH"
git add .
git commit -m "Initial commit" || true
git push -u origin "$MAIN_BRANCH" --force

# --- Create dev branch ---
git checkout -B "$DEV_BRANCH"
git push -u origin "$DEV_BRANCH" --force

# --- Create a sample feature branch ---
FEATURE_BRANCH="${FEATURE_PREFIX}/example"
git checkout -B "$FEATURE_BRANCH"
git push -u origin "$FEATURE_BRANCH" --force

echo "Branches created and pushed:"
git branch -a
