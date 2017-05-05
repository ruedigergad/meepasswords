/*
 *  Copyright 2013 Ruediger Gad
 *
 *  This file is part of SyncToImap.
 *
 *  SyncToImap is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  SyncToImap is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with SyncToImap.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef ENVVARHELPER_H
#define ENVVARHELPER_H

#include <QProcess>
#include <QString>

class EnvVarHelper
{
public:
    static int appendToEnvironmentVariable(QString var, QString value);
    static QString getOwnLibPath(QString ownPath = getOwnPath());
    static QString getOwnPath();
    static int setEnvironmentVariable(QString var, QString value);

private:
    EnvVarHelper();
};

#endif // ENVVARHELPER_H
