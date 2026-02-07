#ifndef SNIPPER_MANAGER_H
#define SNIPPER_MANAGER_H

#include <QObject>
#include <QQmlEngine>
#include <QQuickWindow>

class SnipperManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QString temp_path READ get_temp_path CONSTANT)

public:
    explicit SnipperManager(QObject *parent = nullptr);
    ~SnipperManager();

    QString get_temp_path() const { return m_temp_path; }

    Q_INVOKABLE void capture_screenshot(QQuickWindow *root_window);
    Q_INVOKABLE void save_cropped_region(const QUrl &image_source, const QRect &crop_rect, const qreal zoom_factor);
    Q_INVOKABLE void copyToClipboard(const QUrl &image_source);

signals:
    void screenshot_captured(const QUrl &screenshot_url);
private:
    QString m_temp_path;
};

#endif // SNIPPER_MANAGER_H
