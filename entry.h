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

#ifndef ENTRY_H
#define ENTRY_H

#include <QObject>
#include <QString>

class Entry : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString category READ category WRITE setCategory NOTIFY categoryChanged)
    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString notes READ notes WRITE setNotes NOTIFY notesChanged)
    Q_PROPERTY(QString userName READ userName WRITE setUserName NOTIFY userNameChanged)

public:
    Entry(QObject *parent = 0);
    Entry(QString name, QString category, QString userName, QString password, QString notes, QObject *parent = 0);
    Entry(const Entry &obj, QObject *parent = 0);

    Entry& operator = (const Entry &e);

    QString category() const { return m_category; }
    QString password() const { return m_password; }
    QString notes() const { return m_notes; }
    QString name() const { return m_name; }
    QString userName() const { return m_userName; }

    void setCategory(QString category){
        m_category = category;
        emit categoryChanged(category);
    }
    void setPassword(QString password){
        m_password = password;
        emit passwordChanged(password);
    }
    void setName(QString name){
        m_name = name;
        emit nameChanged(name);
    }
    void setNotes(QString notes){
        m_notes = notes;
        emit notesChanged(notes);
    }
    void setUserName(QString userName){
        m_userName = userName;
        emit userNameChanged(userName);
    }

signals:
    void categoryChanged(QString);
    void passwordChanged(QString);
    void nameChanged(QString);
    void notesChanged(QString);
    void userNameChanged(QString);

private:
    QString m_category;
    QString m_password;
    QString m_name;
    QString m_notes;
    QString m_userName;

};

bool entryCompare(const Entry &e1, const Entry &e2);

#endif // ENTRY_H
