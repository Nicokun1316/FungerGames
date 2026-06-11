#include "FaceTrackingServer.h"

#include <QDateTime>
#include <QJsonDocument>
#include <QJsonObject>

FaceTrackingServer::FaceTrackingServer(QObject *parent)
    : QObject(parent)
{
    connect(&m_server, &QTcpServer::newConnection, this, &FaceTrackingServer::handleNewConnection);
}

bool FaceTrackingServer::start(quint16 port)
{
    return m_server.listen(QHostAddress::LocalHost, port);
}

void FaceTrackingServer::handleNewConnection()
{
    while (QTcpSocket *socket = m_server.nextPendingConnection()) {
        m_clients.insert(socket);
        m_buffers.insert(socket, QByteArray{});

        connect(socket, &QTcpSocket::readyRead, this, [this, socket]() {
            handleReadyRead(socket);
        });
        connect(socket, &QTcpSocket::disconnected, this, [this, socket]() {
            removeClient(socket);
        });

        broadcastSnapshot();
    }
}

void FaceTrackingServer::handleReadyRead(QTcpSocket *socket)
{
    QByteArray &buffer = m_buffers[socket];
    buffer.append(socket->readAll());

    while (true) {
        const int newlineIndex = buffer.indexOf('\n');
        if (newlineIndex < 0) {
            break;
        }

        const QByteArray line = buffer.left(newlineIndex).trimmed();
        buffer.remove(0, newlineIndex + 1);

        if (!line.isEmpty()) {
            consumeLine(line);
        }
    }
}

void FaceTrackingServer::removeClient(QTcpSocket *socket)
{
    m_clients.remove(socket);
    m_buffers.remove(socket);
    socket->deleteLater();
}

void FaceTrackingServer::consumeLine(const QByteArray &line)
{
    const QJsonDocument document = QJsonDocument::fromJson(line);
    if (!document.isObject()) {
        return;
    }

    const QVariantMap payload = document.object().toVariantMap();
    m_focusX = qBound<qreal>(0.0, payload.value(QStringLiteral("x")).toDouble(), 1.0);
    m_focusY = qBound<qreal>(0.0, payload.value(QStringLiteral("y")).toDouble(), 1.0);

    m_smoothedX = (m_smoothedX * 0.72) + (m_focusX * 0.28);
    m_smoothedY = (m_smoothedY * 0.72) + (m_focusY * 0.28);

    broadcastSnapshot();
}

void FaceTrackingServer::broadcastSnapshot()
{
    QJsonObject payload{
        {QStringLiteral("service"), QStringLiteral("face-tracking-service")},
        {QStringLiteral("focusX"), m_focusX},
        {QStringLiteral("focusY"), m_focusY},
        {QStringLiteral("smoothedX"), m_smoothedX},
        {QStringLiteral("smoothedY"), m_smoothedY},
        {QStringLiteral("timestamp"), QDateTime::currentDateTimeUtc().toString(Qt::ISODate)}
    };

    const QByteArray encoded = QJsonDocument(payload).toJson(QJsonDocument::Compact) + '\n';

    for (QTcpSocket *socket : std::as_const(m_clients)) {
        if (socket->state() == QAbstractSocket::ConnectedState) {
            socket->write(encoded);
            socket->flush();
        }
    }
}
