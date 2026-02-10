#include "window_manager.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QIcon>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQuickStyle::setStyle("Basic");

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("snipper", "Main");

    WindowManager* windowManager = engine.singletonInstance<WindowManager*>("snipper", "WindowManager");
    if (windowManager)
        windowManager->setEngine(&engine);

    return app.exec();
}
