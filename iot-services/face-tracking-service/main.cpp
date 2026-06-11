#include <QCoreApplication>

#include "FaceTrackingServer.h"

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);

    FaceTrackingServer server;
    if (!server.start(45454)) {
        return 1;
    }

    return app.exec();
}
