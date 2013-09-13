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

import QtQuick 2.0
import SyncToImap 1.0

SyncToImapBase {

    property int _currentMessageIdIndex

    function deleteMessage(subject) {
        console.log("Deleting message with subject: " + subject)

        if (subject === "") {
            console.log("Error: subject is not set. Stopping sync.")
            return
        }

        _imapMessageSubject = subject

        if (useBuiltInDialogs) {
            _syncToImapProgressDialog.maxValue = 5
        }

        _syncToImap()
    }

    onMessageAdded: {
    }

    onMessageDeleted: {
        if (_messageIds.length === 1 || _messageIds.length === _currentMessageIdIndex + 1) {
            _reportSuccess()
        } else {
            _currentMessageIdIndex++
            _imapMessageId = _messageIds[_currentMessageIdIndex]
            console.log("Message id is: " + _imapMessageId)
            _imapStorage.deleteMessage(_imapMessageId)
        }
    }

    onMessageRetrieved: {
    }

    onMessageUpdated: {
    }

    onMessageIdsQueried:  {
        console.log("Performing file sync.")

        if (_messageIds.length === 0) {
            console.log("No message found. Doing nothing.")
            _reportSuccess()
        } else if (_messageIds.length === 1) {
            console.log("Message found.")
            _imapMessageId = _messageIds[0]
            console.log("Message id is: " + _imapMessageId)
            _imapStorage.deleteMessage(_imapMessageId)
        } else {
            console.log("Multiple messages found.")
            _currentMessageIdIndex = 0
            _imapMessageId = _messageIds[_currentMessageIdIndex]
            console.log("Message id is: " + _imapMessageId)
            _imapStorage.deleteMessage(_imapMessageId)
        }
    }
}
