/*
 *  Copyright 2013 Ruediger Gad
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

import QtQuick 1.1
import meepasswords 1.0
import SyncToImap 1.0

Item {
    function mergeDir (dirName) {
        console.log("Merging directory: " + dirName)
    }

    function mergeFile (syncFileName) {
        console.log("Merging sync file: " + syncFileName)

//        if (rootElementModel.rowCount() === 0) {
//            console.log("Initial sync, reloading storage...")
//            fileHelper.rm(fileHelper.home() + "/to-do-o/default.xml")
//            console.log("Copying " + syncFileName + " to " + fileHelper.home() + "/to-do-o/default.xml")
//            fileHelper.cp(syncFileName, fileHelper.home() + "/to-do-o/default.xml")
//            fileHelper.rm(syncFileName)
//            storage.open()
//            return false
//        } else {
//            mergeTodoStorage(syncFileName)
//            fileHelper.rm(syncFileName)
//            storage.open()
//            return true
//        }
    }
}
