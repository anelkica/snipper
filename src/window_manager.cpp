#include "window_manager.h"

#include <QQmlComponent>
#include <QGuiApplication>
#include <expected>

WindowManager::WindowManager(QObject *parent): QObject{parent} {}

std::expected<QQuickWindow*, QString> WindowManager::createPinWindow(const QUrl &imageSourceUrl) {
    if (!m_engine)
        return std::unexpected("Can't pin: QQML Engine not initialized");

    if (imageSourceUrl.isEmpty())
        return std::unexpected("Can't pin: Invalid image source");

    // the window already exists! no duplicates
    QPointer<QQuickWindow> existingWindow = m_pinnedWindows.value(imageSourceUrl);
    if (existingWindow)
        return std::unexpected("Can't have duplicate pins!");

    QQmlComponent component(m_engine, QUrl("qrc:/qml/FloatingImageWindow.qml")); // i forgot to add this shit to cmake oml.
    if (component.isError())
        return std::unexpected("QML Component Error:" + component.errorString());

    QObject *object = component.create();
    if (!object)
        return std::unexpected("Can't pin: Failed to create pin component");

    QQuickWindow *window = qobject_cast<QQuickWindow*>(object);
    if (!window) {
        delete object;
        return std::unexpected("Can't pin: failed to create window");
    }

    QScreen *screen = QGuiApplication::screenAt(QCursor::pos());
    if (!screen) screen = QGuiApplication::primaryScreen(); // defaulting to primary monitor
    if (!screen)
        return std::unexpected("Can't pin: do you even have a monitor?"); // lol

    m_pinnedWindows.insert(imageSourceUrl, window);

    connect(window, &QObject::destroyed, this, [this, imageSourceUrl] {
        // when exited, clean up the list containg all pinned windows
        m_pinnedWindows.remove(imageSourceUrl);
    });

    QRect screenGeometry = screen->geometry();

    int x = screenGeometry.x() + (screenGeometry.width() - window->width()) / 2;
    int y = screenGeometry.y() + (screenGeometry.height() - window->height()) / 2;

    window->setProperty("source", imageSourceUrl);
    window->setPosition(x, y);
    window->show();

    return window;
}

// == QML SIDE == //
void WindowManager::requestCreatePinWindow(const QUrl &imageSourceUrl) {

    if (imageSourceUrl.isEmpty()) {
        emit errorOccurred("Invalid image source");
        return;
    }

    auto result = createPinWindow(imageSourceUrl);
    if (!result) {
        emit errorOccurred(result.error());
        return;
    }

    emit pinCreated(result.value());
}
