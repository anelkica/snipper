#ifndef COLORHISTORY_H
#define COLORHISTORY_H

#include <QObject>
#include <QQmlEngine>


class ColorHistory : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QVariantList colors READ colors NOTIFY colorsChanged)
public:
    explicit ColorHistory(QObject *parent = nullptr);

    Q_INVOKABLE void add(const QString &hex);
    Q_INVOKABLE void clear();

    QVariantList colors() const;
    Q_INVOKABLE QString colorsToJsonString() const;
signals:
    void colorsChanged();
private:
    QStringList m_colors;
};

#endif // COLORHISTORY_H
