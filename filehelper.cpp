/*
 *  Copyright 2012 Ruediger Gad
 *
 *  This file is part of Q To-Do.
 *
 *  Q To-Do is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Q To-Do is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Q To-Do.  If not, see <http://www.gnu.org/licenses/>.
 *
 *  ###################
 *
 *  Note: The code of the FileHelper is additionally released under the terms
 *  of the GNU Lesser General Public License (LGPL) as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  Files considered part of the FileHelper are filehelper.h and filehelper.cpp.
 *  This file is additionally licensed under the terms of the LGPL.
 *
 */

#include "filehelper.h"

#include <QDateTime>
#include <QDebug>
#include <QDir>
#include <QFile>

FileHelper::FileHelper(QObject *parent) :
    QObject(parent)
{
}

QString FileHelper::chksum(const QString &fileName, QCryptographicHash::Algorithm algorithm) {
    if (fileName == "") {
        qWarning("No file name given.");
        return "";
    }

    QFile file(fileName);
    file.open(QFile::ReadOnly);
    QCryptographicHash hash(algorithm);

    QByteArray data = file.readAll();
    hash.addData(data.data(), data.length());

    return QString(hash.result().toHex());
}

bool FileHelper::cp(const QString &source, const QString &destination) {
    if (source == "") {
        qDebug("No source given. Please provide a valid source.");
        return false;
    }
    if (destination == "") {
        qDebug("No destination given. Please provide a valid destination.");
        return false;
    }

    return QFile::copy(source, destination);
}

bool FileHelper::exists(const QString &fileName) {
    if (fileName == "") {
        return false;
    }
    return QFile::exists(fileName);
}

QString FileHelper::home(){
    return QDir::homePath();
}

QStringList FileHelper::ls(const QString &dirName) {
    return ls(dirName, "*");
}

QStringList FileHelper::ls(const QString &dirName, const QString &filter) {
    if (dirName == "") {
        qDebug("No directory given.");
        return QStringList();
    }

    QDir dir(dirName);
    return dir.entryList(QStringList() << filter, QDir::Files);
}

QString FileHelper::md5sum(const QString &fileName) {
    return chksum(fileName, QCryptographicHash::Md5);
}

bool FileHelper::mkdir(const QString &dir){
    return QDir().mkpath(dir);
}

QString FileHelper::mtimeString(const QString &fileName) {
    return QFileInfo(fileName).lastModified().toString(Qt::ISODate);
}

bool FileHelper::rm(const QString &file){
    return QFile(file).remove();
}

bool FileHelper::rmdir(const QString &dir){
    return QDir().rmpath(dir);
}

QString FileHelper::sha1sum(const QString &fileName) {
    return chksum(fileName, QCryptographicHash::Sha1);
}
