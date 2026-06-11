#pragma once

#include <QObject>
#include <QHash>
#include <QSet>
#include <QTcpServer>
#include <QTcpSocket>

class FaceTrackingServer : public QObject
{
    Q_OBJECT

public:
    explicit FaceTrackingServer(QObject *parent = nullptr);

    bool start(quint16 port);

private slots:
    void handleNewConnection();

private:
    void handleReadyRead(QTcpSocket *socket);
    void removeClient(QTcpSocket *socket);
    void consumeLine(const QByteArray &line);
    void broadcastSnapshot();

    QTcpServer m_server;
    QSet<QTcpSocket *> m_clients;
    QHash<QTcpSocket *, QByteArray> m_buffers;
    qreal m_focusX = 0.5;
    qreal m_focusY = 0.5;
    qreal m_smoothedX = 0.5;
    qreal m_smoothedY = 0.5;
};
