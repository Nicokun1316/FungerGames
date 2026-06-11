#include "DeviceStatusServer.h"

#include <QDateTime>
#include <QJsonDocument>
#include <QJsonObject>

DeviceStatusServer::DeviceStatusServer(QObject *parent)
    : QObject(parent)
{
    connect(&m_server, &QTcpServer::newConnection, this, &DeviceStatusServer::handleNewConnection);

    m_timer.setInterval(1500);
    connect(&m_timer, &QTimer::timeout, this, &DeviceStatusServer::publishSnapshot);
}

bool DeviceStatusServer::start(quint16 port)
{
    const bool listening = m_server.listen(QHostAddress::LocalHost, port);
    if (listening) {
        m_timer.start();
    }

    return listening;
}

void DeviceStatusServer::handleNewConnection()
{
    while (QTcpSocket *socket = m_server.nextPendingConnection()) {
        m_clients.insert(socket);

        connect(socket, &QTcpSocket::disconnected, this, [this, socket]() {
            removeClient(socket);
        });

        publishSnapshot();
    }
}

void DeviceStatusServer::publishSnapshot()
{
    ++m_tick;

    QJsonObject payload{
        {QStringLiteral("service"), QStringLiteral("device-status-service")},
        {QStringLiteral("deviceId"), QStringLiteral("FG-THERMAL-01")},
        {QStringLiteral("online"), true},
        {QStringLiteral("temperature"), 22 + (m_tick % 5)},
        {QStringLiteral("battery"), 96 - (m_tick % 12)},
        {QStringLiteral("timestamp"), QDateTime::currentDateTimeUtc().toString(Qt::ISODate)}
    };

    const QByteArray message = QJsonDocument(payload).toJson(QJsonDocument::Compact) + '\n';

    for (QTcpSocket *socket : std::as_const(m_clients)) {
        if (socket->state() == QAbstractSocket::ConnectedState) {
            socket->write(message);
            socket->flush();
        }
    }
}

void DeviceStatusServer::removeClient(QTcpSocket *socket)
{
    m_clients.remove(socket);
    socket->deleteLater();
}
