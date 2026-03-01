#pragma once
#ifndef APP_SETTINGS_HPP
#define APP_SETTINGS_HPP

#include <QObject>
#include <QColor>
#include <QQmlEngine>

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

class AppSettings : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    QML_PROPERTY(int, timerDelay, 0)
public:
    explicit AppSettings(QObject *parent = nullptr) : QObject(parent) {}
};

#endif // APP_SETTINGS_HPP
