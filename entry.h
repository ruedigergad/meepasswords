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
#include <QUuid>
#include <QDateTime>

class Entry : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString category READ category WRITE setCategory NOTIFY categoryChanged)
    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString notes READ notes WRITE setNotes NOTIFY notesChanged)
    Q_PROPERTY(QString userName READ userName WRITE setUserName NOTIFY userNameChanged)
    Q_PROPERTY(int id READ id NOTIFY idChanged)
    Q_PROPERTY(QString uuid READ uuid)
    Q_PROPERTY(QString mtime READ mtime NOTIFY mtimeChanged)
    Q_PROPERTY(QString mtimeInt READ mtimeInt)

public:
    Entry(QObject *parent = 0);
    Entry(QString name, QString category, QString userName, QString password,
          QString notes, int id, QUuid uuid = QUuid::createUuid(), QDateTime mtime = QDateTime::currentDateTimeUtc(),
          QObject *parent = 0);
    Entry(const Entry &obj, QObject *parent = 0);

    Entry& operator = (const Entry &e);

    QString category() const { return m_category; }
    QString password() const { return m_password; }
    QString notes() const { return m_notes; }
    QString name() const { return m_name; }
    QString userName() const { return m_userName; }
    int id() const { return m_id; }
    QString uuid() const { return QString(m_uuid.toRfc4122().toBase64()); }
    QString mtime() const { return m_mtime.toString(Qt::ISODate); }
    qint64 mtimeInt() const { return m_mtime.toMSecsSinceEpoch(); }

    void setCategory(QString category){
        m_category = category;
        m_mtime = QDateTime::currentDateTimeUtc();
        emit categoryChanged(category);
        emit mtimeChanged(mtime());
    }
    void setPassword(QString password){
        m_password = password;
        m_mtime = QDateTime::currentDateTimeUtc();
        emit passwordChanged(password);
        emit mtimeChanged(mtime());
    }
    void setName(QString name){
        m_name = name;
        m_mtime = QDateTime::currentDateTimeUtc();
        emit nameChanged(name);
        emit mtimeChanged(mtime());
    }
    void setNotes(QString notes){
        m_notes = notes;
        m_mtime = QDateTime::currentDateTimeUtc();
        emit notesChanged(notes);
        emit mtimeChanged(mtime());
    }
    void setUserName(QString userName){
        m_userName = userName;
        m_mtime = QDateTime::currentDateTimeUtc();
        emit userNameChanged(userName);
        emit mtimeChanged(mtime());
    }
    void setId(int id){
        m_id = id;
        emit idChanged(id);
    }

signals:
    void categoryChanged(QString);
    void passwordChanged(QString);
    void nameChanged(QString);
    void notesChanged(QString);
    void userNameChanged(QString);
    void idChanged(int);
    void mtimeChanged(QString);

private:
    QString m_category;
    QString m_password;
    QString m_name;
    QString m_notes;
    QString m_userName;
    int m_id;
    QUuid m_uuid;
    QDateTime m_mtime;

};

bool entryCompare(const Entry &e1, const Entry &e2);

#endif // ENTRY_H
