#!/usr/bin/env bash
set -euo pipefail

# ----------------------------------------
# Semantic Version Bump Script
# Usage: ./bump.sh [patch|minor|major]
# Default: patch
# ----------------------------------------

BUMP_TYPE="${1:-patch}"

# Ensure we’re in a Git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "❌ Not a git repository."
  exit 1
fi

# Ensure working directory is clean
if [ -n "$(git status --porcelain)" ]; then
  echo "⚠️ Working directory not clean. Commit or stash your changes first."
  exit 1
fi

# Get latest tag or start at v0.0.0
LATEST_TAG=$(git tag --sort=-v:refname | grep -E '^v?[0-9]+\.[0-9]+\.[0-9]+$' | head -n 1 || true)
if [ -z "$LATEST_TAG" ]; then
  LATEST_TAG="v0.0.0"
fi

# Strip the leading "v" if present
VERSION="${LATEST_TAG#v}"

IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"

case "$BUMP_TYPE" in
  patch)
    PATCH=$((PATCH + 1))
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  *)
    echo "❌ Unknown bump type: $BUMP_TYPE"
    echo "Usage: $0 [patch|minor|major]"
    exit 1
    ;;
esac

NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
NEW_TAG="v${NEW_VERSION}"

echo "🚀 Bumping version: ${LATEST_TAG} → ${NEW_TAG}"

# Create git tag
git tag -a "${NEW_TAG}" -m "Release ${NEW_TAG}"

# Push tag to remote
git push origin "${NEW_TAG}"

echo "✅ New tag ${NEW_TAG} pushed successfully!"
