#include "FridgeServiceServer.h"

#include <QDateTime>
#include <QJsonDocument>
#include <QJsonObject>

FridgeServiceServer::FridgeServiceServer(QObject *parent)
    : QObject(parent)
{
    connect(&m_server, &QTcpServer::newConnection, this, &FridgeServiceServer::handleNewConnection);

    m_timer.setInterval(1000);
    connect(&m_timer, &QTimer::timeout, this, &FridgeServiceServer::publishSnapshot);
}

bool FridgeServiceServer::start(quint16 port)
{
    const bool listening = m_server.listen(QHostAddress::LocalHost, port);
    if (listening) {
        m_timer.start();
    }

    return listening;
}

void FridgeServiceServer::handleNewConnection()
{
    while (QTcpSocket *socket = m_server.nextPendingConnection()) {
        m_clients.insert(socket);

        connect(socket, &QTcpSocket::disconnected, this, [this, socket]() {
            removeClient(socket);
        });

        publishSnapshot();
    }
}

void FridgeServiceServer::publishSnapshot()
{
    const int nextCalories = caloriesForStep(m_cycleStep);
    const int delta = nextCalories - m_dailyCalories;
    const QString eventType = delta >= 0 ? QStringLiteral("load") : QStringLiteral("unload");
    const QString contentType = contentTypeForStep(m_cycleStep);
    const int eventCalories = qAbs(delta);
    m_dailyCalories = nextCalories;

    const int dailyDeficit = m_dailyLimit - m_dailyCalories;

    QJsonObject payload{
        {QStringLiteral("service"), QStringLiteral("fridge-service")},
        {QStringLiteral("eventType"), eventType},
        {QStringLiteral("contentType"), contentType},
        {QStringLiteral("eventCalories"), eventCalories},
        {QStringLiteral("dailyCalories"), m_dailyCalories},
        {QStringLiteral("dailyDeficit"), dailyDeficit},
        {QStringLiteral("dailyLimit"), m_dailyLimit},
        {QStringLiteral("timestamp"), QDateTime::currentDateTimeUtc().toString(Qt::ISODate)}
    };

    const QByteArray encoded = QJsonDocument(payload).toJson(QJsonDocument::Compact) + '\n';

    for (QTcpSocket *socket : std::as_const(m_clients)) {
        if (socket->state() == QAbstractSocket::ConnectedState) {
            socket->write(encoded);
            socket->flush();
        }
    }

    m_cycleStep = (m_cycleStep + 1) % 21;
}

void FridgeServiceServer::removeClient(QTcpSocket *socket)
{
    m_clients.remove(socket);
    socket->deleteLater();
}

int FridgeServiceServer::caloriesForStep(int step) const
{
    if (step <= 10) {
        return step * 120;
    }

    return 1200 + ((step - 10) * 120);
}

QString FridgeServiceServer::contentTypeForStep(int step) const
{
    if (step == 0) {
        return QStringLiteral("reset");
    }

    if (step <= 3) {
        return QStringLiteral("fruit");
    }

    if (step <= 7) {
        return QStringLiteral("meal");
    }

    if (step <= 10) {
        return QStringLiteral("drink");
    }

    if (step <= 15) {
        return QStringLiteral("snack");
    }

    return QStringLiteral("dessert");
}
