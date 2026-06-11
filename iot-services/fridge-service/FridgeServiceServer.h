#pragma once

#include <QObject>
#include <QSet>
#include <QTcpServer>
#include <QTcpSocket>
#include <QTimer>
#include <QVector>

class FridgeServiceServer : public QObject
{
    Q_OBJECT

public:
    explicit FridgeServiceServer(QObject *parent = nullptr);

    bool start(quint16 port);

private slots:
    void handleNewConnection();
    void publishSnapshot();

private:
    struct FridgeEvent {
        QString eventType;
        QString contentType;
        int calories;
    };

    int caloriesForStep(int step) const;
    QString contentTypeForStep(int step) const;
    void removeClient(QTcpSocket *socket);

    QTcpServer m_server;
    QSet<QTcpSocket *> m_clients;
    QTimer m_timer;
    int m_dailyCalories = 0;
    int m_dailyLimit = 1800;
    int m_cycleStep = 0;
};
