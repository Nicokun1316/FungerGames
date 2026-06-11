#include <QCoreApplication>

#include "FridgeServiceServer.h"

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);

    FridgeServiceServer server;
    if (!server.start(45455)) {
        return 1;
    }

    return app.exec();
}
