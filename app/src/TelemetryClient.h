#pragma once

#include <QObject>
#include <QTcpSocket>
#include <QTimer>
#include <QVariantMap>

class TelemetryClient : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(bool connected READ isConnected NOTIFY connectedChanged)
    Q_PROPERTY(QVariantMap payload READ payload NOTIFY payloadChanged)
    Q_PROPERTY(QString lastUpdated READ lastUpdated NOTIFY lastUpdatedChanged)

public:
    explicit TelemetryClient(QString name, QObject *parent = nullptr);

    QString name() const;
    bool isConnected() const;
    QVariantMap payload() const;
    QString lastUpdated() const;

    void connectToService(const QString &host, quint16 port);
    void sendMessage(const QVariantMap &message);

signals:
    void connectedChanged();
    void payloadChanged();
    void lastUpdatedChanged();
    void messageReceived(const QVariantMap &payload);

private slots:
    void handleReadyRead();
    void updateConnectionState();
    void attemptReconnect();

private:
    void consumeLine(const QByteArray &line);
    void setLastUpdated(const QString &value);

    QString m_name;
    QTcpSocket m_socket;
    QTimer m_reconnectTimer;
    QByteArray m_buffer;
    QVariantMap m_payload;
    QString m_lastUpdated;
    QString m_host;
    quint16 m_port = 0;
};
