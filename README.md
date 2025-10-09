# python-try
Template python repository

- development in dev container
- build docker images inside dev environment
- Makefile verify, test, build, lint, e.t.c.

## DevContainer configuration

```sh
# install precommit hook (need to run once after 'git clone')
make precommit

# Devcontainer config(features and extensions): 
./devcontainer/devcontainer.json

# Run devcontainer (WSL2), creates dev environment in container
Ctrl + Shift + P: Dev Containers: Open Container/Rebuild Container.

# files binding from WSL host(.ssh keys, creds, aliases should be configured):
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

## bump version and push tags to remote (default -> patch version)
# !! runs build -> push pipeline to ghcr
# !! runs release pipeline to make release on github
make release
# make release <patch/minor/major>

## Server test
python server.py

## Build and run container inside devcontainer
docker build -t server . && docker run -p 8080:8080 server

# open browser... observe server logs in terminal
```