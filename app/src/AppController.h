#pragma once

#include <QObject>

#include "TelemetryClient.h"

class AppController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(TelemetryClient *deviceService READ deviceService CONSTANT)
    Q_PROPERTY(TelemetryClient *gameService READ gameService CONSTANT)

public:
    explicit AppController(QObject *parent = nullptr);

    TelemetryClient *deviceService();
    TelemetryClient *gameService();

private:
    TelemetryClient m_deviceService;
    TelemetryClient m_gameService;
};
