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

#include "keepassxmlstreamreader.h"

#include <QFileDialog>

KeePassXmlStreamReader::KeePassXmlStreamReader(QObject *parent) :
    QObject(parent)
{
}

void KeePassXmlStreamReader::addEntry(){
    qDebug("Entry: %s, %s, %s", entryTitle.toUtf8().constData(), userName.toUtf8().constData(), comment.toUtf8().constData());
    entries << Entry(entryTitle, groupTitle, userName, password, QString(url + "\n" + comment), -1);
    resetEntry();
}

QList<Entry> KeePassXmlStreamReader::openFileForImport(){
    qDebug("Entering openFileForImport...");
    entries.clear();
    groupTitleStack.clear();
    qDebug("Opening file for import.");
    QString fileName = QFileDialog::getOpenFileName(0, "Import KeePassX Database", QDir::homePath(), "KeePassX XML File (*.xml)");

    if(fileName.isEmpty()){
        qDebug("No file selected.");
        return entries;
    }

    QFile file(fileName);
    if (file.open(QFile::ReadOnly)){
        xmlReader.setDevice(&file);
        parseFile();
        file.close();
    }else{
        QString msg = "Failed to open file \"" + fileName + "\" for reading.";
        qErrnoWarning(msg.toUtf8().constData());
        emit error(msg);
    }
    return entries;
}

void KeePassXmlStreamReader::parseFile(){
    while(xmlReader.readNextStartElement()){
        if(xmlReader.name() == "database"){
            qDebug("Found database tag. Assuming KeePassX file format. Continuing with KeePassX specific parsing...");
            parseDatabase();
        }else if(xmlReader.name() == "PwmanXmlList"){
            qDebug("Found PwmanXmlList tag. Assuming pwman3 file format. Continuing with pwman3 specific parsing...");
            parsePwmanList();
        }
        else{
            qErrnoWarning("No Database found!");
        }
    }
    qDebug("Leaving parseFile...");
}

/*
 * Begin: Parse pwman3 XML Files.
 */
void KeePassXmlStreamReader::parsePwmanList(){
    groupTitle = "pwman3";

    while(xmlReader.readNextStartElement()){
        if(xmlReader.name() == "Node"){
            qDebug("Found Node in pwman3 XML list.");
            parseNode();
        }else{
            qDebug("Skipping pwman3 XML list child element: %s", xmlReader.name().toString().toUtf8().constData());
            xmlReader.skipCurrentElement();
        }
    }
    qDebug("Leaving parsePwmanList...");
}
void KeePassXmlStreamReader::parseNode(){
    while(xmlReader.readNextStartElement()){
        if(xmlReader.name() == "username"){
            userName = xmlReader.readElementText();
        }else if(xmlReader.name() == "password"){
            password = xmlReader.readElementText();
        }else if(xmlReader.name() == "url"){
            url = xmlReader.readElementText();
        }else if(xmlReader.name() == "notes"){
            do{
                if(xmlReader.isCharacters()){
                    comment += xmlReader.text().toString();
                }else if(xmlReader.isStartElement() && xmlReader.name() == "br"){
                    comment += "\n";
                }
                xmlReader.readNext();
            }while (xmlReader.name() != "notes");
        }else{
            qDebug("Skipping Node child element: %s", xmlReader.name().toString().toUtf8().constData());
            xmlReader.skipCurrentElement();
        }
    }
    entryTitle = userName + " " + url;
    addEntry();
    qDebug("Leaving parseNode...");
}
/*
 * End: Parse pwman3 XML Files.
 */

/*
 * Begin: Parse KeePassX XML Files.
 */
void KeePassXmlStreamReader::parseDatabase(){
    resetMembers();
    while(xmlReader.readNextStartElement()){
        if(xmlReader.name() == "group"){
            qDebug("Found group in database.");
            parseGroup();
        }else{
            qDebug("Skipping database child element: %s", xmlReader.name().toString().toUtf8().constData());
            xmlReader.skipCurrentElement();
        }
    }
    qDebug("Leaving parseDatabase...");
}
void KeePassXmlStreamReader::parseGroup(){
    while(xmlReader.readNextStartElement()){
        if(xmlReader.name() == "title"){
            if(! groupTitle.isEmpty()) groupTitleStack.append(groupTitle);
            groupTitle = xmlReader.readElementText();
        }else if(xmlReader.name() == "entry"){
            qDebug("Found entry in group.");
            parseEntry();
        }else if(xmlReader.name() == "group"){
            qDebug("Found group in group.");
            parseGroup();
        }else{
            qDebug("Skipping group child element: %s", xmlReader.name().toString().toUtf8().constData());
            xmlReader.skipCurrentElement();
        }
    }
    resetMembers();
    qDebug("Leaving parseGroup...");
}
void KeePassXmlStreamReader::parseEntry(){
    while(xmlReader.readNextStartElement()){
        QStringRef name = xmlReader.name();
        if(name == "title") {
            entryTitle = xmlReader.readElementText();
        }else if(name == "username") {
            userName = xmlReader.readElementText();
        }else if(name == "password"){
            password = xmlReader.readElementText();
        }else if(name == "url"){
            url = xmlReader.readElementText(QXmlStreamReader::IncludeChildElements);
        }else if(name == "comment"){
            do{
                if(xmlReader.isCharacters()){
                    comment += xmlReader.text().toString();
                }else if(xmlReader.isStartElement() && xmlReader.name() == "br"){
                    comment += "\n";
                }
                xmlReader.readNext();
            }while (xmlReader.name() != "comment");
        }else{
            qDebug("Skipping entry child element: %s", name.toString().toUtf8().constData());
            xmlReader.skipCurrentElement();
        }
    }
    addEntry();
    qDebug("Leaving parseEntry...");
}
/*
 * End: Parse KeePassX XML Files.
 */

void KeePassXmlStreamReader::resetMembers(){
    groupTitle = (groupTitleStack.isEmpty()) ? "" : groupTitleStack.takeLast();
    resetEntry();
}

void KeePassXmlStreamReader::resetEntry(){
    entryTitle = "";
    userName = "";
    password = "";
    url = "";
    comment = "";
}
