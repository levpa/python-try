# python-try
Template python repository

- development in dev container
- build docker images inside dev environment
- Makefile verify, test, build, lint, e.t.c.

## DevContainer configuration

```sh
# install precommit hook
make precommit

# Devcontainer config: 
./devcontainer/devcontainer.json

# files binding from WSL host:
.ssh/
├── allowed_signers
├── azure_rsa
├── config
├── github_ed25519
├── id_ed25519.pub
└── known_hosts
.gitconfig
```

## Main dev commands
```sh
# Commit add and signing: 
# executed with git alias: sm = !git add -A && git commit -S -m
git sm "new signed commit"
git push

## bump version and push tags to remote
cd scripts
./scripts/bump.sh <patch|minor|major>
# → bumps patch -> 1.2.3/1.2.4 minor -> 1.2.3/1.3.3 -> major 1.2.3/2.2.3 version

## Server test
python server.py

## Build and run container inside devcontainer
docker build -t server . && docker run -p 8080:8080 server

# open browser... observe server logs in terminal
```