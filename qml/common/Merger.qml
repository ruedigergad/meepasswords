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

        incomingStorageFile.setStoragePath(syncFileName)
        incomingStorageFile.setPassword(mainFlickable.entryStorage.getPassword())
        if (!incomingStorageFile.loadAndDecryptData()) {
            return false;
        }

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
                console.log("Found two matching entries.")
                var incomingMtime = incomingEntry.mtimeInt
                var ownMtime = ownModel.get(ownIndex).mtimeInt

                if (ownMtime < incomingMtime) {
                    console.log("Own entry is older, updating...")
                    ownModel.updateEntryAt(ownIndex, incomingEntry.name, incomingEntry.category,
                                           incomingEntry.userName, incomingEntry.password,
                                           incomingEntry.notes)
                }
            } else {
                console.log("Entry not found, adding new.")
                ownModel.addEntry(incomingEntry.name, incomingEntry.category,
                                  incomingEntry.userName, incomingEntry.password,
                                  incomingEntry.notes, incomingEntry.uuid)
            }
            index++
        }
    }

    EntryStorage {
        id: incomingStorageFile
    }
}
