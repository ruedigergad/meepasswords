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

#ifndef IMAPSTORAGE_H
#define IMAPSTORAGE_H

#include <QObject>
#include <qmfclient/qmailaccount.h>
#include <qmfclient/qmailserviceaction.h>

class ImapStorage : public QObject
{
    Q_OBJECT
public:
    explicit ImapStorage(QObject *parent = 0);
    
    Q_INVOKABLE void addMessage(qulonglong accId, QString folder, QString subject, QString attachment = "");
    Q_INVOKABLE void createFolder(qulonglong accId, QString name);
    Q_INVOKABLE void deleteMessage(qulonglong msgId);
    Q_INVOKABLE bool folderExists(qulonglong accId, QString path);
    Q_INVOKABLE QString getAttachmentIdentifier(qulonglong msgId, QString attachmentLocation);
    Q_INVOKABLE QStringList getAttachmentLocations(qulonglong msgId);
    Q_INVOKABLE QString getDateString(qulonglong msgId);
    Q_INVOKABLE QString getSubject(qulonglong msgId);
    Q_INVOKABLE void moveMessageToTrash(qulonglong msgId);
    Q_INVOKABLE QVariantList queryImapAccounts();
    Q_INVOKABLE QVariantList queryMessages(qulonglong accId, QString folder, QString subject);
    Q_INVOKABLE bool removeMessage(qulonglong msgId);
    Q_INVOKABLE void retrieveFolderList(qulonglong accId);
    Q_INVOKABLE void retrieveMessage(qulonglong msgId);
    Q_INVOKABLE void retrieveMessageList(qulonglong accId, QString folder);
    Q_INVOKABLE void searchMessage(qulonglong accId, QString folder, QString subject);
    Q_INVOKABLE void updateMessageAttachment(qulonglong msgId, QString attachment);
    Q_INVOKABLE QString writeAttachmentTo(qulonglong msgId, QString attachmentLocation, QString path);

signals:
    void error(QString errorString, int errorCode, int currentAction);
    void folderCreated();
    void folderListRetrieved();
    void messageAdded();
    void messageDeleted();
    void messageListRetrieved();
    void messageRetrieved();
    void messageUpdated();
    void searchFinished(QVariantList msgIds);
    
public slots:

private slots:
    void accountContentsModified(const QMailAccountIdList &ids);
    void foldersAdded(QMailFolderIdList ids);
    void retrieveActivityChanged(QMailServiceAction::Activity);
    void searchMessageActivityChanged(QMailServiceAction::Activity);
    void storageActivityChanged(QMailServiceAction::Activity);

private:
    enum CurrentAction {
        NoAction,
        CreateFolderAction,
        AddMessageAction,
        SearchAction,
        RetrieveFolderListAction,
        RetrieveMessageListAction,
        RetrieveMessageAction,
        UpdateMessageAction,
        DeleteMessageAction,
        MoveToTrashAction
    };

    CurrentAction currentAction;
    QMailRetrievalAction *retrievalAction;
    QMailSearchAction *searchAction;
    QMailStorageAction *storageAction;

    QMailFolderIdList queryFolders(qulonglong accId, QString path);
};

#endif // IMAPSTORAGE_H
