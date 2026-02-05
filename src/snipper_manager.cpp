#include "snipper_manager.h"

#include <QGuiApplication>
#include <QScreen>
#include <QPixmap>
#include <QTimer>
#include <QStandardPaths>
#include <QDebug>

SnipperManager::SnipperManager(QObject *parent) : QObject(parent) {}

void SnipperManager::capture_screenshot() {
    if (!m_main_window) {
        qWarning() << "SnipperManager: No main window set!";
        return;
    }

    // hide app
    m_main_window->showMinimized();

    // 365ms grace period for the app to hide
    QTimer::singleShot(365, this, [this]() {
        QScreen *screen = m_main_window->screen();
        if (!screen) screen = QGuiApplication::primaryScreen();

        if (!screen) {
            qWarning() << "SnipperManager: Could not detect a screen!";
            return;
        }

        QPixmap screenshot = screen->grabWindow(0);
        QImage image = screenshot.toImage();

        QString path = QStandardPaths::writableLocation(QStandardPaths::TempLocation) + "/screenshot.png";
        if (image.save(path)) {
            qDebug() << "Full screen captured to:" << path;
        }

        // 5. Send it back to QML to show in the Overlay
        emit screenshot_captured(image);
    });
}
