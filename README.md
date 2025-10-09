# python-try
Template python repository

- development in dev container
- build docker images inside dev environment
- Makefile verify, test, build, lint, e.t.c.

## DevContainer configuration

```sh
# install/rewrite precommit hook (run once after 'git clone')
make precommit

# Devcontainer config(docker image, VS Code features and extensions): 
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
# install deps if needed
pip install -r src/requirements.txt

# CI test
make verify lint test check-build

# Commit add and signing with SSH keys: 
git sm "new signed commit"
git push

## bump version and push tags to remote (default -> patch version)

# !! runs build -> push pipeline to ghcr
# !! runs release pipeline to make release on github

make release # make release <patch/minor/major>

## Server local test
python src/server.py

## Build and run from Docker(DinD) inside devcontainer
docker build -t py-server . && docker run -p 8080:8080 py-server

# open browser... observe server logs in terminal
```

## Debug image labels

```sh
export IMAGE=ghcr.io/levpa/python-try:v0.0.14

# Pull the image
docker pull $IMAGE
IMAGE_ID=$(docker images --format '{{.Repository}}:{{.Tag}} {{.ID}}' | grep $IMAGE | awk '{print $2}')
echo -e "\nIMAGE_ID: $IMAGE_ID\n"
docker inspect "$IMAGE_ID" --format='{{json .Config.Labels}}' | jq
```