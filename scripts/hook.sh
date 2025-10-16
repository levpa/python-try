#!/usr/bin/env bash
set -e

REPO_ROOT="$(git rev-parse --show-toplevel)"
HOOK_PATH="$REPO_ROOT/.git/hooks/pre-commit"

if [ "$REPO_ROOT" != "$(realpath .)" ]; then
  echo "❌ Please run this script from the root of your Git repository:"
  echo "   cd $REPO_ROOT"
  exit 1
fi

echo "🔧 Installing pre-commit hook..."

if [ -f "$HOOK_PATH" ]; then
  echo "⚠️ Existing pre-commit hook found. Overwriting..."
fi

cat > "$HOOK_PATH" <<'EOF'
#!/usr/bin/env bash
set -e

echo "🔍 Running make verify..."
make verify

echo "🧪 Running make lint..."
make lint

echo "🧪 Running make test..."
make test

echo "🧱 Running make check-build..."
make check-build
EOF

chmod +x "$HOOK_PATH"

echo "✅ Pre-commit hook installed at $HOOK_PATH"
