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

#include "entrylistmodel.h"

#include <QTextStream>
#include <QDebug>

#include "keepassxmlstreamreader.h"
#include "keepassxmlstreamwriter.h"

EntryListModel::EntryListModel(QObject *parent) :
    QAbstractListModel(parent)
{
    qDebug("EntryListModel constructor.");
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    /*
     * Needed to make SectionScroller happy.
     * Take care to give the property used for naming the
     * section in the ListView the same name as in the
     * model element class (here Entry, see entry.h).
     */
    roles[CategoryRole] = "category";
    roles[UserNameRole] = "userName";
    roles[PasswordRole] = "password";
    roles[NotesRole] = "notes";
    roles[IdRole] = "id";
    roles[UuidRole] = "uuid";
    roles[MtimeRole] = "mtime";
    roles[MtimeIntRole] = "mtimeInt";
    setRoleNames(roles);

    m_deleted.clear();
}

void EntryListModel::add(Entry &entry){
    beginInsertRows(QModelIndex(), m_entries.length(), m_entries.length());
    entry.setId(m_entries.length());
    m_entries << entry;
    endInsertRows();
    emit countChanged(rowCount());
}

void EntryListModel::addEntry(Entry &entry){
    add(entry);
    qDebug("Added entry %s. New list size is: %d", entry.name().toUtf8().data(), m_entries.size());
    /*
     * In some (rare) situations the highlight of the list view was not updated correctly after a
     * new entry had been placed at the beginning of a category. Emitting the dataChanged() signal
     * as follows solves this issue.
     */
    emit dataChanged(index(0), index(0));
    emit changed();
}

void EntryListModel::addEntry(QString name, QString category, QString userName, QString password, QString notes){
    Entry entry(name, category, userName, password, notes, -1);
    addEntry(entry);
}

void EntryListModel::addEntry(QString name, QString category, QString userName, QString password, QString notes, QString uuid){
    Entry entry(name, category, userName, password, notes, -1,
                QUuid::fromRfc4122(QByteArray::fromBase64(uuid.toAscii())));
    addEntry(entry);
}

void EntryListModel::addFromByteArray(QByteArray &data){
    qDebug("Adding entries from QByteArray.");
    QTextStream in(data);

    QString line = in.readLine();
    if(line.length() == 0){
        qDebug("No entries in array.");
        return;
    }

    qDebug("Looking for list of deleted entries.");
    if (line.startsWith("deleted:")) {
        line.remove(0, QString("deleted:").length());

        m_deleted << line.split(CSV_SEP);
        qDebug() << "Got list of deleted entries: " << m_deleted;

        line = in.readLine();
    }

    qDebug("Beginning to insert data into model.");
    bool forceRewrite = false;
    QRegExp xhtmlLineFeed("<br/>|<br />");
    while(line != 0 && line.length() > 0){
//        qDebug() << "Adding: "  << line;
        QStringList list = line.split(CSV_SEP, QString::KeepEmptyParts);
        QString notes = list.at(4);
        if (list.length() == 5) {
            qDebug("Adding entry with default uuid and mtime. Forcing rewrite.");
            Entry entry(list.at(0), list.at(1), list.at(2), list.at(3), notes.replace(xhtmlLineFeed, "\n"), -1);
            add(entry);
            forceRewrite = true;
        } else {
            Entry entry(list.at(0), list.at(1), list.at(2), list.at(3),
                        notes.replace(xhtmlLineFeed, "\n"), -1,
                        QUuid::fromRfc4122(QByteArray::fromBase64(list.at(5).toAscii())),
                        QDateTime::fromString(list.at(6), Qt::ISODate));
            add(entry);
        }

        line = in.readLine();
    }

    if (forceRewrite) {
        emit changed();
    }
}

Entry* EntryListModel::at(int index){
    return new Entry(m_entries.at(index));
}

void EntryListModel::clear(){
    beginResetModel();
    m_entries.clear();
    m_deleted.clear();
    endResetModel();
    emit countChanged(rowCount());
}

bool EntryListModel::containsUuid(QString uuid) {
    for (int i = 0; i < m_entries.size(); i++) {
        Entry e = m_entries[i];
        if (e.uuid() == uuid) {
            return true;
        }
    }
    return false;
}

QVariant EntryListModel::data(const QModelIndex &index, int role) const{
    if (index.row() < 0 || index.row() > m_entries.count())
        return QVariant();

    const Entry &entry = m_entries[index.row()];
    if(role == NameRole)
        return entry.name();
    else if (role == CategoryRole)
        return entry.category();
    else if (role == UserNameRole)
        return entry.userName();
    else if (role == PasswordRole)
        return entry.password();
    else if (role == NotesRole)
        return entry.notes();
    else if (role == IdRole)
        return entry.id();
    else if (role == UuidRole)
        return entry.uuid();
    else if (role == MtimeRole)
        return entry.mtime();
    else if (role == MtimeIntRole)
        return entry.mtimeInt();
    return QVariant();
}

QStringList EntryListModel::deletedUuids() {
    return m_deleted;
}

int EntryListModel::indexOfUuid(QString uuid) {
    for (int i = 0; i < m_entries.size(); i++) {
        Entry e = m_entries[i];
        if (e.uuid() == uuid) {
            return i;
        }
    }
    return -1;
}

void EntryListModel::remove(int index){
    beginRemoveRows(QModelIndex(), index, index);
    Entry *e = at(index);
    m_deleted << e->uuid();
    m_entries.removeAt(index);
    endRemoveRows();
    emit countChanged(rowCount());
}

void EntryListModel::removeAt(int index){
    remove(index);
    emit changed();
}

void EntryListModel::removeById(int id){
    for (int i = 0; i < m_entries.size(); i++) {
        Entry e = m_entries[i];
        if (e.id() == id) {
            removeAt(i);
            return;
        }
    }
}

void EntryListModel::removeByUuid(QString uuid){
    for (int i = 0; i < m_entries.size(); i++) {
        Entry e = m_entries[i];
        if (e.uuid() == uuid) {
            removeAt(i);
            return;
        }
    }
}

int EntryListModel::rowCount(const QModelIndex &/*parent*/) const{
    return m_entries.size();
}

QByteArray EntryListModel::toByteArray(){
    qDebug("Writing data into QByteArray...");
    QByteArray ret;
    QTextStream out(&ret);

    out << "deleted:" << m_deleted.join(CSV_SEP) << CSV_NL;

    for(int i = 0; i < m_entries.size(); i++){
        Entry e = m_entries.at(i);
        out << e.name() << CSV_SEP << e.category() << CSV_SEP << e.userName()
            << CSV_SEP << e.password() << CSV_SEP << e.notes().replace("\n", "<br />")
            << CSV_SEP << e.uuid() << CSV_SEP << e.mtime() << CSV_NL;
    }

    out.flush();
    return ret;
}

void EntryListModel::updateEntryAt(int index, QString name, QString category, QString userName, QString password, QString notes){
    if (index > 0 && index < m_entries.length() - 1) {
        Entry e = m_entries.at(index);

        e.setName(name);
        e.setCategory(category);
        e.setUserName(userName);
        e.setPassword(password);
        e.setNotes(notes);

        m_entries.replace(index, e);
    } else {
        Entry newEntry(name, category, userName, password, notes, -1);
        add(newEntry);
    }
    emit changed();
}

void EntryListModel::appendEntries(const QList<Entry> entries){
    foreach (Entry entry, entries) {
        entry.setId(m_entries.length());
        add(entry);
    }
    emit changed();
}

QStringList EntryListModel::getItemNames() const {
    QStringList items;

    for(int i = 0; i < m_entries.size(); i++){
        QString category = m_entries[i].category();

        if(! items.contains(category)){
            items.append(category);
        }
    }

    return items;
}

void EntryListModel::addOrUpdateEntry(QString name, QString category, QString userName, QString password, QString notes, int id)
{
    for (int i = 0; i < m_entries.length(); i++) {
        Entry entry = m_entries[i];
        if (entry.id() == id) {
            entry.setName(name);
            entry.setCategory(category);
            entry.setUserName(userName);
            entry.setPassword(password);
            entry.setNotes(notes);
            m_entries.replace(i, entry);
            emit dataChanged(index(i), index(i));
            emit changed();
            return;
        }
    }

    // No entry found. Add new entry.
    Entry newEntry(name, category, userName, password, notes, id);
    addEntry(newEntry);
    emit changed();
}
