/*
 *  Copyright 2013 Ruediger Gad
 *
 *  This file is part of EnvVarHelper.
 *
 *  EnvVarHelper is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  EnvVarHelper is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with EnvVarHelper.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "envvarhelper.h"

#include <QDebug>
#include <QFile>

#include <unistd.h>



EnvVarHelper::EnvVarHelper()
{
}

int EnvVarHelper::appendToEnvironmentVariable(QString var, QString value) {
    qDebug() << "Appending" << value << "to" << var;
    int ret;

#ifdef LINUX_DESKTOP
    char *oldValue = getenv(var.toLocal8Bit().constData());
    qDebug() << "Got" << var << ":" << oldValue;
    ret = setEnvironmentVariable(var, QString::fromLocal8Bit(oldValue) + ":" + value);
#endif

    return ret;
}

QString EnvVarHelper::getOwnLibPath(QString ownPath) {
    QString ownLibPath;

#ifdef LINUX_DESKTOP
    if (QFile::exists(ownPath + "/../lib")) {
        ownLibPath = ownPath + "/../lib";
    } else if (QFile::exists(ownPath + "/lib")) {
        ownLibPath = ownPath + "/lib";
    } else if (QFile::exists("lib")) {
        ownLibPath = "lib";
    } else {
        qErrnoWarning("Couldn't find own lib directory.");
    }
#endif

    return ownLibPath;
}

QString EnvVarHelper::getOwnPath() {
    QString ownPathStr;

#ifdef LINUX_DESKTOP
    char ownPath[256];
    int ownPathLength = readlink("/proc/self/exe", ownPath, 256);
    ownPathStr = QString::fromLocal8Bit(ownPath, ownPathLength);
    int lastIndex = ownPathStr.lastIndexOf("/");
    ownPathStr.truncate(lastIndex);
    qDebug() << "Found own path:" << ownPathStr;
#endif

    return ownPathStr;
}

int EnvVarHelper::setEnvironmentVariable(QString var, QString value) {
    qDebug() << "Setting" << var << "to" << value;
    int ret = -127;

#ifdef LINUX_DESKTOP
    ret = setenv(var.toLocal8Bit().constData(), value.toLocal8Bit().constData(), 1);
    qDebug() << "setenv returned:" << ret;
#endif

    return ret;
}

