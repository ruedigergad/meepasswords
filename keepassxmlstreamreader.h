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

#ifndef KEEPASSXMLSTREAMREADER_H
#define KEEPASSXMLSTREAMREADER_H

#include <QObject>
#include <QList>
#include <QStringList>
#include <QXmlStreamReader>

#include "entry.h"

class KeePassXmlStreamReader : public QObject
{
    Q_OBJECT
public:
    explicit KeePassXmlStreamReader(QObject *parent = 0);
    QList<Entry> openFileForImport();

signals:
    void error(QString message);

private:
    QList<Entry> entries;
    QXmlStreamReader xmlReader;

    QString groupTitle;
    QString entryTitle;
    QString userName;
    QString password;
    QString url;
    QString comment;

    QStringList groupTitleStack;

    void addEntry();
    void parseFile();

    /*
     * Begin: Parse pwman3 XML Files.
     */
    void parsePwmanList();
    void parseNode();
    /*
     * Begin: Parse pwman3 XML Files.
     */

    /*
     * Begin: Parse KeePassX XML Files.
     */
    void parseDatabase();
    void parseGroup();
    void parseEntry();
    /*
     * End: Parse KeePassX XML Files.
     */


    void resetMembers();
    void resetEntry();

};

#endif // KEEPASSXMLSTREAMREADER_H
