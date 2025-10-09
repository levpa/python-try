.PHONY: verify test hook lint check-build precommit

verify:
	@echo "🔍 Verifying Python environment..."
	@python3.12 --version
	@pip --version
	@pip check
	@echo "✅ Environment verification complete."

lint:
	@echo "🔍 Linting with ruff and mypy..."
	@ruff check . --exit-zero
	@mypy . --ignore-missing-imports

test:
	@echo "🧪 Running tests..."
	@pytest --disable-warnings --maxfail=1 
	@echo "✅ Tests completed."

check-build:
	@echo "🧱 Checking Python build integrity..."
	@python -m compileall -q .
	@python -m pip check
# 	@echo "🐳 Building Docker image..."
# 	@docker build -t myserver .

precommit:
	bash ./scripts/hook.sh