.PHONY: verify test hook lint check-build precommit release chlog-write version-inject docker-build

SRC_FOLDER := src
REPO := levpa/python-try
verify:
	@echo "🔍 Verifying Python environment..."
	@python3.13 --version
	@pip --version
	@pip check
	@echo "✅ Environment verification complete."

lint:
	@echo "🔍 Linting with ruff and mypy..."
	@ruff check $(SRC_FOLDER)/ --exit-zero
	@mypy $(SRC_FOLDER)/ --ignore-missing-imports

test:
	@echo "🧪 Running tests..."
	@pytest tests/ --disable-warnings --maxfail=1 
	@echo "✅ Tests completed."

check-build:
	@echo "🧱 Checking Python build integrity..."
	@python -m compileall -q $(SRC_FOLDER)/
	@python -m pip check

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

VERSION := $(shell git tag --sort=-v:refname | grep -E '^v?[0-9]+\.[0-9]+\.[0-9]+$$' | head -n 1)
COMMIT := $(shell git rev-parse --short HEAD)
BUILD_DATE := $(shell date -u +%Y-%m-%dT%H:%M:%SZ)

version-inject:
	@echo "🚀 Injecting version, commit sha and date into version.py"
	@echo "VERSION = '$(VERSION)'" > $(SRC_FOLDER)/version.py
	@echo "COMMIT = '$(COMMIT)'" >> $(SRC_FOLDER)/version.py
	@echo "BUILD_DATE = '$(BUILD_DATE)'" >> $(SRC_FOLDER)/version.py

docker-build:
	docker buildx build \
		--label version=$(VERSION) \
		--label commit=$(COMMIT) \
		--label build_date=$(BUILD_DATE) \
		--label repo=https://github.com/$(REPO) \
		--label registry=ghcr.io/$(REPO) \
		-t ghcr.io/$(REPO):$(VERSION) .
	docker run -p 8080:8080 py-server
