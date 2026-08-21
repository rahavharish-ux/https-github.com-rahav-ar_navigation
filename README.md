# TN AR Navigation

AR navigation application for Tamil Nadu. This repository currently contains
only the **clean Flutter project foundation** — no maps, routing, AR, AI,
GPS, camera, sensor, or backend integrations have been added yet.

## Status

See [PROJECT_STATUS.md](PROJECT_STATUS.md) for the current build status,
phase roadmap, and completed tasks. See
[KNOWN_LIMITATIONS.md](KNOWN_LIMITATIONS.md) for current limitations, and
[DEVELOPMENT.md](DEVELOPMENT.md) for the development workflow, module
map, and full phase roadmap.

## Architecture

See [ARCHITECTURE.md](ARCHITECTURE.md) for the current folder layout,
target architecture, and design decisions behind the project structure.

## Getting Started

See [SETUP.md](SETUP.md) for environment requirements and how to run the
project locally.

## Quick Start

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

## Scope

This is a foundation-only milestone. Feature packages (maps, routing, AR,
GPS/location, camera, sensors, Supabase, AI/ML) will be added deliberately
in later milestones, one capability at a time.
