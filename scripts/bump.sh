#!/usr/bin/env bash
set -euo pipefail

BUMP_TYPE="${1:-patch}"

# Ensure we're in a Git repo with at least one commit
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌ Not inside a Git repository"
  exit 1
fi

if ! git log -1 >/dev/null 2>&1; then
  echo "❌ No commits found. Please commit before tagging."
  exit 1
fi

# Get latest semver tag or fallback
LATEST_TAG=$(git tag --sort=-v:refname | grep -E '^v?[0-9]+\.[0-9]+\.[0-9]+$' | head -n 1)
LATEST_TAG="${LATEST_TAG:-v0.0.0}"
VERSION="${LATEST_TAG#v}"

IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"

case "$BUMP_TYPE" in
  major)
    ((MAJOR++)); MINOR=0; PATCH=0 ;;
  minor)
    ((MINOR++)); PATCH=0 ;;
  patch)
    ((PATCH++)) ;;
  *)
    echo "❌ Invalid bump type: $BUMP_TYPE"
    echo "Usage: $0 [major|minor|patch]"
    exit 1 ;;
esac

NEW_TAG="v${MAJOR}.${MINOR}.${PATCH}"
echo "🔖 Bumping version: $LATEST_TAG → $NEW_TAG"

# Create tag
git tag "$NEW_TAG"

# Push tag if remote exists
if git remote get-url origin >/dev/null 2>&1; then
  git push origin "$NEW_TAG"
  echo "✅ Tag $NEW_TAG pushed to origin"
else
  echo "⚠️ No remote 'origin' found. Tag created locally."
fi