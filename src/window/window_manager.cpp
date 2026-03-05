#include "window_manager.h"

#include <QQmlComponent>
#include <QGuiApplication>
#include <expected>

WindowManager::WindowManager(QObject *parent): QObject{parent} {
    s_instance = this;
}

std::expected<QQuickWindow*, QString> WindowManager::createPinWindow(const QUrl &imageSourceUrl) {
    if (!m_engine)
        return std::unexpected("Can't pin: QQML Engine not initialized");

    if (imageSourceUrl.isEmpty())
        return std::unexpected("Can't pin: Invalid image source");

    // the window already exists! no duplicates
    QPointer<QQuickWindow> existingWindow = m_pinnedWindows.value(imageSourceUrl);
    if (existingWindow)
        return std::unexpected("Can't have duplicate pins!");

    QQmlComponent component(m_engine, QUrl("qrc:/qml/components/window/FloatingImageWindow.qml")); // this shit needs to be put in resources.qrc, not cmake. why qt? why must you torment
    if (component.isError())
        return std::unexpected("QML Component Error:" + component.errorString());

    QObject *object = component.create();
    if (!object)
        return std::unexpected("Can't pin: Failed to create pin component");

    QQuickWindow *window = qobject_cast<QQuickWindow*>(object);
    if (!window) {
        object->deleteLater();
        return std::unexpected("Can't pin: failed to create window");
    }

    QScreen *screen = QGuiApplication::screenAt(QCursor::pos());
    if (!screen) screen = QGuiApplication::primaryScreen(); // defaulting to primary monitor
    if (!screen)
        return std::unexpected("Can't pin: do you even have a monitor?"); // lol

    m_pinnedWindows.insert(imageSourceUrl, window);

    // &QQuickWindow::closing if the user tries ALT+F4 or closing via other means
    connect(window, &QQuickWindow::closing, this, [this, imageSourceUrl] {
        // when exited, clean up the list containg all pinned windows
        m_pinnedWindows.remove(imageSourceUrl);
        emit pinRemoved(imageSourceUrl); // usually i don't signal in the backend, but, there's no way else to announce this removal
    });

    QRect screenGeometry = screen->geometry();

    int x = screenGeometry.x() + (screenGeometry.width() - window->width()) / 2;
    int y = screenGeometry.y() + (screenGeometry.height() - window->height()) / 2;

    window->setProperty("source", imageSourceUrl);
    window->setPosition(x, y);
    window->show();

    return window;
}

std::expected<void, QString> WindowManager::removePinWindow(const QUrl &imageSourceUrl) {
    if (imageSourceUrl.isEmpty())
        return std::unexpected("Can't remove pin: Invalid image source");

    if (!m_pinnedWindows.contains(imageSourceUrl))
        return std::unexpected("Pin doesn't exist.");

    QPointer<QQuickWindow> window = m_pinnedWindows.take(imageSourceUrl);
    if (!window)
        return std::unexpected("Pin was already lost or destroyed."); // already null, but not removed???

    window->close();
    window->deleteLater();

    return {};
}

std::expected<qsizetype, QString> WindowManager::raiseAllPins() {
    if (m_pinnedWindows.isEmpty())
        return std::unexpected("No pins to raise");

    auto iterator = m_pinnedWindows.begin();
    while (iterator != m_pinnedWindows.end()) {
        QPointer<QQuickWindow> pin = iterator.value();

        if (!pin) {
            iterator = m_pinnedWindows.erase(iterator); // update it bcuz it wasn't deleted :p
            continue;
        }

        pin->raise();
        pin->requestActivate();

        pin->setProperty("clickThrough", false);
        pin->setFlags(pin->flags() & ~Qt::WindowTransparentForInput);

        ++iterator;
    }

    return m_pinnedWindows.size();
}

// == QML SIDE == //
bool WindowManager::requestWindowExists(const QUrl &imageSourceUrl) {
    auto iterator = m_pinnedWindows.find(imageSourceUrl);
    if (iterator == m_pinnedWindows.end()) return false;
    if (iterator->isNull()) {
        m_pinnedWindows.erase(iterator); // just in case it wasn't flagged by WindowManager for deletion
        return false;
    }

    return true;
}

void WindowManager::requestCreatePinWindow(const QUrl &imageSourceUrl) {

    if (imageSourceUrl.isEmpty()) {
        emit errorOccurred("Invalid image source");
        return;
    }

    auto result = createPinWindow(imageSourceUrl);
    if (!result) {
        emit errorOccurred(result.error());
        qDebug() << "requestCreatePinWindow failed:" << result.error();
        return;
    }

    emit pinCreated(result.value());
}

void WindowManager::requestRaiseAllPins() {
    auto result = raiseAllPins();
    if (result)
        emit raisedAllPins(result.value());
    else
        emit errorOccurred(result.error());
}

void WindowManager::requestRemovePinWindow(const QUrl &imageSourceUrl) {
    auto result = removePinWindow(imageSourceUrl);
    if (result) {}
        //emit pinRemoved(imageSourceUrl); // removePinWindow() emits this signal now via &QQuickWindow::closing connection
    else
        emit errorOccurred(result.error());
}
