.PHONY: verify test hook lint check-build precommit release version-inject docker-build chlog

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
	@yamllint .github/workflows

test:
	@echo "🧪 Running tests..."
	@pytest tests/ --disable-warnings --maxfail=1 
	@echo "✅ Tests completed."

check-build:
	@echo "🧱 Checking Python build integrity..."
	@python -m compileall -q $(SRC_FOLDER)/
	@python -m pip check

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

CHLOG_LENGTH ?= 5
BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
VERSION := $(shell git describe --tags --abbrev=0)


chlog:
	@echo "# Changelog for $(VERSION)\n" > CHANGELOG.md
	@printf "## Date: $(shell date '+%Y-%m-%d')\n\n" >> CHANGELOG.md
	@rm -f .chlog-seen

	@printf "### ✨ Features\n\n" >> CHANGELOG.md
	@git log -n $(CHLOG_LENGTH) --grep="^feat" --pretty=format:"%h" | tee -a .chlog-seen | \
		xargs -I{} git log -1 --pretty=format:"- {} %d %s (%ad)" --date=relative {} >> CHANGELOG.md

	@printf "### 🐛 Fixes\n\n" >> CHANGELOG.md
	@git log -n $(CHLOG_LENGTH) --grep="^fix" --pretty=format:"%h" | tee -a .chlog-seen | \
		xargs -I{} git log -1 --pretty=format:"- {} %d %s (%ad)" --date=relative {} >> CHANGELOG.md

	@printf "\n\n### 🧹 Chores & Refactors\n\n" >> CHANGELOG.md
	@git log -n $(CHLOG_LENGTH) --grep="^chore\|^refactor" --pretty=format:"%h" | tee -a .chlog-seen | \
		xargs -I{} git log -1 --pretty=format:"- {} %d %s (%ad)" --date=relative {} >> CHANGELOG.md

	@printf "\n\n### 📌 Other Commits\n\n" >> CHANGELOG.md
	@git log -n $(CHLOG_LENGTH) --pretty=format:"%h" | while read hash; do \
		grep -q $$hash .chlog-seen || \
		git log -1 --pretty=format:"- $$hash %d %s (%ad)" --date=relative $$hash >> CHANGELOG.md; \
	  printf "\n" >> CHANGELOG.md; \
	done

	@sed -i -E \
		-e 's/HEAD -> [^,)]+,? ?//g' \
		-e 's/origin\/[^,)]+,? ?//g' \
		-e 's/HEAD,? ?//g' \
		-e 's/origin\/HEAD,? ?//g' \
		-e 's/ ,/,/g' \
		-e 's/, \)/)/g' \
		CHANGELOG.md

	@rm -f .chlog-seen
	@cat CHANGELOG.md
