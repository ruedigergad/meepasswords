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

#ifndef FILEHELPER_H
#define FILEHELPER_H

#include <QCryptographicHash>
#include <QObject>
#include <QStringList>

class FileHelper : public QObject
{
    Q_OBJECT
public:
    explicit FileHelper(QObject *parent = 0);

    Q_INVOKABLE QString chksum(const QString &fileName, QCryptographicHash::Algorithm algorithm);
    Q_INVOKABLE bool cp(const QString &source, const QString &destination);
    Q_INVOKABLE bool exists(const QString &fileName);
    Q_INVOKABLE QStringList ls (const QString &dirName);
    Q_INVOKABLE QStringList ls (const QString &dirName, const QString &filter);
    Q_INVOKABLE QString md5sum(const QString &fileName);
    Q_INVOKABLE bool mkdir(const QString &dir);
    Q_INVOKABLE QString mtimeString(const QString &fileName);
    Q_INVOKABLE bool rm(const QString &file);
    Q_INVOKABLE bool rmdir(const QString &dir);
    Q_INVOKABLE QString sha1sum(const QString &fileName);

    Q_INVOKABLE QString home();
    
signals:
    
public slots:
    
};

#endif // FILEHELPER_H
