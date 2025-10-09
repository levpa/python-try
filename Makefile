.PHONY: verify test

verify:
	@echo "🔍 Verifying Python environment..."
	@python3.12 --version
	@pip --version
	@pip check
	@echo "✅ Environment verification complete."

test:
	@echo "🧪 Running tests..."
	@pytest --disable-warnings --maxfail=1
	@echo "✅ Tests completed."