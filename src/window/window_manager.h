#ifndef WINDOW_MANAGER_H
#define WINDOW_MANAGER_H

#include <expected>
#include <QObject>
#include <QQUickWindow>
#include <QQmlEngine>

class WindowManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
public:
    explicit WindowManager(QObject *parent = nullptr);
    static WindowManager* instance() { return s_instance; }
    void setEngine(QQmlEngine *engine) { m_engine = engine; }

    std::expected<QQuickWindow*, QString> createPinWindow(const QUrl &imageSourceUrl);
    std::expected<void, QString> removePinWindow(const QUrl &imageSourceUrl);
    std::expected<qsizetype, QString> raiseAllPins();


    Q_INVOKABLE bool requestWindowExists(const QUrl &imageSourceUrl);
    Q_INVOKABLE void requestRaiseAllPins();
    Q_INVOKABLE void requestCreatePinWindow(const QUrl &imageSourceUrl);
    Q_INVOKABLE void requestRemovePinWindow(const QUrl &imageSourceUrl);

signals:
    void errorOccurred(const QString &message);
    void pinCreated(QQuickWindow* pinWindow);
    void pinRemoved(const QUrl &imageSourceUrl);
    void raisedAllPins(qsizetype amountOfPins);

private:
    static inline WindowManager* s_instance = nullptr;
    QQmlEngine *m_engine = nullptr;
    // so basically, the key is the image source URL, and value is the window
    // image soure URLs are unique, so we'll use that ez
    QHash<QUrl, QPointer<QQuickWindow>> m_pinnedWindows;
};

#endif // WINDOW_MANAGER_H
