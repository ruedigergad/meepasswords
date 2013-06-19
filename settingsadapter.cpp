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
    m_fastScrollAnchor = QSettings().value("fastScrollAnchor", "right").toString();
}

QString SettingsAdapter::fastScrollAnchor() {
    return m_fastScrollAnchor;
}

void SettingsAdapter::setFastScrollAnchor(QString anchor) {
    m_fastScrollAnchor = anchor;
    QSettings().setValue("fastScrollAnchor", m_fastScrollAnchor);
    emit fastScrollAnchorChanged(m_fastScrollAnchor);
}
