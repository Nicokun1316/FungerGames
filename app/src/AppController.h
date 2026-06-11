#pragma once

#include <QObject>
#include <QTimer>

#include "TelemetryClient.h"

class AppController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool faceServiceConnected READ faceServiceConnected NOTIFY faceServiceConnectedChanged)
    Q_PROPERTY(bool fridgeServiceConnected READ fridgeServiceConnected NOTIFY fridgeServiceConnectedChanged)
    Q_PROPERTY(QString faceServiceLastUpdated READ faceServiceLastUpdated NOTIFY faceServiceLastUpdatedChanged)
    Q_PROPERTY(QString fridgeServiceLastUpdated READ fridgeServiceLastUpdated NOTIFY fridgeServiceLastUpdatedChanged)
    Q_PROPERTY(QString latestEventType READ latestEventType NOTIFY fridgeDataChanged)
    Q_PROPERTY(QString latestContentType READ latestContentType NOTIFY fridgeDataChanged)
    Q_PROPERTY(int eventCalories READ eventCalories NOTIFY fridgeDataChanged)
    Q_PROPERTY(int dailyCalories READ dailyCalories NOTIFY fridgeDataChanged)
    Q_PROPERTY(int dailyDeficit READ dailyDeficit NOTIFY fridgeDataChanged)
    Q_PROPERTY(int dailyLimit READ dailyLimit NOTIFY fridgeDataChanged)
    Q_PROPERTY(bool overLimit READ overLimit NOTIFY fridgeDataChanged)
    Q_PROPERTY(int calorieOverage READ calorieOverage NOTIFY fridgeDataChanged)
    Q_PROPERTY(qreal overageRatio READ overageRatio NOTIFY fridgeDataChanged)
    Q_PROPERTY(qreal smoothedFocusX READ smoothedFocusX NOTIFY faceDataChanged)
    Q_PROPERTY(qreal smoothedFocusY READ smoothedFocusY NOTIFY faceDataChanged)
    Q_PROPERTY(qreal focusX READ focusX NOTIFY faceDataChanged)
    Q_PROPERTY(qreal focusY READ focusY NOTIFY faceDataChanged)
    Q_PROPERTY(bool alarmActive READ alarmActive NOTIFY alarmStateChanged)
    Q_PROPERTY(QString alarmDisplay READ alarmDisplay NOTIFY alarmStateChanged)
    Q_PROPERTY(bool challengeVisible READ challengeVisible NOTIFY challengeStateChanged)
    Q_PROPERTY(bool strikeWindowOpen READ strikeWindowOpen NOTIFY challengeStateChanged)
    Q_PROPERTY(QString challengeStatus READ challengeStatus NOTIFY challengeStateChanged)
    Q_PROPERTY(QString challengeHint READ challengeHint NOTIFY challengeStateChanged)

public:
    explicit AppController(QObject *parent = nullptr);

    bool faceServiceConnected() const;
    bool fridgeServiceConnected() const;
    QString faceServiceLastUpdated() const;
    QString fridgeServiceLastUpdated() const;
    QString latestEventType() const;
    QString latestContentType() const;
    int eventCalories() const;
    int dailyCalories() const;
    int dailyDeficit() const;
    int dailyLimit() const;
    bool overLimit() const;
    int calorieOverage() const;
    qreal overageRatio() const;
    qreal smoothedFocusX() const;
    qreal smoothedFocusY() const;
    qreal focusX() const;
    qreal focusY() const;
    bool alarmActive() const;
    QString alarmDisplay() const;
    bool challengeVisible() const;
    bool strikeWindowOpen() const;
    QString challengeStatus() const;
    QString challengeHint() const;

    Q_INVOKABLE void sendFaceTrackingTarget(qreal x, qreal y);
    Q_INVOKABLE void triggerAlarm();
    Q_INVOKABLE void requestAlarmDismissal();
    Q_INVOKABLE void attemptChallenge();

signals:
    void faceServiceConnectedChanged();
    void fridgeServiceConnectedChanged();
    void faceServiceLastUpdatedChanged();
    void fridgeServiceLastUpdatedChanged();
    void fridgeDataChanged();
    void faceDataChanged();
    void alarmStateChanged();
    void challengeStateChanged();

private:
    enum class ChallengePhase {
        Idle,
        Windup,
        Hold,
        Strike,
        Recover
    };

    void handleFridgeMessage(const QVariantMap &payload);
    void handleFaceMessage(const QVariantMap &payload);
    void tickAlarmCountdown();
    void startAlarmCountdown();
    void triggerAlarmInternal();
    void updateChallengePhase();
    void failChallenge(const QString &status);
    void clearChallenge();
    void stopAlarm();

    TelemetryClient m_faceService;
    TelemetryClient m_fridgeService;
    QTimer m_alarmTimer;
    QTimer m_challengeTimer;
    QString m_latestEventType;
    QString m_latestContentType;
    int m_eventCalories = 0;
    int m_dailyCalories = 0;
    int m_dailyDeficit = 0;
    int m_dailyLimit = 1800;
    qreal m_smoothedFocusX = 0.5;
    qreal m_smoothedFocusY = 0.5;
    qreal m_focusX = 0.5;
    qreal m_focusY = 0.5;
    bool m_alarmActive = false;
    int m_secondsUntilAlarm = 35;
    bool m_challengeVisible = false;
    bool m_strikeWindowOpen = false;
    QString m_challengeStatus = QStringLiteral("The bell sleeps.");
    QString m_challengeHint = QStringLiteral("Wait for the strike window.");
    ChallengePhase m_challengePhase = ChallengePhase::Idle;
};
