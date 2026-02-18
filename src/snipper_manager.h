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
    std::expected<QUrl, QString> saveCropAs(const QUrl &imageSource, const QUrl &userSelectedPath);

    std::expected<void, QString> copyToClipboard(const QUrl &imageSource); // refactor name?
    std::expected<void, QString> copyTextToClipboard(const QString &text);

    std::expected<QPair<QPoint, QColor>, QString> pickColorAtCursor();

    // FOR QML !!
    Q_INVOKABLE void requestCaptureScreenshot(QQuickWindow *rootWindow);

    Q_INVOKABLE void requestCopyToClipboard(const QUrl &imageSource);
    Q_INVOKABLE bool requestCopyTextToClipboard(const QString &text);

    Q_INVOKABLE void requestSaveCroppedRegion(const QUrl &imageSource, const QRect &cropRect, qreal zoom);
    Q_INVOKABLE void requestSaveCropAs(const QUrl &imageSource, const QUrl &userSelectedPath);

    Q_INVOKABLE QVariantMap requestColorAtCursor();

signals:
    void screenshotCaptured(const QUrl &screenshotUrl, QScreen *currentScreen);

    void cropSaved(const QUrl &croppedImageUrl);
    void cropCopiedToClipboard();

    void colorPicked(QPoint globalCursorPosition, const QColor &color, const QString &hexColor);

    void errorOccurred(const QString &message);
private:
    QString m_tempFolderPath;
};

#endif // SNIPPER_MANAGER_H
