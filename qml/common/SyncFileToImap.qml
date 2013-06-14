/*
 *  Copyright 2013 Ruediger Gad
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
 */

import QtQuick 1.1
import qtodo 1.0

SyncToImapBase {

    function syncFile(dirName, fileName) {
        console.log("Syncing file " + fileName + " in " + dirName)

        if (dirName === "") {
            console.log("Error: dirName is not set. Stopping sync.")
            return
        }
        if (fileName === "") {
            console.log("Error: fileName is not set. Stopping sync.")
            return
        }

        _baseDir = dirName
        _localFileName = fileName
        _imapMessageSubject = _localFileName
        _imapMessageSubjectPrefix = _imapMessageSubject

        if (useBuiltInDialogs) {
            _syncToImapProgressDialog.maxValue = 6
        }

        _syncToImap()
    }

    function _processMessage() {
        console.log("Processing message...")
        progress()

        var attachmentLocations = _imapStorage.getAttachmentLocations(_imapMessageId)
        console.log("Found the following attachment locations: " + attachmentLocations)

        _imapSyncFile = _imapStorage.writeAttachmentTo(_imapMessageId, attachmentLocations[0], _baseDir)
        console.log("Wrote attachment to: " + _imapSyncFile)

        if (!_filesAreEqual(_baseDir + "/" + _localFileName, _imapSyncFile)) {
            console.log("Files differ, merging.")

            if (merger.mergeFile(_imapSyncFile)) {
                console.log("Merger reported changes, updating attachment...")
                _imapStorage.deleteMessage(_imapMessageId)
            } else {
                console.log("No changes reported by merger. Sync finished successfully.")
                _reportSuccess()
            }
        } else {
            console.log("Files are equal, not merging.")
            _reportSuccess()
        }
    }

    onMessageAdded: _reportSuccess()

    onMessageDeleted: {
        _imapStorage.addMessage(_imapAccountId, imapFolderName, _imapMessageSubject, _baseDir + "/" + _localFileName)
    }

    onMessageRetrieved: {
        _processMessage()
    }

    onMessageUpdated: {
        _reportSuccess()
    }

    onMessageIdsQueried:  {
        console.log("Performing file sync.")

        if (_messageIds.length === 0) {
            console.log("No message found. Performing initital upload.")
            _imapStorage.addMessage(_imapAccountId, imapFolderName, _imapMessageSubject, _baseDir + "/" + _localFileName)
        } else if (_messageIds.length === 1) {
            console.log("Message found.")
            _imapMessageId = _messageIds[0]
            console.log("Message id is: " + _imapMessageId)
            _imapStorage.retrieveMessage(_imapMessageId)
        } else {
            console.log("Error: Multiple messages found.")
        }
    }
}
