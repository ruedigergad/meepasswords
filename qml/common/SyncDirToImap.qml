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

    property variant _acceptedFiles
    property variant _dirSyncFiles
    property int _dirSyncCurrentIndex

    function syncDir(dirName, messageSubjectPrefix) {
        console.log("Going to accept all files.")
        syncDirFiltered(dirName, messageSubjectPrefix, [])
    }

    function syncDirFiltered(dirName, messageSubjectPrefix, acceptedFiles) {
        console.log("Syncing dir " + dirName + ". Using prefix " + messageSubjectPrefix + ".")
        if (acceptedFiles.length === 0) {
            console.log("Accepting all files.")
        } else {
            console.log("Accepting files: " + acceptedFiles)
        }

        if (dirName === "") {
            console.log("Error: dirName is not set. Stopping sync.")
            return
        }
        if (messageSubjectPrefix === "") {
            console.log("Error: messageSubjectPrefix is not set. Stopping sync.")
            return
        }

        _acceptedFiles = acceptedFiles
        _baseDir = dirName
        _imapMessageSubject = ""
        _imapMessageSubjectPrefix = messageSubjectPrefix
        _localFileName = ""

        _syncToImap()
    }

    function _addFiles() {
        for (var i = _dirSyncCurrentIndex; i < _dirSyncFiles.length; i++) {
            var file = _dirSyncFiles[i]

            if (_testSkip(file)) {
                console.log("File " + file + " is not accepted anymore.")
                continue
            }

            console.log("Uploading: " + _baseDir + "/" + file)
            console.log("Subject: " + _imapMessageSubjectPrefix + file)
            _dirSyncCurrentIndex = i + 1
            _imapStorage.addMessage(_imapAccountId, imapFolderName, _imapMessageSubjectPrefix + file, _baseDir + "/" + file)
        }

        console.log("Processed all messages.")
        _reportSuccess()
    }

    function _retrieveMessages() {
        if (_dirSyncCurrentIndex < _messageIds.length) {
            var msgId = _messageIds[_dirSyncCurrentIndex]
            console.log("Retrieving: " + msgId)
            _dirSyncCurrentIndex++
            _imapStorage.retrieveMessage(msgId)
        } else {
            console.log("Retrieved all messages.")
            _dirSyncCurrentIndex = 0
            _processMessages()
        }
    }

    function _processMessages() {
        console.log("Processing messages: " + _messageIds)

        /*
         * This function may also be called asynchronously.
         * Thus, we start at _dirSyncCurrentIndex to avoid
         * starting all over when being called asynchronously.
         * Note: before calling this for the first time,
         *       _dirSyncCurrentIndex must be set to 0.
         */
        for (var i = _dirSyncCurrentIndex; i < _messageIds.length; i++) {
            var msgId = _messageIds[i]
            var attachmentLocation = _getFirstAttachmenLocation(msgId)

            if (attachmentLocation === "") {
                console.log("Invalid attachment location.")
                continue
            }

            var attachmentIdentifier = _imapStorage.getAttachmentIdentifier(msgId, attachmentLocation)
            console.log("Processing attachment: " + attachmentIdentifier)

            if (_testSkip(attachmentIdentifier)) {
                console.log("Message with attachment " + attachmentIdentifier + " is not accepted anymore.")
                console.log("Deleting message.")
                _dirSyncCurrentIndex = i + 1;
                _imapStorage.deleteMessage(msgId)
                return
            }

            if (fileHelper.exists(_baseDir + "/" + attachmentIdentifier)) {
                var ownFile = _baseDir + "/" + attachmentIdentifier

                console.log("File " + ownFile + " exits.")

                var incomingFile = _imapStorage.writeAttachmentTo(msgId, attachmentLocation, _baseDir)

                if (! _filesAreEqual(ownFile, incomingFile)) {
                    console.log("Files differ, using newest version...")

                    var ownMtime = _fileHelper.mtimeString(ownFile)
                    var incomingDate = _imapStorage.getDateString(msgId)
                    console.log("Own mtime: " + ownMtime + " Incoming date: " + incomingDate)

                    if (ownMtime < incomingDate) {
                        console.log("Incoming file is newer. Updating...")
                        _fileHelper.rm(ownFile)
                        _fileHelper.cp(incomingFile, ownFile)
                    }

                    _fileHelper.rm(incomingFile)
                    _dirSyncCurrentIndex = i + 1;
                    _imapStorage.updateMessageAttachment(msgId, ownFile)
                    return
                } else {
                    console.log("Files are equal, removing temp file.")
                    fileHelper.rm(incomingFile)
                }
            } else {
                console.log("File " + _baseDir + "/" + attachmentIdentifier + " not found. Extracting attachment in-place...")
                _imapStorage.writeAttachmentTo(msgId, attachmentLocation, _baseDir)
            }
        }

        _reportSuccess()
    }

    function _testSkip(name) {
        if (_acceptedFiles.length !== 0) {
            var skip = true

            for (var j = 0; j < _acceptedFiles.length; j++) {
                if (_acceptedFiles[j] === name) {
                    skip = false
                    break
                }
            }

            return skip
        }

        return false
    }

    onMessageAdded: _addFiles()
    onMessageDeleted: {
        console.log("Message deleted. Going on with processing.")
        _processMessages()
    }
    onMessageIdsQueried: {
        console.log("Performing dir sync.")

        if (_messageIds.length === 0) {
            console.log("No message(s) found. Performing initital upload.")

            _dirSyncFiles = _fileHelper.ls(_baseDir)
            console.log("Uploading: " + _dirSyncFiles)
            _dirSyncCurrentIndex = 0

            if (useBuiltInDialogs) {
                _syncToImapProgressDialog.maxValue = _dirSyncFiles.length
                _syncToImapProgressDialog.currentValue = 0
            }

            _addFiles()
        } else {
            console.log("Message(s) found: Retrieving " + _messageIds)
            _dirSyncCurrentIndex = 0
            _retrieveMessages()
        }
    }
    onMessageRetrieved: _retrieveMessages()
    onMessageUpdated: {
        console.log("Message updated. Going on with processing.")
        _processMessages()
    }
}
