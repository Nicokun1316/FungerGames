#include <QCoreApplication>

#include "DeviceStatusServer.h"

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);

    DeviceStatusServer server;
    if (!server.start(45454)) {
        return 1;
    }

    return app.exec();
}
