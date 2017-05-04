/*
 *  Copyright 2013 Ruediger Gad
 *
 *  This file is part of MeePasswords.
 *
 *  MeePasswords is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  MeePasswords is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with MeePasswords.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "settingsadapter.h"

SettingsAdapter::SettingsAdapter(QObject *parent) :
    QObject(parent)
{
    m_clickToOpen = QSettings().value("clickToOpen", false).toBool();
    m_fastScrollAnchor = QSettings().value("fastScrollAnchor", "right").toString();
    m_fontSize = QSettings().value("fontSize", -1).toInt();
}

bool SettingsAdapter::clickToOpen() {
    return m_clickToOpen;
}

QString SettingsAdapter::fastScrollAnchor() {
    return m_fastScrollAnchor;
}

int SettingsAdapter::getFontSize() {
    return m_fontSize;
}

void SettingsAdapter::setClickToOpen(bool val) {
    m_clickToOpen = val;
    QSettings().setValue("clickToOpen", m_clickToOpen);
    emit clickToOpenChanged(m_clickToOpen);
}

void SettingsAdapter::setFastScrollAnchor(QString anchor) {
    m_fastScrollAnchor = anchor;
    QSettings().setValue("fastScrollAnchor", m_fastScrollAnchor);
    emit fastScrollAnchorChanged(m_fastScrollAnchor);
}

void SettingsAdapter::setFontSize(int fontSize) {
    m_fontSize = fontSize;
    QSettings().setValue("fontSize", m_fontSize);
    emit fontSizeChanged(m_fontSize);
}
