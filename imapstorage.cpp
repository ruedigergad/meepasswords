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

#include "imapstorage.h"
#include <QDebug>
#include <QDir>
#include <qmfclient/qmaildisconnected.h>
#include <qmfclient/qmailstore.h>
#include <qmfclient/qmailfolderkey.h>

ImapStorage::ImapStorage(QObject *parent) :
    QObject(parent)
{
    storageAction = new QMailStorageAction();
    retrievalAction = new QMailRetrievalAction();
    searchAction = new QMailSearchAction();

    connect(storageAction, SIGNAL(activityChanged(QMailServiceAction::Activity)),
            this, SLOT(storageActivityChanged(QMailServiceAction::Activity)));
    connect(QMailStore::instance(), SIGNAL(foldersAdded(QMailFolderIdList)),
            this, SLOT(foldersAdded(QMailFolderIdList)));
    connect(QMailStore::instance(), SIGNAL(foldersUpdated(QMailFolderIdList)),
            this, SLOT(foldersAdded(QMailFolderIdList)));
    connect(QMailStore::instance(), SIGNAL(accountContentsModified(QMailAccountIdList)),
            this, SLOT(accountContentsModified(QMailAccountIdList)));

    connect(retrievalAction, SIGNAL(activityChanged(QMailServiceAction::Activity)),
            this, SLOT(retrieveActivityChanged(QMailServiceAction::Activity)));
    connect(searchAction, SIGNAL(activityChanged(QMailServiceAction::Activity)),
            this, SLOT(searchMessageActivityChanged(QMailServiceAction::Activity)));

    currentAction = NoAction;
}

/*
 * FIXME: For now we are checking if the account got modified in order to determine
 * if our folder got created. For some reason activityChanged(QMailServiceAction::Activity)
 * always reports a failure, even though the folder was created successfully. Also the
 * foldersAdded and foldersUpdated signals of QMailStore are not triggered when we add
 * our storage folder. Could it be that this is due to the fact that we are creating a
 * folder at the root level?
 */
void ImapStorage::accountContentsModified(const QMailAccountIdList &ids) {
    Q_UNUSED(ids);
    qDebug() << "accountContentsModified";

    switch (currentAction) {
        case CreateFolderAction:
            currentAction = NoAction;
            emit folderCreated();
            break;
        case AddMessageAction:
        case NoAction:
        default:
            break;
    }
}

void ImapStorage::addMessage(qulonglong accId, QString folder, QString subject, QString attachment) {
    QMailFolderIdList folderIds = queryFolders(accId, folder);
    if (folderIds.count() != 1) {
        qDebug("Error retrieving folder for new message!");
        return;
    }
    QMailFolderId folderId = folderIds.at(0);

    QMailMessage msg;
    msg.setParentAccountId(QMailAccountId(accId));
    msg.setParentFolderId(folderId);
    msg.setSubject(subject);
    msg.setMessageType(QMailMessageMetaDataFwd::Email);
    msg.setDate(QMailTimeStamp(QDateTime::currentDateTime()));
    msg.setStatus(QMailMessage::LocalOnly, true);
    if (attachment != "") {
        msg.setAttachments(QStringList() << attachment);
    }

    QMailStore::instance()->addMessage(&msg);

    QMailDisconnected::moveToFolder(QMailMessageIdList() << msg.id(), folderId);
    currentAction = AddMessageAction;
    retrievalAction->exportUpdates(QMailAccountId(accId));
}

void ImapStorage::createFolder(qulonglong accId, QString name) {
    currentAction = CreateFolderAction;
#if defined(MER_EDITION_SAILFISH) || defined(MER_EDITION_NEMO) || defined(QT5_BUILD)
    storageAction->onlineCreateFolder(name, QMailAccountId(accId), QMailFolderId());
#else
    storageAction->createFolder(name, QMailAccountId(accId), QMailFolderId());
#endif
}

void ImapStorage::deleteMessage(qulonglong msgId) {
    qDebug() << "Deleting message with id: " << msgId;
    currentAction = DeleteMessageAction;
#if defined(MER_EDITION_SAILFISH) || defined(MER_EDITION_NEMO) || defined(QT5_BUILD)
    storageAction->onlineDeleteMessages(QMailMessageIdList() << QMailMessageId(msgId));
#else
    storageAction->deleteMessages(QMailMessageIdList() << QMailMessageId(msgId));
#endif
}

/*
 * Used for debugging. For some reason the activityChanged signal of createFolderAction
 * is not emitted upon success even though the folder is actually created successfully.
 */
void ImapStorage::foldersAdded(QMailFolderIdList ids) {
    qDebug() << "Folders added: " << ids << " number of new folders: " << ids.count();
}

bool ImapStorage::folderExists(qulonglong accId, QString path) {
    return (queryFolders(accId, path).count() == 1);
}

QString ImapStorage::getAttachmentIdentifier(qulonglong msgId, QString attachmentLocation) {
    QMailMessage *msg = new QMailMessage(QMailMessageId(msgId));
    QMailMessagePart attachment = msg->partAt(QMailMessagePart::Location(attachmentLocation));
    return attachment.identifier();
}

QStringList ImapStorage::getAttachmentLocations(qulonglong msgId) {
    QMailMessage *msg = new QMailMessage(QMailMessageId(msgId));
    QList<QMailMessagePartContainer::Location> locations = msg->findAttachmentLocations();

    QStringList ret;
    for (int i = 0; i < locations.count(); i++) {
        ret << locations.at(i).toString(true);
    }

    return ret;
}

QString ImapStorage::getDateString(qulonglong msgId) {
    QMailMessage *msg = new QMailMessage(QMailMessageId(msgId));
    return msg->date().toLocalTime().toString(Qt::ISODate);
}

QString ImapStorage::getSubject(qulonglong msgId) {
    QMailMessage *msg = new QMailMessage(QMailMessageId(msgId));
    return msg->subject();
}

void ImapStorage::moveMessageToTrash(qulonglong msgId) {
    QMailDisconnected::moveToStandardFolder(QMailMessageIdList() << QMailMessageId(msgId), QMailFolder::TrashFolder);
    currentAction = MoveToTrashAction;
    retrievalAction->exportUpdates(QMailMessage(QMailMessageId(msgId)).parentAccountId());
}

QMailFolderIdList ImapStorage::queryFolders(qulonglong accId, QString path) {
    QMailFolderKey accountKey(QMailFolderKey::parentAccountId(QMailAccountId(accId)));
    QMailFolderKey pathKey(QMailFolderKey::path(path));

    QMailFolderIdList folderIds = QMailStore::instance()->queryFolders(accountKey & pathKey);
    return folderIds;
}

QVariantList ImapStorage::queryImapAccounts() {
    QMailAccountIdList accountIds = QMailStore::instance()->queryAccounts();
    QVariantList ret;

    for (int i = 0; i < accountIds.count(); i++) {
        QMailAccount account(accountIds.at(i));

        if(account.messageSources().contains("imap4", Qt::CaseInsensitive)) {
            qDebug() << "Found IMAP account with id: " << account.id() << " and name: " << account.name();
            ret.append(account.id().toULongLong());
        } else {
            qDebug() << "Account with id: " << account.id() << " and name: " << account.name() << " does not support IMAP.";
            accountIds.removeAt(i);
            i--;
        }
    }

    return ret;
}

QVariantList ImapStorage::queryMessages(qulonglong accId, QString folder, QString subject) {
    QMailFolderIdList folders = queryFolders(accId, folder);
    if (folders.count() != 1) {
        qDebug("Error retrieving folder for query!");
        return QVariantList();
    }

    QMailMessageKey accountKey(QMailMessageKey::parentAccountId(QMailAccountId(accId)));
    QMailMessageKey folderKey(QMailMessageKey::parentFolderId(folders.at(0)));
    QMailMessageKey subjectKey(QMailMessageKey::subject(subject, QMailDataComparator::Includes));

    QMailMessageIdList messageIds = QMailStore::instance()->queryMessages(accountKey & folderKey & subjectKey);

    QVariantList ret;
    for (int i = 0; i < messageIds.count(); i++) {
        ret.append(messageIds.at(i).toULongLong());
    }
    return ret;
}

bool ImapStorage::removeMessage(qulonglong msgId) {
    return QMailStore::instance()->removeMessage(QMailMessageId(msgId));
}

void ImapStorage::retrieveActivityChanged(QMailServiceAction::Activity activity) {
    qDebug() << "retrieveActivityChanged: " << activity;

    switch (activity) {
    case QMailServiceAction::Successful:
        switch (currentAction) {
        case AddMessageAction:
            qDebug("Message added.");
            emit messageAdded();
            break;
        case RetrieveFolderListAction:
            currentAction = NoAction;
            emit folderListRetrieved();
            break;
        case RetrieveMessageAction:
            currentAction = NoAction;
            emit messageRetrieved();
            break;
        case RetrieveMessageListAction:
            currentAction = NoAction;
            emit messageListRetrieved();
            break;
        case UpdateMessageAction:
            qDebug("Message updated.");
            currentAction = NoAction;
            emit messageUpdated();
            break;
        case MoveToTrashAction:
            qDebug() << "Message was successfully moved to trash.";
            currentAction = NoAction;
            break;
        default:
            break;
        }
        break;
    case QMailServiceAction::Failed:
        qDebug("Retrieval action failed.");
        emit error(retrievalAction->status().text, retrievalAction->status().errorCode, currentAction);
        currentAction = NoAction;
        break;
    default:
        break;
    }
}

void ImapStorage::retrieveFolderList(qulonglong accId) {
    qDebug() << "Retrieving folder list for account id: " << accId;
    currentAction = RetrieveFolderListAction;
    retrievalAction->retrieveFolderList(QMailAccountId(accId), QMailFolderId());
}

void ImapStorage::retrieveMessage(qulonglong msgId) {
    qDebug() << "Retrieving message with id: " << msgId;
    currentAction = RetrieveMessageAction;
    retrievalAction->retrieveMessages(QMailMessageIdList() << QMailMessageId(msgId), QMailRetrievalAction::Content);
}

void ImapStorage::retrieveMessageList(qulonglong accId, QString folder) {
    qDebug() << "Retrieving message list for account id: " << accId << " from folder: " << folder;

    QMailFolderIdList folders = queryFolders(accId, folder);
    if (folders.count() != 1) {
        qDebug("Error retrieving folder for search!");
        return;
    }

    currentAction = RetrieveMessageListAction;
    retrievalAction->retrieveMessageList(QMailAccountId(accId), folders.at(0));
}

void ImapStorage::searchMessage(qulonglong accId, QString folder, QString subject) {
    QMailMessageKey accountKey(QMailMessageKey::parentAccountId(QMailAccountId(accId)));

    QMailFolderIdList folders = queryFolders(accId, folder);
    if (folders.count() != 1) {
        qDebug("Error retrieving folder for search!");
        return;
    }

    QMailMessageKey folderKey(QMailMessageKey::parentFolderId(folders.at(0)));
    QMailMessageKey subjectKey(QMailMessageKey::subject(subject));

    searchAction->searchMessages(accountKey & folderKey & subjectKey, QString(), QMailSearchAction::Remote);
}

void ImapStorage::searchMessageActivityChanged(QMailServiceAction::Activity activity) {
    qDebug() << "searchActivityChanged: " << activity;

    QVariantList ret;
    QMailMessageIdList msgIds;

    switch (activity) {
        case QMailServiceAction::Successful:
            msgIds = searchAction->matchingMessageIds();

            qDebug() << "Search succeeded. Found " << msgIds.count() << " matches";

            for (int i = 0; i < msgIds.count(); i++) {
                ret.append(msgIds.at(i));
            }
            emit searchFinished(ret);
            break;
        case QMailServiceAction::Failed:
            qDebug("Search action failed.");
            emit error(searchAction->status().text, searchAction->status().errorCode, -1);
            emit searchFinished(ret);
            break;
        default:
            break;
    }
}

/*
 * FIXME: This is not working properly right now. As a workaround we use the
 * accountContentsModified(QMailAccountIdList) signal of QMailStore (see above).
 */
void ImapStorage::storageActivityChanged(QMailServiceAction::Activity activity) {
    qDebug() << "storageActivityChanged changed: " << activity;

    switch (activity) {
    case QMailServiceAction::Successful:
        switch (currentAction) {
        case CreateFolderAction:
            qDebug() << "Succeeded creating folder.";
            //emit folderCreated();
            break;
        case DeleteMessageAction:
            qDebug() << "Message deleted successfully.";
            currentAction = NoAction;
            emit messageDeleted();
            break;
        default:
            break;
        }
        break;
    case QMailServiceAction::Failed:
        qDebug("Storage action failed.");
        emit error(storageAction->status().text, storageAction->status().errorCode, currentAction);
        currentAction = NoAction;
        break;
    default:
        break;
    }
}

void ImapStorage::updateMessageAttachment(qulonglong msgId, QString attachment) {
    qDebug("Updating message attachment...");
    QMailMessage *oldMsg = new QMailMessage(QMailMessageId(msgId));

    /*
     * FIXME: Quite a hack to update the message on the server.
     * What we do is, essentially, to clone the message, upload the clone, and remove the old message.
     * Note: The account must be set to delete messages on the server for this to work.
     * See also the other FIXME below. This is actually how it should work.
     */
    QMailMessage msg;
    msg.setParentAccountId(oldMsg->parentAccountId());
    msg.setParentFolderId(oldMsg->parentFolderId());
    msg.setSubject(oldMsg->subject());
    msg.setMessageType(oldMsg->messageType());
    msg.setDate(QMailTimeStamp(QDateTime::currentDateTime()));
    msg.setStatus(QMailMessage::LocalOnly, true);
    msg.setAttachments(QStringList() << attachment);

    QMailStore::instance()->addMessage(&msg);
    QMailStore::instance()->removeMessage(oldMsg->id(), QMailStore::CreateRemovalRecord);
    QMailDisconnected::moveToFolder(QMailMessageIdList() << msg.id(), msg.parentFolderId());

    /*
     * FIXME: Why is this not working.
     * Ideally, we would just update the message as can be seen below.
     * However, this results in a copy of the old message being retained on the server.
     */
//    oldMsg->setAttachments(QStringList() << attachment);
//    oldMsg->setDate(QMailTimeStamp(QDateTime::currentDateTime()));
//    oldMsg->setStatus(QMailMessage::LocalOnly, true);
//    QMailStore::instance()->updateMessage(oldMsg);

    currentAction = UpdateMessageAction;
    retrievalAction->exportUpdates(QMailAccountId(oldMsg->parentAccountId()));
}

QString ImapStorage::writeAttachmentTo(qulonglong msgId, QString attachmentLocation, QString path) {
    QMailMessage *msg = new QMailMessage(QMailMessageId(msgId));
    QMailMessagePart attachment = msg->partAt(QMailMessagePart::Location(attachmentLocation));
    QString ret = attachment.writeBodyTo(path);
    return ret;
}
