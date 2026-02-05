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

public:
    explicit SnipperManager(QObject *parent = nullptr);

    QQuickWindow* main_window() { return m_main_window; }
    Q_INVOKABLE void set_main_window(QQuickWindow *window) { m_main_window = window; }

    Q_INVOKABLE void capture_screenshot();
signals:
    void screenshot_captured(const QImage &image);
private:
    QQuickWindow *m_main_window = nullptr;
};

#endif // SNIPPER_MANAGER_H
