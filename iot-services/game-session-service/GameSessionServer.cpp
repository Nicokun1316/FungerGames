#include "GameSessionServer.h"

#include <QDateTime>
#include <QJsonDocument>
#include <QJsonObject>

GameSessionServer::GameSessionServer(QObject *parent)
    : QObject(parent)
{
    connect(&m_server, &QTcpServer::newConnection, this, &GameSessionServer::handleNewConnection);

    m_timer.setInterval(2000);
    connect(&m_timer, &QTimer::timeout, this, &GameSessionServer::publishSnapshot);
}

bool GameSessionServer::start(quint16 port)
{
    const bool listening = m_server.listen(QHostAddress::LocalHost, port);
    if (listening) {
        m_timer.start();
    }

    return listening;
}

void GameSessionServer::handleNewConnection()
{
    while (QTcpSocket *socket = m_server.nextPendingConnection()) {
        m_clients.insert(socket);

        connect(socket, &QTcpSocket::disconnected, this, [this, socket]() {
            removeClient(socket);
        });

        publishSnapshot();
    }
}

void GameSessionServer::publishSnapshot()
{
    static const QStringList roundStates{
        QStringLiteral("Lobby"),
        QStringLiteral("Draft"),
        QStringLiteral("Expedition"),
        QStringLiteral("Boss Encounter")
    };

    ++m_tick;
    const int index = m_tick % roundStates.size();

    QJsonObject payload{
        {QStringLiteral("service"), QStringLiteral("game-session-service")},
        {QStringLiteral("title"), QStringLiteral("Funger Arena Prototype")},
        {QStringLiteral("playersOnline"), 12 + (m_tick % 9)},
        {QStringLiteral("roundState"), roundStates.at(index)},
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

void GameSessionServer::removeClient(QTcpSocket *socket)
{
    m_clients.remove(socket);
    socket->deleteLater();
}
