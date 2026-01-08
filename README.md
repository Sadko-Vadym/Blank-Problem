# Bot Project

A Telegram bot with automated CI/CD pipeline using GitHub Actions, Docker, and Kubernetes deployment via ArgoCD.

## CI/CD Pipeline Workflow

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              CI/CD Pipeline Workflow                                 │
└─────────────────────────────────────────────────────────────────────────────────────┘

     ┌──────────┐
     │Developer │
     └────┬─────┘
          │
          │ git push
          ▼
┌─────────────────┐
│   GitHub Repo   │
│ (develop branch)│
└────────┬────────┘
         │
         │ triggers
         ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                            GitHub Actions Workflow                                   │
│  ┌────────────────────────────────────────────────────────────────────────────────┐ │
│  │                                                                                │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌────────────────┐  │ │
│  │  │  Checkout   │───▶│  Build Go   │───▶│ Build Docker│───▶│ Push to ghcr.io│  │ │
│  │  │    Code     │    │   Binary    │    │    Image    │    │                │  │ │
│  │  └─────────────┘    └─────────────┘    └─────────────┘    └───────┬────────┘  │ │
│  │                                                                   │           │ │
│  │                                                                   ▼           │ │
│  │                                                         ┌────────────────┐    │ │
│  │                                                         │  Update Helm   │    │ │
│  │                                                         │ Chart values   │    │ │
│  │                                                         └───────┬────────┘    │ │
│  │                                                                 │             │ │
│  └─────────────────────────────────────────────────────────────────┼─────────────┘ │
└────────────────────────────────────────────────────────────────────┼───────────────┘
                                                                     │
                                                                     │ commit & push
                                                                     ▼
                                                           ┌─────────────────┐
                                                           │   GitHub Repo   │
                                                           │ (updated chart) │
                                                           └────────┬────────┘
                                                                    │
                                                                    │ sync
                                                                    ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                    ArgoCD                                            │
│  ┌────────────────────────────────────────────────────────────────────────────────┐ │
│  │                                                                                │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────────────────────────────┐ │ │
│  │  │   Detect    │───▶│    Sync     │───▶│        Deploy to Kubernetes         │ │ │
│  │  │   Changes   │    │ Application │    │                                     │ │ │
│  │  └─────────────┘    └─────────────┘    └─────────────────────────────────────┘ │ │
│  │                                                                                │ │
│  └────────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                                                     │
                                                                     │ deploy
                                                                     ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              Kubernetes Cluster                                      │
│  ┌────────────────────────────────────────────────────────────────────────────────┐ │
│  │                                                                                │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────────────────────────────┐ │ │
│  │  │   Secret    │    │ Deployment  │    │              Pod                    │ │ │
│  │  │ (TELE_TOKEN)│───▶│    (bot)    │───▶│  ┌─────────────────────────────┐   │ │ │
│  │  └─────────────┘    └─────────────┘    │  │      Bot Container          │   │ │ │
│  │                                        │  │  (ghcr.io/sadko-vadym/...)  │   │ │ │
│  │                                        │  └─────────────────────────────┘   │ │ │
│  │                                        └─────────────────────────────────────┘ │ │
│  │                                                                                │ │
│  └────────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                                                     │
                                                                     │ connects
                                                                     ▼
                                                           ┌─────────────────┐
                                                           │  Telegram API   │
                                                           └─────────────────┘
```

## Components

| Component | Description |
|-----------|-------------|
| **GitHub Actions** | CI/CD automation - builds, tests, and pushes container images |
| **ghcr.io** | GitHub Container Registry for storing Docker images |
| **Helm Chart** | Kubernetes package manager for deploying the bot |
| **ArgoCD** | GitOps continuous delivery tool for Kubernetes |
| **Kubernetes** | Container orchestration platform |

## Image Format

The container image follows this naming convention:

```
ghcr.io/<owner>/<repo>:<version>-<commit>-<os>-<arch>
```

Example:
```
ghcr.io/sadko-vadym/blank-problem:v1.0.0-abc1234-linux-amd64
```

## Helm Chart Configuration

The Helm chart values (`bot/values.yaml`) include:

```yaml
image:
  registry: "ghcr.io"
  repository: "sadko-vadym/blank-problem"
  tag: "v1.0.0-abc1234"
  os: linux
  arch: amd64

secret:
  TELE_TOKEN: ""  # Set during installation
```

## Installation

### Using Helm

```bash
helm install bot ./bot --set secret.TELE_TOKEN=YOUR_TELEGRAM_TOKEN
```

### From GitHub Release

```bash
helm install bot https://github.com/Sadko-Vadym/Blank-Problem/releases/download/v1.0.0/bot-1.0.0.tgz \
  --set secret.TELE_TOKEN=YOUR_TELEGRAM_TOKEN
```

## Local Development

### Build

```bash
make build
```

### Build Docker Image

```bash
make image
```

### Push to Registry

```bash
make push
```

## Pipeline Trigger

The CI/CD pipeline is triggered on every push to the `develop` branch.

## License

MIT

