#include <QCoreApplication>

#include "GameSessionServer.h"

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);

    GameSessionServer server;
    if (!server.start(45455)) {
        return 1;
    }

    return app.exec();
}
