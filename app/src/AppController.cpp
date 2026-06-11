#include "AppController.h"

#include <QDateTime>

namespace {
constexpr quint16 kFaceServicePort = 45454;
constexpr quint16 kFridgeServicePort = 45455;
}

AppController::AppController(QObject *parent)
    : QObject(parent)
    , m_faceService(QStringLiteral("Face Tracking"), this)
    , m_fridgeService(QStringLiteral("Fridge Service"), this)
{
    connect(&m_faceService, &TelemetryClient::connectedChanged, this, &AppController::faceServiceConnectedChanged);
    connect(&m_faceService, &TelemetryClient::lastUpdatedChanged, this, &AppController::faceServiceLastUpdatedChanged);
    connect(&m_faceService, &TelemetryClient::messageReceived, this, &AppController::handleFaceMessage);

    connect(&m_fridgeService, &TelemetryClient::connectedChanged, this, &AppController::fridgeServiceConnectedChanged);
    connect(&m_fridgeService, &TelemetryClient::lastUpdatedChanged, this, &AppController::fridgeServiceLastUpdatedChanged);
    connect(&m_fridgeService, &TelemetryClient::messageReceived, this, &AppController::handleFridgeMessage);

    m_alarmTimer.setInterval(1000);
    connect(&m_alarmTimer, &QTimer::timeout, this, &AppController::tickAlarmCountdown);

    m_challengeTimer.setSingleShot(true);
    connect(&m_challengeTimer, &QTimer::timeout, this, &AppController::updateChallengePhase);

    startAlarmCountdown();
    m_faceService.connectToService(QStringLiteral("127.0.0.1"), kFaceServicePort);
    m_fridgeService.connectToService(QStringLiteral("127.0.0.1"), kFridgeServicePort);
}

bool AppController::faceServiceConnected() const
{
    return m_faceService.isConnected();
}

bool AppController::fridgeServiceConnected() const
{
    return m_fridgeService.isConnected();
}

QString AppController::faceServiceLastUpdated() const
{
    return m_faceService.lastUpdated();
}

QString AppController::fridgeServiceLastUpdated() const
{
    return m_fridgeService.lastUpdated();
}

QString AppController::latestEventType() const
{
    return m_latestEventType;
}

QString AppController::latestContentType() const
{
    return m_latestContentType;
}

int AppController::eventCalories() const
{
    return m_eventCalories;
}

int AppController::dailyCalories() const
{
    return m_dailyCalories;
}

int AppController::dailyDeficit() const
{
    return m_dailyDeficit;
}

int AppController::dailyLimit() const
{
    return m_dailyLimit;
}

bool AppController::overLimit() const
{
    return m_dailyCalories > m_dailyLimit;
}

int AppController::calorieOverage() const
{
    return qMax(0, m_dailyCalories - m_dailyLimit);
}

qreal AppController::overageRatio() const
{
    return qMin<qreal>(1.0, calorieOverage() / 600.0);
}

qreal AppController::smoothedFocusX() const
{
    return m_smoothedFocusX;
}

qreal AppController::smoothedFocusY() const
{
    return m_smoothedFocusY;
}

qreal AppController::focusX() const
{
    return m_focusX;
}

qreal AppController::focusY() const
{
    return m_focusY;
}

bool AppController::alarmActive() const
{
    return m_alarmActive;
}

QString AppController::alarmDisplay() const
{
    if (m_alarmActive) {
        return QStringLiteral("ALARM RINGING");
    }

    const int minutes = m_secondsUntilAlarm / 60;
    const int seconds = m_secondsUntilAlarm % 60;
    return QStringLiteral("Next alarm in %1:%2")
        .arg(minutes, 2, 10, QLatin1Char('0'))
        .arg(seconds, 2, 10, QLatin1Char('0'));
}

bool AppController::challengeVisible() const
{
    return m_challengeVisible;
}

bool AppController::strikeWindowOpen() const
{
    return m_strikeWindowOpen;
}

QString AppController::challengeStatus() const
{
    return m_challengeStatus;
}

QString AppController::challengeHint() const
{
    return m_challengeHint;
}

void AppController::sendFaceTrackingTarget(qreal x, qreal y)
{
    if (!overLimit()) {
        return;
    }

    QVariantMap payload;
    payload.insert(QStringLiteral("type"), QStringLiteral("cursor"));
    payload.insert(QStringLiteral("x"), qBound<qreal>(0.0, x, 1.0));
    payload.insert(QStringLiteral("y"), qBound<qreal>(0.0, y, 1.0));
    payload.insert(QStringLiteral("timestamp"), QDateTime::currentDateTimeUtc().toString(Qt::ISODate));
    m_faceService.sendMessage(payload);
}

void AppController::triggerAlarm()
{
    triggerAlarmInternal();
}

void AppController::requestAlarmDismissal()
{
    if (!m_alarmActive || m_challengeVisible) {
        return;
    }

    m_challengeVisible = true;
    m_challengeStatus = QStringLiteral("A bell-knight rises from the clockface.");
    m_challengeHint = QStringLiteral("Do not strike early.");
    m_challengePhase = ChallengePhase::Windup;
    m_strikeWindowOpen = false;
    emit challengeStateChanged();
    m_challengeTimer.start(1000);
}

void AppController::attemptChallenge()
{
    if (!m_challengeVisible) {
        return;
    }

    if (m_strikeWindowOpen) {
        m_challengeTimer.stop();
        m_challengeStatus = QStringLiteral("Perfect strike. The bell falls silent.");
        m_challengeHint = QStringLiteral("The alarm has been dismissed.");
        m_strikeWindowOpen = false;
        emit challengeStateChanged();
        stopAlarm();
        clearChallenge();
        return;
    }

    failChallenge(QStringLiteral("Mistimed. The bell-knight punishes impatience."));
}

void AppController::handleFridgeMessage(const QVariantMap &payload)
{
    m_latestEventType = payload.value(QStringLiteral("eventType")).toString();
    m_latestContentType = payload.value(QStringLiteral("contentType")).toString();
    m_eventCalories = payload.value(QStringLiteral("eventCalories")).toInt();
    m_dailyCalories = payload.value(QStringLiteral("dailyCalories")).toInt();
    m_dailyDeficit = payload.value(QStringLiteral("dailyDeficit")).toInt();
    m_dailyLimit = payload.value(QStringLiteral("dailyLimit")).toInt();
    emit fridgeDataChanged();
}

void AppController::handleFaceMessage(const QVariantMap &payload)
{
    m_focusX = payload.value(QStringLiteral("focusX")).toDouble();
    m_focusY = payload.value(QStringLiteral("focusY")).toDouble();
    m_smoothedFocusX = payload.value(QStringLiteral("smoothedX")).toDouble();
    m_smoothedFocusY = payload.value(QStringLiteral("smoothedY")).toDouble();
    emit faceDataChanged();
}

void AppController::tickAlarmCountdown()
{
    if (m_alarmActive) {
        return;
    }

    if (m_secondsUntilAlarm > 0) {
        --m_secondsUntilAlarm;
        emit alarmStateChanged();
    }

    if (m_secondsUntilAlarm == 0) {
        triggerAlarmInternal();
    }
}

void AppController::startAlarmCountdown()
{
    m_secondsUntilAlarm = 35;
    m_alarmTimer.start();
    emit alarmStateChanged();
}

void AppController::triggerAlarmInternal()
{
    if (m_alarmActive) {
        return;
    }

    m_alarmActive = true;
    emit alarmStateChanged();
}

void AppController::updateChallengePhase()
{
    switch (m_challengePhase) {
    case ChallengePhase::Windup:
        m_challengePhase = ChallengePhase::Hold;
        m_challengeStatus = QStringLiteral("The blade rises. Hold your nerve.");
        m_challengeHint = QStringLiteral("Wait for the opening.");
        emit challengeStateChanged();
        m_challengeTimer.start(900);
        break;
    case ChallengePhase::Hold:
        m_challengePhase = ChallengePhase::Strike;
        m_strikeWindowOpen = true;
        m_challengeStatus = QStringLiteral("Strike now.");
        m_challengeHint = QStringLiteral("One clean hit wins.");
        emit challengeStateChanged();
        m_challengeTimer.start(700);
        break;
    case ChallengePhase::Strike:
        failChallenge(QStringLiteral("Too slow. The bell keeps screaming."));
        break;
    case ChallengePhase::Recover:
        m_challengePhase = ChallengePhase::Windup;
        m_challengeStatus = QStringLiteral("The bell-knight attacks again.");
        m_challengeHint = QStringLiteral("Wait. Then strike.");
        emit challengeStateChanged();
        m_challengeTimer.start(1000);
        break;
    case ChallengePhase::Idle:
        break;
    }
}

void AppController::failChallenge(const QString &status)
{
    m_challengePhase = ChallengePhase::Recover;
    m_strikeWindowOpen = false;
    m_challengeStatus = status;
    m_challengeHint = QStringLiteral("Prepare for another exchange.");
    emit challengeStateChanged();
    m_challengeTimer.start(1200);
}

void AppController::clearChallenge()
{
    m_challengeVisible = false;
    m_challengePhase = ChallengePhase::Idle;
    emit challengeStateChanged();
}

void AppController::stopAlarm()
{
    m_alarmActive = false;
    emit alarmStateChanged();
    startAlarmCountdown();
}
