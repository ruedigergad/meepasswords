/*
 *  Copyright 2011 Ruediger Gad
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

#include "entry.h"

Entry::Entry(QObject *parent) :
    QObject(parent)
{
}

Entry::Entry(QString name, QString category, QString userName, QString password,
             QString notes, int id, QUuid uuid, QDateTime mtime, QObject *parent) :
    QObject(parent)
{
    m_name = name.trimmed();
    m_category = category.trimmed();
    m_userName = userName.trimmed();
    m_password = password.trimmed();
    m_notes = notes;
    m_id = id;
    m_uuid = uuid;
    m_mtime = mtime;
}

Entry::Entry(const Entry &obj, QObject *parent) :
    QObject(parent)
{
    m_name = obj.name();
    m_category = obj.category();
    m_userName = obj.userName();
    m_password = obj.password();
    m_notes = obj.notes();
    m_id = obj.id();
    m_uuid = obj.m_uuid;
    m_mtime = obj.m_mtime;
}

Entry& Entry::operator = (const Entry &e) {
    m_name = e.m_name;
    m_category = e.m_category;
    m_userName = e.m_userName;
    m_password = e.m_password;
    m_notes = e.m_notes;
    m_id = e.m_id;
    m_uuid = e.m_uuid;
    m_mtime = e.m_mtime;
    return *this;
}


bool entryCompare(const Entry &e1, const Entry &e2){
    if(e1.category() == e2.category()){
        return e1.name() < e2.name();
    }else{
        return e1.category() < e2.category();
    }
}
