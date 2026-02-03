#include "snipper.h"

#include <QDebug>
#include <QGuiApplication>
#include <QPixmap>
#include <QScreen>
#include <QStandardPaths>
#include <QTimer>
#include <QWindow>

void Snipper::start_snipping() {
    if (!main_window) return;

    main_window->showMinimized();

    // 365ms grace period for the app to minimize
    QTimer::singleShot(365, this, &Snipper::take_screenshot);
}

void Snipper::take_screenshot() {
    QScreen *screen = main_window->screen(); // screenshots whatever monitor it's on
    if (!screen) return;

    const QPixmap screenshot = screen->grabWindow(0);
    const QImage image = screenshot.toImage();
    const QString image_path = QStandardPaths::writableLocation(QStandardPaths::TempLocation) + "/screenshot.png"; // temp folder

    image.save(image_path);

    emit screenshot_captured(image);
}
