#ifndef SNIPPER_MANAGER_H
#define SNIPPER_MANAGER_H

#include <expected>
#include <QObject>
#include <QQmlEngine>
#include <QQuickWindow>

class SnipperManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QString tempFolderPath READ getTempFolderPath CONSTANT)

public:
    explicit SnipperManager(QObject *parent = nullptr);
    ~SnipperManager();

    QString getTempFolderPath() const { return m_tempFolderPath; }

    std::expected<QUrl, QString> captureScreenshot(QQuickWindow *rootWindow);
    std::expected<QUrl, QString> saveCroppedRegion(const QUrl &imageSource, const QRect &cropRect, qreal zoom);
    std::expected<void, QString> copyToClipboard(const QUrl &imageSource);
    std::expected<QUrl, QString> saveCropAs(const QUrl &imageSource);

    // FOR QML !!
    Q_INVOKABLE void requestCaptureScreenshot(QQuickWindow *rootWindow);
    Q_INVOKABLE void requestCopyToClipboard(const QUrl &imageSource);
    Q_INVOKABLE void requestSaveCroppedRegion(const QUrl &imageSource, const QRect &cropRect, qreal zoom);
    Q_INVOKABLE void requestSaveCropAs(const QUrl &imageSource);

signals:
    void screenshotCaptured(const QUrl &screenshotUrl);
    void cropSaved(const QUrl &croppedImageUrl);
    void cropCopiedToClipboard();
    void errorOccurred(const QString &message);
private:
    QString m_tempFolderPath;
};

#endif // SNIPPER_MANAGER_H
