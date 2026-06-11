#include "AppController.h"

namespace {
constexpr quint16 kDeviceServicePort = 45454;
constexpr quint16 kGameServicePort = 45455;
}

AppController::AppController(QObject *parent)
    : QObject(parent)
    , m_deviceService(QStringLiteral("Device Status"), this)
    , m_gameService(QStringLiteral("Game Session"), this)
{
    m_deviceService.connectToService(QStringLiteral("127.0.0.1"), kDeviceServicePort);
    m_gameService.connectToService(QStringLiteral("127.0.0.1"), kGameServicePort);
}

TelemetryClient *AppController::deviceService()
{
    return &m_deviceService;
}

TelemetryClient *AppController::gameService()
{
    return &m_gameService;
}
