#ifndef APPSTATE_H
#define APPSTATE_H

#include <QObject>
#include <QQmlEngine>

class AppState : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QUrl currentScreenshotUrl READ currentScreenshotUrl WRITE setCurrentScreenshotUrl NOTIFY currentScreenshotUrlChanged)

    Q_PROPERTY(bool isPickingColor READ isPickingColor WRITE setIsPickingColor NOTIFY isPickingColorChanged)
    Q_PROPERTY(int timerDelay READ timerDelay WRITE setTimerDelay NOTIFY timerDelayChanged)

public:
    explicit AppState(QObject *parent = nullptr) {};

    bool isPickingColor() const;
    void setIsPickingColor(bool newIsPickingColor);
    int timerDelay() const;
    void setTimerDelay(int newTimerDelay);

    QUrl currentScreenshotUrl() const;
    void setCurrentScreenshotUrl(const QUrl &newCurrentScreenshotUrl);

signals:
    void isPickingColorChanged();
    void timerDelayChanged();
    void currentScreenshotUrlChanged();

private:
    bool m_isPickingColor = false;
    int m_timerDelay = 0;
    QUrl m_currentScreenshotUrl;
};

// -- STUFF QT CREATOR GENERATES VIA Refactor MACRO -- //

inline QUrl AppState::currentScreenshotUrl() const
{
    return m_currentScreenshotUrl;
}

inline void AppState::setCurrentScreenshotUrl(const QUrl &newCurrentScreenshotUrl)
{
    if (m_currentScreenshotUrl == newCurrentScreenshotUrl)
        return;
    m_currentScreenshotUrl = newCurrentScreenshotUrl;
    emit currentScreenshotUrlChanged();
}

inline int AppState::timerDelay() const
{
    return m_timerDelay;
}

inline void AppState::setTimerDelay(int newTimerDelay)
{
    if (m_timerDelay == newTimerDelay)
        return;
    m_timerDelay = newTimerDelay;
    emit timerDelayChanged();
}

inline bool AppState::isPickingColor() const
{
    return m_isPickingColor;
}

inline void AppState::setIsPickingColor(bool newIsPickingColor)
{
    if (m_isPickingColor == newIsPickingColor)
        return;
    m_isPickingColor = newIsPickingColor;
    emit isPickingColorChanged();
}

#endif // APPSTATE_H
