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
    m_tempFolderPath = QStandardPaths::writableLocation(QStandardPaths::TempLocation) + "/snipper/";

    QDir tempFolder(m_tempFolderPath);
    if (!tempFolder.exists()) tempFolder.mkpath(".");
}

SnipperManager::~SnipperManager() {
    if (m_tempFolderPath.isEmpty()) return; // we don't wanna bomb an entire random location lol

    QDir tempFolder(m_tempFolderPath);
    tempFolder.removeRecursively();
}


std::expected<QUrl, QString> SnipperManager::captureScreenshot(QQuickWindow *rootWindow) {
    if (!rootWindow)
        return std::unexpected("No root window");

    QScreen *screen = rootWindow->screen();
    if (!screen) screen = QGuiApplication::primaryScreen();
    if (!screen) return std::unexpected("No monitors found"); // seriously? how tf are u using a GUI with no monitors??

    QPixmap screenshot = screen->grabWindow(0);
    if (screenshot.isNull()) return std::unexpected("Failed to grab window");

    QString filename = QString("snip_%1.png").arg(QDateTime::currentMSecsSinceEpoch());
    QString fullPath = m_tempFolderPath + filename;

    if (!screenshot.save(fullPath, "PNG")) return std::unexpected("Failed to save: " + fullPath);
    return QUrl::fromLocalFile(fullPath);
}

std::expected<QUrl, QString> SnipperManager::saveCroppedRegion(const QUrl &imageSource, const QRect &cropRect, qreal zoom) {
    if (imageSource.isEmpty())
        return std::unexpected("Image source is missing");

    if (!cropRect.isValid())
        return std::unexpected("Invalid selection area");

    QString imageSourcePath = imageSource.toLocalFile();
    QImage image(imageSourcePath);
    if (image.isNull()) return std::unexpected("Failed to load image from: " + imageSourcePath);

    QImage croppedImage = image.copy(cropRect);

    if (zoom > 1.0) {
        const QSize size = croppedImage.size() * zoom;
        croppedImage = croppedImage.scaled(size, Qt::KeepAspectRatio, Qt::FastTransformation);
        // Qt::FastTransformation = nearest neighbor
    }

    QString desktopPath = QStandardPaths::writableLocation(QStandardPaths::DesktopLocation);
    QString filename =  "snip_" + QDateTime::currentDateTime().toString("yyyyMMdd__hhmmss") + ".png";
    QString finalPath = desktopPath + '/' + filename;

    if (!croppedImage.save(finalPath, "PNG"))
        return std::unexpected("Failed to save: " + finalPath);

    return QUrl::fromLocalFile(finalPath);
}

std::expected<void, QString> SnipperManager::copyToClipboard(const QUrl &imageSource) {
    if (imageSource.isEmpty())
        return std::unexpected("Image source is missing");

    QString imageSourcePath = imageSource.toLocalFile();
    QImage image(imageSourcePath);
    if (image.isNull()) return std::unexpected("Failed to load image from: " + imageSourcePath);

    QClipboard *clipboard = QGuiApplication::clipboard();
    if (!clipboard) return std::unexpected("Clipboard unavailable");

    clipboard->setImage(image);
    return {};
}

// == QML SIDE == //

void SnipperManager::requestCaptureScreenshot(QQuickWindow *rootWindow) {
    if (!rootWindow) {
        emit errorOccurred("Can't capture: no main window found");
        return;
    }

    rootWindow->showMinimized();

    // 365ms waiting period for the window to minimize
    QTimer::singleShot(365, this, [this, rootWindow] {
        if (!rootWindow) return; // just in case tbh

        auto result = captureScreenshot(rootWindow);
        if (result)
            emit screenshotCaptured(*result);
        else
            emit errorOccurred(result.error());

        rootWindow->showNormal();
    });
}

void SnipperManager::requestCopyToClipboard(const QUrl &imageSource) {
    if (imageSource.isEmpty()) {
        emit errorOccurred("Nothing to copy");
        return;
    }

    auto result = copyToClipboard(imageSource);
    if (result)
        emit cropCopiedToClipboard();
    else
        emit errorOccurred(result.error());
}

void SnipperManager::requestSaveCroppedRegion(const QUrl &imageSource, const QRect &cropRect, qreal zoom) {
    if (imageSource.isEmpty()) {
        emit errorOccurred("Can't save: invalid image source");
        return;
    }

    if (!cropRect.isValid()) {
        emit errorOccurred("Can't save: invalid selection area");
        return;
    }

    auto result = saveCroppedRegion(imageSource, cropRect, zoom);
    if (result)
        emit cropSaved(*result);
    else
        emit errorOccurred(result.error());
}
