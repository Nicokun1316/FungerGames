#pragma once

#include <QObject>
#include <QTcpSocket>
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

signals:
    void connectedChanged();
    void payloadChanged();
    void lastUpdatedChanged();

private slots:
    void handleReadyRead();
    void updateConnectionState();

private:
    void consumeLine(const QByteArray &line);
    void setLastUpdated(const QString &value);

    QString m_name;
    QTcpSocket m_socket;
    QByteArray m_buffer;
    QVariantMap m_payload;
    QString m_lastUpdated;
};
