.PHONY: verify test hook lint check-build precommit release chlog-write

verify:
	@echo "🔍 Verifying Python environment..."
	@python3.13 --version
	@pip --version
	@pip check
	@echo "✅ Environment verification complete."

lint:
	@echo "🔍 Linting with ruff and mypy..."
	@ruff check src/ --exit-zero
	@mypy src/ --ignore-missing-imports

test:
	@echo "🧪 Running tests..."
	@pytest tests/ --disable-warnings --maxfail=1 
	@echo "✅ Tests completed."

check-build:
	@echo "🧱 Checking Python build integrity..."
	@python -m compileall -q src/
	@python -m pip check
# 	@echo "🐳 Building Docker image..."
# 	@docker build -t myserver .

chlog-write:
	@git log -n 10 --pretty=format:"- %h %s" > CHANGELOG.md
	@git add CHANGELOG.md
	@cat CHANGELOG.md

precommit:
	bash ./scripts/hook.sh

BUMP_TYPE ?= patch

release:
	@echo "🚀 Releasing version bump..."
	bash scripts/bump.sh $(BUMP_TYPE)
