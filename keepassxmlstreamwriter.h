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

#ifndef KEEPASSXMLSTREAMWRITER_H
#define KEEPASSXMLSTREAMWRITER_H

#include <QList>
#include <QObject>
#include <QXmlStreamWriter>

#include "entrylistmodel.h"

class KeePassXmlStreamWriter : public QObject
{
    Q_OBJECT
public:
    explicit KeePassXmlStreamWriter(QObject *parent = 0);

    void exportList(const QList<Entry> &list);

signals:
    void error(QString msg);

public slots:

private:
    void writeFile();
    void writeDatabase();
    void writeGroup(QString groupName);
    void writeEntry(const Entry &entry);

    QList<Entry> list;
    QString currentGroup;

    QXmlStreamWriter xmlWriter;

};

#endif // KEEPASSXMLSTREAMWRITER_H
