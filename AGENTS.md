# AGENTS.md

## Project purpose

`FungerGames` is a Qt 6.9 prototype. It contains a Qt Quick desktop app that connects to two local TCP stub services and shows their latest JSON payloads in a simple dashboard.

## Repository layout

- `app/`: main Qt Quick application
- `iot-services/device-status-service/`: mock TCP server for device telemetry
- `iot-services/game-session-service/`: mock TCP server for game/session telemetry
- `scripts/dev.sh`: local build, clean, and run workflow

## Build and run

- Build: `./scripts/dev.sh build`
- Run everything: `./scripts/dev.sh run`
- Clean generated files: `./scripts/dev.sh clean`

The default Qt install path is `~/Qt/6.9.3/gcc_64/`. The script converts that into `CMAKE_PREFIX_PATH` during configure.

## Runtime contract

- The app talks only to local TCP services on `127.0.0.1`.
- Ports:
  - device status service: `45454`
  - game session service: `45455`
- Wire format: UTF-8 JSON, one object per line.

### Device payload

Expected keys:
- `service`
- `deviceId`
- `online`
- `temperature`
- `battery`
- `timestamp`

### Game session payload

Expected keys:
- `service`
- `title`
- `playersOnline`
- `roundState`
- `timestamp`

## Coding conventions

- Keep the app/service boundary simple: newline-delimited JSON over TCP.
- Prefer small QObject-based adapters between C++ networking code and QML.
- Keep QML declarative and minimal; push socket and parsing logic into C++.
- Preserve fixed localhost ports unless the runtime contract is intentionally updated.
- If payload shapes change, update both the service emitter and the QML-facing backend together.
