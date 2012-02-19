/*
 *  Copyright 2011 Ruediger Gad
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

#ifndef ENTRYSTORAGE_H
#define ENTRYSTORAGE_H

#include <QObject>
#include <QStringList>

#ifdef MEEGO_EDITION_HARMATTAN
#include <aegis_storage.h>
#endif

#include <QtCrypto>

#include "entrylistmodel.h"
#include "entrysortfilterproxymodel.h"

#define DEFAULT_STORAGE "MeePasswords_DefaultStorage"
#define ENCRYPTED_FILE "/encrypted.raw"
#define CIPHER_TYPE "aes256"
#define CIPHER_MODE QCA::Cipher::CBC
#define CIPHER_PADDING QCA::Cipher::PKCS7
#define PASSWORD_HASH_ALGORITHM "sha256"
#define RANDOM_KEY_LENGTH 16

class EntryStorage : public QObject
{
    Q_OBJECT
public:
    explicit EntryStorage(QObject *parent = 0);
    ~EntryStorage();

    Q_INVOKABLE bool equalsStoredHash(QString hash);
    Q_INVOKABLE bool equalsStoredPassword(QString password);
    Q_INVOKABLE QString getBase64Hash(QString password);
    Q_INVOKABLE EntrySortFilterProxyModel* getModel() { return proxyModel; }

    Q_INVOKABLE void exportKeePassXml();
    Q_INVOKABLE void importKeePassXml();

    Q_INVOKABLE QString getRandomKeyAsString();
    Q_INVOKABLE bool canDecrypt(QString password);

signals:
    void decryptionFailed();
    void decryptionSuccess();
    void newFileOpened();

    void operationFailed(QString message);

    void storageOpenSuccess();
    void storageOpenSuccessNewPassword();

public slots:
    void loadAndDecryptDataUsingHash(QString hash);
    void loadAndDecryptDataUsingPassword(QString password);
    void openStorage();
    void setPassword(QString password);
    void storeModel();

private:
#ifdef MEEGO_EDITION_HARMATTAN
    bool migrateStorage();
    aegis::storage *aegisStorage;
#endif
    void encryptAndStoreData(const QByteArray rawData);
    void migrateSymmetricKey(QString password);
    void loadAndDecryptData();

    QCA::SecureArray hashPassword(QString password);

    QCA::Initializer *initializer;
    QCA::SymmetricKey *key;

    EntryListModel *model;
    EntrySortFilterProxyModel *proxyModel;
};

#endif // ENTRYSTORAGE_H
