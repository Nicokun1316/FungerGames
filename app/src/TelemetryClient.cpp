#include "TelemetryClient.h"

#include <QDateTime>
#include <QJsonDocument>
#include <QJsonObject>
#include <QLocale>

TelemetryClient::TelemetryClient(QString name, QObject *parent)
    : QObject(parent)
    , m_name(std::move(name))
{
    connect(&m_socket, &QTcpSocket::readyRead, this, &TelemetryClient::handleReadyRead);
    connect(&m_socket, &QTcpSocket::connected, this, &TelemetryClient::updateConnectionState);
    connect(&m_socket, &QTcpSocket::disconnected, this, &TelemetryClient::updateConnectionState);
    connect(&m_socket, &QTcpSocket::stateChanged, this, &TelemetryClient::updateConnectionState);
}

QString TelemetryClient::name() const
{
    return m_name;
}

bool TelemetryClient::isConnected() const
{
    return m_socket.state() == QAbstractSocket::ConnectedState;
}

QVariantMap TelemetryClient::payload() const
{
    return m_payload;
}

QString TelemetryClient::lastUpdated() const
{
    return m_lastUpdated;
}

void TelemetryClient::connectToService(const QString &host, quint16 port)
{
    if (m_socket.state() != QAbstractSocket::UnconnectedState) {
        m_socket.abort();
    }

    m_buffer.clear();
    m_socket.connectToHost(host, port);
}

void TelemetryClient::handleReadyRead()
{
    m_buffer.append(m_socket.readAll());

    while (true) {
        const int newlineIndex = m_buffer.indexOf('\n');
        if (newlineIndex < 0) {
            break;
        }

        const QByteArray line = m_buffer.left(newlineIndex).trimmed();
        m_buffer.remove(0, newlineIndex + 1);

        if (!line.isEmpty()) {
            consumeLine(line);
        }
    }
}

void TelemetryClient::updateConnectionState()
{
    emit connectedChanged();
}

void TelemetryClient::consumeLine(const QByteArray &line)
{
    const QJsonDocument document = QJsonDocument::fromJson(line);
    if (!document.isObject()) {
        return;
    }

    m_payload = document.object().toVariantMap();
    emit payloadChanged();

    const QString timestamp = m_payload.value(QStringLiteral("timestamp")).toString();
    if (!timestamp.isEmpty()) {
        const QDateTime parsed = QDateTime::fromString(timestamp, Qt::ISODate);
        setLastUpdated(parsed.isValid() ? QLocale().toString(parsed.toLocalTime(), QLocale::ShortFormat) : timestamp);
    }
}

void TelemetryClient::setLastUpdated(const QString &value)
{
    if (m_lastUpdated == value) {
        return;
    }

    m_lastUpdated = value;
    emit lastUpdatedChanged();
}
