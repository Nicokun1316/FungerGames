# AGENTS.md

## Project purpose

`FungerGames` is a Qt 6.9 prototype. It contains a Qt Quick desktop app that monitors simulated fridge activity, switches into a cursed over-calorie mode, and uses a face-tracking service to drive creepy eye movement.

## Repository layout

- `app/`: main Qt Quick application
- `iot-services/face-tracking-service/`: mock TCP server that smooths normalized mouse coordinates into eye focal points
- `iot-services/fridge-service/`: mock TCP server that simulates fridge load/unload calorie events
- `scripts/dev.sh`: local build, clean, and run workflow

## Build and run

- Build: `./scripts/dev.sh build`
- Run everything: `./scripts/dev.sh run`
- Clean generated files: `./scripts/dev.sh clean`

The default Qt install path is `~/Qt/6.9.3/gcc_64/`. The script converts that into `CMAKE_PREFIX_PATH` during configure.

## Runtime contract

- The app talks only to local TCP services on `127.0.0.1`.
- Ports:
  - face tracking service: `45454`
  - fridge service: `45455`
- Wire format: UTF-8 JSON, one object per line.

### Face tracking payloads

Inbound keys from app:
- `type`
- `x`
- `y`
- `timestamp`

Outbound keys from service:
- `service`
- `focusX`
- `focusY`
- `smoothedX`
- `smoothedY`
- `timestamp`

### Fridge payload

Expected keys:
- `service`
- `eventType`
- `contentType`
- `eventCalories`
- `dailyCalories`
- `dailyDeficit`
- `dailyLimit`
- `timestamp`

## Coding conventions

- Keep the app/service boundary simple: newline-delimited JSON over TCP.
- Prefer small QObject-based adapters between C++ networking code and QML.
- Keep QML declarative and minimal; push socket and parsing logic into C++.
- Preserve fixed localhost ports unless the runtime contract is intentionally updated.
- If payload shapes change, update both the service emitter and the QML-facing backend together.
- The cursed widget should send mouse coordinates to the face-tracking service only while it is active.
