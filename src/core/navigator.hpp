#pragma once
#ifndef NAVIGATOR_HPP
#define NAVIGATOR_HPP

#include <QObject>
#include <QStack>
#include <QQuickItem>
#include <QQmlEngine>

// connected in Main.qml

class Navigator : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QString currentPage READ currentPage NOTIFY currentPageChanged)
    Q_PROPERTY(bool canGoBack READ canGoBack NOTIFY canGoBackChanged)
public:
    explicit Navigator(QObject *parent = nullptr) : QObject(parent) {}

    QString currentPage() const { return m_pageStack.isEmpty() ? "" : m_pageStack.top(); }
    bool canGoBack() const { return m_canGoBack; }

    Q_INVOKABLE void setStackView(QQuickItem *stackView) {
        m_stackView = stackView;
        m_pageStack.push("pages/MainPage.qml"); // syncing with stackview element
    }

    // format: pages/PageName.qml
    Q_INVOKABLE void push(const QString &page) {
        if (!m_stackView) return;
        if (!m_pageStack.isEmpty() && m_pageStack.top() == page) return;
        m_pageStack.push(page);
        QUrl url("qrc:/qml/" + page);
        emit pushRequested(url);
        emit currentPageChanged();
        setCanGoBack(true);
    }
    Q_INVOKABLE void pop() {
        if (!m_stackView) return;
        if (!m_pageStack.isEmpty()) m_pageStack.pop();
        emit popRequested();
        emit currentPageChanged();
        int depth = m_stackView->property("depth").toInt();
        setCanGoBack(depth > 1);
    }
signals:
    void canGoBackChanged();
    void currentPageChanged();
    void pushRequested(const QUrl &url);
    void popRequested();
private:
    QStack<QString> m_pageStack;
    void setCanGoBack(bool value) {
        if (m_canGoBack == value) return;
        m_canGoBack = value;
        emit canGoBackChanged();
    }

    bool m_canGoBack = false;
    QPointer<QQuickItem> m_stackView; // stackview in Main.qml
};

#endif // NAVIGATOR_HPP
