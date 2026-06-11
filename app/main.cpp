#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "AppController.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    AppController controller;

    engine.rootContext()->setContextProperty(QStringLiteral("appController"), &controller);
    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/FungerGames/Main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return 1;
    }

    return app.exec();
}
