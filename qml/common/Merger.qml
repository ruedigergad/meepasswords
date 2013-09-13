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

    property string _password

    function setPassword(p) {
        _password = p
    }

    function mergeDir (dirName) {
        console.log("Merging directory: " + dirName)
    }

    function mergeFile (syncFileName) {
        console.log("Merging sync file: " + syncFileName)

        incomingStorageFile.getModel().clear()
        incomingStorageFile.setStoragePath(syncFileName)
        incomingStorageFile.setPassword(_password)
        if (!incomingStorageFile.loadAndDecryptData()) {
            _password = ""
            return false;
        }

        var changed = false
        var incomingModel = incomingStorageFile.getModel()
        var ownModel = mainFlickable.entryStorage.getModel()

        // Remove deleted entries first.
        var deletedUuids = incomingModel.deletedUuids()
        console.log("Removing deleted entries from own model: " + deletedUuids)
        console.log("deletedUuids.length: " + deletedUuids.length)
        if (deletedUuids && deletedUuids.length >  0) {
            for (var i = 0; i < deletedUuids.length; i++) {
                var uuid = deletedUuids[i]
                if (uuid === "") {
                    continue
                }
                if (ownModel.containsUuid(uuid)) {
                    console.log("Deleting: " + uuid)
                    ownModel.removeByUuid(uuid)
                    changed = true
                }
            }
        }
        deletedUuids = ownModel.deletedUuids()
        console.log("Removing deleted entries from incoming model: " + deletedUuids)
        console.log("deletedUuids.length: " + deletedUuids.length)
        if (deletedUuids && deletedUuids.length >  0) {
            for (i = 0; i < deletedUuids.length; i++) {
                uuid = deletedUuids[i]
                if (uuid === "") {
                    continue
                }
                if (incomingModel.containsUuid(uuid)) {
                    console.log("Deleting: " + uuid)
                    incomingModel.removeByUuid(uuid)
                    changed = true
                }
            }
        }

        console.log("Iterating over incoming model.")
        var index = 0
        while (index < incomingModel.count) {
            console.log("Index: " + index)

            var incomingEntry = incomingModel.get(index)
            var ownIndex = ownModel.indexOfUuid(incomingEntry.uuid)

            if (ownIndex > -1) {
                console.log("Found two matching entries. own: " + ownIndex + " incoming: " + index)
                var incomingMtime = incomingEntry.mtime
                var ownMtime = ownModel.get(ownIndex).mtime
                console.log("Own mtime: " + ownMtime + " Incoming mtime: " + incomingMtime)

                if (ownMtime < incomingMtime) {
                    console.log("Own entry is older, updating...")
                    ownModel.updateEntryAt(ownIndex, incomingEntry.name, incomingEntry.category,
                                           incomingEntry.userName, incomingEntry.password,
                                           incomingEntry.notes)
                    changed = true
                } else if (incomingMtime < ownMtime) {
                    console.log("Own entry is newer. Forcing update.")
                    changed = true
                }
            } else {
                console.log("Entry not found, adding new.")
                ownModel.addEntry(incomingEntry.name, incomingEntry.category,
                                  incomingEntry.userName, incomingEntry.password,
                                  incomingEntry.notes, incomingEntry.uuid)
                changed = true
            }
            index++
        }

        console.log("Checking for additions in own model.")
        index = 0
        while (index < ownModel.count) {
            console.log("Index: " + index)

            var ownEntry = ownModel.get(index)
            if (!incomingModel.containsUuid(ownEntry.uuid)) {
                console.log("Found new entry. Forcing upload.")
                changed = true
            }
            index++
        }

        if (changed) {
            mainFlickable.entryStorage.storeModel()
        }

        incomingStorageFile.getModel().clear()
        _password = ""
        return changed
    }

    EntryStorage {
        id: incomingStorageFile
    }
}
