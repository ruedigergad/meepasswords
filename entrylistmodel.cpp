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
    setRoleNames(roles);
}

void EntryListModel::add(Entry &entry){
    beginInsertRows(QModelIndex(), m_entries.length(), m_entries.length());
    entry.setId(m_entries.length());
    m_entries << entry;
    endInsertRows();
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

void EntryListModel::addFromByteArray(QByteArray &data){
    qDebug("Adding entries from QByteArray.");
    QTextStream in(data);

    QString line = in.readLine();
    if(line.length() == 0){
        qDebug("No entries in array.");
        return;
    }

    qDebug("Beginning to insert data into model.");

    QRegExp xhtmlLineFeed("<br/>|<br />");
    while(line != 0 && line.length() > 0){
        QStringList list = line.split(CSV_SEP, QString::KeepEmptyParts);
        QString notes = list.at(4);
        Entry entry(list.at(0), list.at(1), list.at(2), list.at(3), notes.replace(xhtmlLineFeed, "\n"), -1);
        add(entry);
        line = in.readLine();
    }
}

Entry* EntryListModel::at(int index){
    return new Entry(m_entries.at(index));
}

void EntryListModel::clear(){
    beginResetModel();
    m_entries.clear();
    endResetModel();
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
    return QVariant();
}

void EntryListModel::remove(int index){
    beginRemoveRows(QModelIndex(), index, index);
    m_entries.removeAt(index);
    endRemoveRows();
}

void EntryListModel::removeAt(int index){
    remove(index);
    emit changed();
}

void EntryListModel::removeById(int id){
    for (int i = 0; i <= m_entries.size(); i++) {
        Entry e = m_entries[i];
        if (e.id() == id) {
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

    for(int i = 0; i < m_entries.size(); i++){
        Entry e = m_entries.at(i);
        out << e.name() << CSV_SEP << e.category() << CSV_SEP << e.userName() << CSV_SEP << e.password() << CSV_SEP << e.notes().replace("\n", "<br />") << CSV_NL;
    }

    out.flush();
    return ret;
}

void EntryListModel::updateEntryAt(int index, QString name, QString category, QString userName, QString password, QString notes){
    remove(index);
    Entry entry(name, category, userName, password, notes, -1);
    add(entry);
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
    Entry newEntry(name, category, userName, password, notes, id);

    for (int i = 0; i < m_entries.length(); i++) {
        Entry entry = m_entries[i];
        if (entry.id() == newEntry.id()) {
            m_entries.replace(i, newEntry);
            emit dataChanged(index(i), index(i));
            emit changed();
            return;
        }
    }

    // No entry found. Add new entry.
    addEntry(newEntry);
}
