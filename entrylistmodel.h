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

#ifndef ENTRYLISTMODEL_H
#define ENTRYLISTMODEL_H

#include <QAbstractListModel>
#include <QStringList>

#include "entry.h"

#define CSV_SEP "\t"
#define CSV_NL "\n"

class EntryListModel : public QAbstractListModel
{
    Q_OBJECT
    // Needed to make SectionScroller happy.
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum EntryRoles {
        NameRole = Qt::UserRole + 1,
        CategoryRole,
        UserNameRole,
        PasswordRole,
        NotesRole,
        IdRole,
        UuidRole,
        MtimeRole
    };

    EntryListModel(QObject *parent = 0);

    Q_INVOKABLE void addEntry(Entry &entry);
    Q_INVOKABLE void addEntry(QString name, QString category, QString userName, QString password, QString notes);
    Q_INVOKABLE void addFromByteArray(QByteArray &data);

    Q_INVOKABLE Entry* at(int index);
    // Needed to make SectionScroller happy.
    Q_INVOKABLE Entry* get(int index) { return at(index); }

    Q_INVOKABLE void clear();

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    Q_INVOKABLE int rowCount(const QModelIndex &parent = QModelIndex()) const;

    Q_INVOKABLE void removeAt(int index);
    void removeById(int id);
    QByteArray toByteArray();
    Q_INVOKABLE void updateEntryAt(int index, QString name, QString category, QString userName, QString password, QString notes);

    QList<Entry> getEntryList() const { return m_entries; }
    void appendEntries(const QList<Entry> entries);
    Q_INVOKABLE QStringList getItemNames() const;
    Q_INVOKABLE void addOrUpdateEntry(QString name, QString category, QString userName, QString password, QString notes, int id);


signals:
    void changed();
    void countChanged(int count);

private:
    QList<Entry> m_entries;

    /**
      * Adds an entry to the list. While updating the model this method does <b>not</b> emit the changed() signal.
      */
    void add(Entry &entry);
    /**
      * Remove an entry from the list. While updating the model this method does <b>not</b> emit the changed() signal.
      */
    void remove(int index);

};

#endif // ENTRYLISTMODEL_H
