#include "snipper_manager.h"

#include <QGuiApplication>
#include <QScreen>
#include <QPixmap>
#include <QTimer>
#include <QStandardPaths>
#include <QDebug>
#include <QDir>
#include <QClipboard>

SnipperManager::SnipperManager(QObject *parent) : QObject(parent) {
    m_temp_path = QStandardPaths::writableLocation(QStandardPaths::TempLocation) + "/snipper/";

    QDir temp_dir(m_temp_path);
    if (!temp_dir.exists()) temp_dir.mkpath(".");
}

SnipperManager::~SnipperManager() {
    if (m_temp_path.isEmpty()) return; // we don't wanna bomb an entire random location lol

    QDir temp_dir(m_temp_path);
    temp_dir.removeRecursively();
}


void SnipperManager::capture_screenshot(QQuickWindow *root_window) {
    if (!root_window) {
        qWarning() << "SnipperManager: No root window set!";
        return;
    }

    root_window->showMinimized();

    // 365ms grace period for the app to hide
    QTimer::singleShot(365, this, [this, root_window]() {
        QScreen *screen = root_window->screen();

        if (!screen) screen = QGuiApplication::primaryScreen();
        if (!screen) return; // do you not have a monitor??

        QPixmap screenshot = screen->grabWindow(0);

        QString unique_filename = QString("snip_%1.png").arg(QDateTime::currentMSecsSinceEpoch());
        QString full_screenshot_path = m_temp_path + unique_filename;

        if (screenshot.save(full_screenshot_path, "PNG")) {
            QUrl screenshot_url = QUrl::fromLocalFile(full_screenshot_path);

            emit screenshot_captured(screenshot_url);

        } else {
            qWarning() << "SnipperManager: Failed to save screenshot: " << full_screenshot_path;
        }

        //root_window->raise();
        //root_window->requestActivate();
    });
}

void SnipperManager::save_cropped_region(const QUrl &image_source_url, const QRect &crop_rect, const qreal zoom_factor) {
    QString image_source_path = image_source_url.toLocalFile();

    if (image_source_path.isEmpty() || crop_rect.isEmpty()) return;

    QImage full_image(image_source_path);
    if (full_image.isNull()) return;

    QImage cropped_image = full_image.copy(crop_rect);

    if (zoom_factor > 1.0) {
        const int new_width = qRound(cropped_image.width() * zoom_factor);
        const int new_height = qRound(cropped_image.height() * zoom_factor);

        // Qt::FastTransformation = nearest neighbor
        cropped_image = cropped_image.scaled(new_width, new_height, Qt::KeepAspectRatio, Qt::FastTransformation);
    }

    QString desktop_path = QStandardPaths::writableLocation(QStandardPaths::DesktopLocation);
    QString unique_filename_path = desktop_path + "/snip_" + QDateTime::currentDateTime().toString("yyyyMMdd__hhmmss") + ".png";

    qDebug() << "Saved to: " << unique_filename_path;
    cropped_image.save(unique_filename_path);
}

void SnipperManager::copyToClipboard(const QUrl &imageSourceUrl) {
    QString imageSourcePath = imageSourceUrl.toLocalFile();
    QImage image(imageSourcePath);

    if (image.isNull()) return;

    QClipboard *clipboard = QGuiApplication::clipboard();
    clipboard->setImage(image);
}
