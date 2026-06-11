#pragma once

#include <QObject>
#include <QSet>
#include <QTcpServer>
#include <QTcpSocket>
#include <QTimer>

class DeviceStatusServer : public QObject
{
    Q_OBJECT

public:
    explicit DeviceStatusServer(QObject *parent = nullptr);

    bool start(quint16 port);

private slots:
    void handleNewConnection();
    void publishSnapshot();

private:
    void removeClient(QTcpSocket *socket);

    QTcpServer m_server;
    QSet<QTcpSocket *> m_clients;
    QTimer m_timer;
    int m_tick = 0;
};
