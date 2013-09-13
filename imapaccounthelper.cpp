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

#include "imapaccounthelper.h"
#include <QDebug>
#include <QSettings>
#include <qmfclient/qmailaccount.h>
#include <qmfclient/qmailstore.h>
#include <qmfclient/qmailnamespace.h>
#include <qmfclient/qmailpluginmanager.h>

ImapAccountHelper::ImapAccountHelper(QObject *parent) :
    QObject(parent)
{
}

int ImapAccountHelper::encryptionSetting(qulonglong accId) {
    return imapConfig(accId).value("encryption").toInt();
}

int ImapAccountHelper::imapAuthenticationType(qulonglong accId) {
    return imapConfig(accId).value("authentication").toInt();
}

QMailAccountConfiguration::ServiceConfiguration ImapAccountHelper::imapConfig(qulonglong accId) {
    QMailAccountConfiguration *accountConfig = new QMailAccountConfiguration(QMailAccountId(accId));
    QMailAccountConfiguration::ServiceConfiguration serviceConfig = accountConfig->serviceConfiguration("imap4");
    return serviceConfig;
}

QString ImapAccountHelper::imapPassword(qulonglong accId) {
    return QString(QByteArray::fromBase64(imapConfig(accId).value("password").toLatin1()));
}

QString ImapAccountHelper::imapPort(qulonglong accId) {
    return imapConfig(accId).value("port");
}

QString ImapAccountHelper::imapServer(qulonglong accId) {
    return imapConfig(accId).value("server");
}

QString ImapAccountHelper::imapUserName(qulonglong accId) {
    return imapConfig(accId).value("username");
}

void ImapAccountHelper::addAccount(QString accountName, QString userName, QString password, QString server, QString port, int encryptionSetting, int authType) {
    qDebug() << "Adding new account: " << accountName << " " << userName << " " << server << " " << port << " " << encryptionSetting;
    QMailAccount *account = new QMailAccount();

    account->setMessageType(QMailMessage::Email);
    account->setName(accountName);
    account->setStatus(QMailAccount::Enabled, true);
    account->setStatus(QMailAccount::MessageSource, true);
    account->setStatus(QMailAccount::UserEditable, true);
    account->setStatus(QMailAccount::UserRemovable, true);

    QMailAccountConfiguration *accountConfig = new QMailAccountConfiguration();
    accountConfig->addServiceConfiguration("imap4");
    QMailAccountConfiguration::ServiceConfiguration serviceConfig = accountConfig->serviceConfiguration("imap4");

    serviceConfig.setValue("username", userName);
    serviceConfig.setValue("password", QString(password.toLatin1().toBase64()));
    serviceConfig.setValue("server", server);
    serviceConfig.setValue("port", port);
    serviceConfig.setValue("encryption", QString::number(encryptionSetting));
    serviceConfig.setValue("canDelete", "1");
    serviceConfig.setValue("servicetype", "source");
//    serviceConfig.setValue("capabilities", "IMAP4rev1 CHILDREN ENABLE ID IDLE LIST-EXTENDED LIST-STATUS LITERAL+ MOVE NAMESPACE SASL-IR SORT THREAD=ORDEREDSUBJECT UIDPLUS UNSELECT WITHIN AUTH=LOGIN AUTH=PLAIN");
    serviceConfig.setValue("authentication", QString::number(authType));
    serviceConfig.setValue("autoDownload", "0");
    serviceConfig.setValue("baseFolder", "");

    QMailStore::instance()->addAccount(account, accountConfig);
}

void ImapAccountHelper::removeAccount(qulonglong accId) {
    qDebug("Removing account: %lld", accId);
    QMailStore::instance()->removeAccount(QMailAccountId(accId));
}

void ImapAccountHelper::updateAccount(qulonglong accId, QString userName, QString password, QString server, QString port, int encryptionSetting, int authType) {
    qDebug() << "Updating account: " << accId << " " << userName << " " << server << " " << port << " " << encryptionSetting;
    QMailAccount *account = new QMailAccount(QMailAccountId(accId));

    QMailAccountConfiguration *accountConfig = new QMailAccountConfiguration(QMailAccountId(accId));
    QMailAccountConfiguration::ServiceConfiguration serviceConfig = accountConfig->serviceConfiguration("imap4");

    serviceConfig.setValue("username", userName);
    serviceConfig.setValue("password", QString(password.toLatin1().toBase64()));
    serviceConfig.setValue("server", server);
    serviceConfig.setValue("port", port);
    serviceConfig.setValue("encryption", QString::number(encryptionSetting));
    serviceConfig.setValue("authentication", QString::number(authType));

    QMailStore::instance()->updateAccount(account, accountConfig);
}

qulonglong ImapAccountHelper::getSyncAccount() {
    return QSettings().value("syncAccountId", -1).toULongLong();
}

void ImapAccountHelper::setSyncAccount(qulonglong accId) {
    qDebug("Setting account id: %lld", accId);
    QSettings().setValue("syncAccountId", accId);
}
