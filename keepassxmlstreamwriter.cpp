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

#include "keepassxmlstreamwriter.h"

#include <QFileDialog>

KeePassXmlStreamWriter::KeePassXmlStreamWriter(QObject *parent) :
    QObject(parent)
{
}

void KeePassXmlStreamWriter::exportList(const QList<Entry> &list){
    qDebug("Going to export data...");

    QString fileName = QFileDialog::getSaveFileName(0, "Export data to:", QDir::homePath(), "KeePassX XML File (*.xml)");

    if(fileName.isEmpty()){
        qDebug("No File selected.");
        return;
    }

    if(! fileName.endsWith(".xml")) fileName += ".xml";
    QFile file(fileName);

    if(file.open(QFile::ReadWrite)){
        file.resize(0);
        xmlWriter.setDevice(&file);
        xmlWriter.setAutoFormatting(true);
        xmlWriter.setAutoFormattingIndent(1);

        this->list = QList<Entry>(list);
        writeFile();

        file.close();
    }else{
        QString msg = "Failed to open file \"" + fileName + "\" for writing.";
        qErrnoWarning(msg.toUtf8().constData());
        emit error(msg);
    }
}

void KeePassXmlStreamWriter::writeFile(){
    xmlWriter.writeStartDocument();

    writeDatabase();

    xmlWriter.writeEndDocument();
}

void KeePassXmlStreamWriter::writeDatabase(){
    xmlWriter.writeStartElement("database");

    while(! list.isEmpty()){
        writeGroup(list.first().category());
    }

    xmlWriter.writeEndElement();
}

void KeePassXmlStreamWriter::writeGroup(QString groupName){
    xmlWriter.writeStartElement("group");
    xmlWriter.writeTextElement("title", groupName);
    xmlWriter.writeTextElement("icon", "0");

    do{
        writeEntry(list.takeFirst());
    /*
     * Above we takeFirst from the list.
     * Hence, first now refers to the next element in the list.
     */
    }while(! list.isEmpty() && groupName == list.first().category());

    xmlWriter.writeEndElement();
}

void KeePassXmlStreamWriter::writeEntry(const Entry &entry){
    xmlWriter.writeStartElement("entry");

    xmlWriter.writeTextElement("title", entry.name());
    xmlWriter.writeTextElement("username", entry.userName());
    xmlWriter.writeTextElement("password", entry.password());
    xmlWriter.writeEmptyElement("url");

    QString comment = entry.notes();
    QRegExp lineBreak("\n|<br />|<br/>");
    if(comment.contains(lineBreak)){
        xmlWriter.writeStartElement("comment");
        xmlWriter.setAutoFormatting(false);

        QStringList commentParts = comment.split(lineBreak);
        do{
            xmlWriter.writeCharacters(commentParts.takeFirst());
            xmlWriter.writeEmptyElement("br");
        }while(! commentParts.isEmpty());

        xmlWriter.writeEndElement();
        xmlWriter.setAutoFormatting(true);
    }else{
        xmlWriter.writeTextElement("comment", comment);
    }

    xmlWriter.writeTextElement("icon", "0");
    xmlWriter.writeEmptyElement("creation");
    xmlWriter.writeEmptyElement("lastaccess");
    xmlWriter.writeEmptyElement("lastmod");
    xmlWriter.writeTextElement("expire", "Never");

    xmlWriter.writeEndElement();
}

