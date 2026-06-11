# FungerGames

Prototype Qt 6 project with a Qt Quick desktop app, a fridge telemetry service, and a face-tracking service for the cursed over-calorie state.

## Requirements

- Qt at `~/Qt/6.9.3/gcc_64/`
- `cmake`
- `ninja` (preferred, but optional)
- `g++`

## Commands

```bash
./scripts/dev.sh build
./scripts/dev.sh run
./scripts/dev.sh clean
```

The `run` command starts both stub services in the background and then launches the app.
