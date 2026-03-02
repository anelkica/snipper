#ifndef APPSTATE_H
#define APPSTATE_H

#include <QObject>
#include <QQmlEngine>
#include "window_manager.h"

// macros are evil, but this requires like 60% less boilerplate code
// this macro defines getters, setters and signals

#define QML_PROPERTY(type, name, defaultValue) \
Q_PROPERTY(type name READ name WRITE set##name NOTIFY name##Changed) \
    public: \
    type name() const { return m_##name; } \
    void set##name(const type& value) { \
        if (m_##name != value) { \
            m_##name = value; \
            emit name##Changed(value); \
    } \
} \
    Q_SIGNAL void name##Changed(const type& value); \
    private: \
    type m_##name = defaultValue;


class AppState : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON


    QML_PROPERTY(QUrl, currentScreenshotUrl, QUrl())
    QML_PROPERTY(bool, isCurrentScreenshotPinned, false)

    QML_PROPERTY(bool, isSnipping, false)
    QML_PROPERTY(bool, isPickingColor, false)


public:
    explicit AppState(QObject *parent = nullptr) {}
};

#endif // APPSTATE_H
