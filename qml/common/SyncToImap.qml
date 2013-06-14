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

Item {
    id: syncToImapItem

    property string imapFolderName: ""
    property QtObject merger
    property bool useBuiltInDialogs: true

    property string _baseDir: ""
    property variant _dirSyncFiles
    property int _dirSyncIndex
    property int _imapAccountId: -1
    property int _imapMessageId: -1
    property string _imapMessageSubject: ""
    property string _imapMessageSubjectPrefix: ""
    property string _imapSyncFile: ""
    property string _localFileName
    property variant _messageIds
    property bool _syncDir

    signal succeeded
    signal progress

    function syncDir(dirName, messageSubjectPrefix) {
        console.log("Syncing dir " + dirName + ". Using prefix " + messageSubjectPrefix + ".")

        if (dirName === "") {
            console.log("Error: dirName is not set. Stopping sync.")
            return
        }
        if (messageSubjectPrefix === "") {
            console.log("Error: messageSubjectPrefix is not set. Stopping sync.")
            return
        }

        _baseDir = dirName
        _imapMessageSubject = ""
        _imapMessageSubjectPrefix = messageSubjectPrefix
        _localFileName = ""
        _syncDir = true

        _syncToImap()
    }

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
        _syncDir = false

        if (useBuiltInDialogs) {
            _syncToImapProgressDialog.maxValue = 6
        }

        _syncToImap()
    }

    function _syncToImap() {
        if (imapFolderName === "") {
            console.log("Error: imapFolderName not set. Stopping sync.")
            return
        }

        //TODO: Add check if merger was set.

        if (useBuiltInDialogs) {
            _syncToImapProgressDialog.currentValue = 0
            _syncToImapProgressDialog.open()
        }

        _imapAccountId = -1
        _imapMessageId = -1
        _imapSyncFile = ""

        var accIds = _imapStorage.queryImapAccounts()
        console.log("Found " + accIds.length + " IMAP account(s).")

        progress()

        if (accIds.length === 1) {
            console.log("Found a single IMAP account. Using this for syncing.")
            console.log("IMAP account id is: " + accIds[0])
            _imapAccountId = accIds[0]
            _imapStorage.retrieveFolderList(_imapAccountId)
        } else if (accIds.length === 0) {
            _syncToImapProgressDialog.close()
            _messageDialog.title = "No IMAP Account"
            _messageDialog.message = "Please set up an IMAP e-mail account for syncing."
            _messageDialog.open()
        } else if (accIds.length > 1) {
            _syncToImapProgressDialog.close()
            _messageDialog.title = "Multiple IMAP Accounts"
            _messageDialog.message = "Functionality for choosing from different IMAP accounts still needs to be implemented."
            _messageDialog.open()
        } else {
            _syncToImapProgressDialog.close()
            _messageDialog.title = "Unexpected Error"
            _messageDialog.message = "Querying for IMAP accounts returned an unexpected value."
            _messageDialog.open()
        }
    }

    function _prepareImapFolder() {
        progress()

        if (! _imapStorage.folderExists(_imapAccountId, imapFolderName)) {
            console.log("Creating folder...")
            _imapStorage.createFolder(_imapAccountId, imapFolderName)
        } else {
            _processImapFolder()
        }
    }

    function _processImapFolder() {
        console.log("Processing content of IMAP folder...")
        progress()

        if (! _imapStorage.folderExists(_imapAccountId, imapFolderName)) {
            console.log("Error: IMAP folder does not exist!")
            return
        }

        _imapStorage.retrieveMessageList(_imapAccountId, imapFolderName)
    }

    function _findAndRetrieveMessages() {
        console.log("Processing messages...")
        progress()

        _messageIds = _imapStorage.queryMessages(_imapAccountId, imapFolderName, _imapMessageSubjectPrefix)

        if (_syncDir) {
            _performDirSync()
        } else {
            _performFileSync()
        }
    }

    function _performDirSync(messageIds) {
        console.log("Performing dir sync.")

        if (_messageIds.length === 0) {
            console.log("No message(s) found. Performing initital upload.")

            _dirSyncFiles = _fileHelper.ls(_baseDir)
            console.log("Uploading: " + _dirSyncFiles)
            _dirSyncIndex = 0

            if (useBuiltInDialogs) {
                _syncToImapProgressDialog.maxValue = _dirSyncFiles.length
                _syncToImapProgressDialog.currentValue = 0
            }

            _dirSyncPerformFileSync()
        } else {
            console.log("Message(s) found: Retrieving " + _messageIds)
            _dirSyncIndex = 0
            _dirSyncRetrieveMessage()
        }
    }

    function _dirSyncPerformFileSync() {
        if (_dirSyncIndex < _dirSyncFiles.length) {
            var file = _dirSyncFiles[_dirSyncIndex]
            console.log("Uploading: " + _baseDir + "/" + file)
            console.log("Subject: " + _imapMessageSubjectPrefix + file)
            _dirSyncIndex++
            _imapStorage.addMessage(_imapAccountId, imapFolderName, _imapMessageSubjectPrefix + file, _baseDir + "/" + file)
        } else {
            console.log("Processed all messages.")
            _reportSuccess()
        }
    }

    function _dirSyncRetrieveMessage() {
        if (_dirSyncIndex < _messageIds.length) {
            var msgId = _messageIds[_dirSyncIndex]
            console.log("Retrieving: " + msgId)
            _dirSyncIndex++
            _imapStorage.retrieveMessage(msgId)
        } else {
            console.log("Retrieved all messages.")
        }
    }

    function _performFileSync(messageIds) {
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

    function _processMessage() {
        console.log("Processing message...")
        progress()

        var attachmentLocations = _imapStorage.getAttachmentLocations(_imapMessageId)
        console.log("Found the following attachment locations: " + attachmentLocations)

        _imapSyncFile = _imapStorage.writeAttachmentTo(_imapMessageId, attachmentLocations[0], _baseDir)
        console.log("Wrote attachment to: " + _imapSyncFile)

        if (!_filesAreEqual(_baseDir + "/" + _localFileName, _imapSyncFile)) {
            console.log("Files differ, merging.")

            if (merger.merge(_imapSyncFile)) {
                console.log("Merger reported changes, updating attachment...")
                _imapStorage.updateMessageAttachment(_imapMessageId, _baseDir + "/" + _localFileName)
            } else {
                _reportSuccess()
            }
        } else {
            console.log("Files are equal, not merging.")
            _reportSuccess()
        }
    }

    function _filesAreEqual(fileNameA, fileNameB) {
        if (fileNameA === "" || fileNameB === "") {
            return false;
        }

        var md5A = _fileHelper.md5sum(fileNameA)
        var sha1A = _fileHelper.sha1sum(fileNameA)

        var md5B = _fileHelper.md5sum(fileNameB)
        var sha1B = _fileHelper.sha1sum(fileNameB)

        console.log("md5sum " + fileNameA + " " + md5A)
        console.log("md5sum " + fileNameB + " " + md5B)
        console.log("sha1sum " + fileNameA + " " + sha1A)
        console.log("sha1sum " + fileNameB + " " + sha1B)
        return md5A === md5B && sha1A === sha1B
    }

    function _reportSuccess() {
        succeeded()

        if (useBuiltInDialogs) {
            _syncToImapProgressDialog.close()
            _messageDialog.title = "Success"
            _messageDialog.message = "Sync was successful."
            _messageDialog.open()
        }
    }

    onProgress: {
        if (useBuiltInDialogs) {
            _syncToImapProgressDialog.currentValue++
        }
    }

    ImapStorage {
        id: _imapStorage

        onFolderCreated: _processImapFolder()
        onFolderListRetrieved: _prepareImapFolder()
        onMessageAdded: {
            if (_syncDir) {
                console.log("Message uploaded. Proceeding...")
                progress()
                _dirSyncPerformFileSync()
            } else {
                _reportSuccess()
            }
        }
        onMessageListRetrieved: _findAndRetrieveMessages()
        onMessageRetrieved: {
            if (_syncDir) {
                console.log("Message retrieved. Proceeding...")
                progress()
                _dirSyncRetrieveMessage()
            } else {
                _processMessage()
            }
        }
        onMessageUpdated: {
                _reportSuccess()
        }

        onError: {
            _syncToImapProgressDialog.close()
            _messageDialog.title = "Error"
            _messageDialog.message = "Sync failed: \"" + errorString + "\" Code: " + errorCode + " Action: " + currentAction
            _messageDialog.open()
        }
    }

    FileHelper { id: _fileHelper }

    ProgressDialog {
        id: _syncToImapProgressDialog
        parent: syncToImapItem.parent

        title: "Syncing..."
        message: "Sync to IMAP in progess"

        maxValue: 6
        currentValue: 0
    }

    MessageDialog {
        id: _messageDialog
        parent: syncToImapItem.parent
    }
}
