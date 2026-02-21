#include "colorhistory.h"
#include <QJsonArray>

ColorHistory::ColorHistory(QObject *parent) : QObject{parent} {}

void ColorHistory::add(const QString &hex) {
    if (m_colors.contains(hex)) return;

    m_colors.prepend(hex); // new hex goes first
    emit colorsChanged();
}

void ColorHistory::clear() {
    m_colors.clear();
    emit colorsChanged();
}

QString ColorHistory::colorsToJsonString() const {
    QJsonArray array;
    for (const QString &hex : m_colors)
        array.append(hex);

    return QJsonDocument(array).toJson(QJsonDocument::Compact);
}

QVariantList ColorHistory::colors() const {
    QVariantList result;

    for (const QString &hex : m_colors)
        result.append(hex);

    return result;
}
