#ifndef SNIPPER_H
#define SNIPPER_H

#include <QObject>
#include <QQuickWindow>
#include <qqmlintegration.h>

class Snipper : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    QQuickWindow *main_window = nullptr;

signals:
    void screenshot_captured(const QImage &image);
public:
    explicit Snipper(QObject *parent = nullptr) : QObject(parent) {}

    Q_INVOKABLE void set_main_window(QQuickWindow *window) { main_window = window; };
    Q_INVOKABLE void start_snipping();
private:
    void take_screenshot();
};

#endif // SNIPPER_H
