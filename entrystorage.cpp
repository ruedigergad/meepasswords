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

#include "entrystorage.h"

#ifdef MEEGO_EDITION_HARMATTAN
//#include <aegis_crypto.h>
#include <QDesktopServices>
#endif

#include <QDebug>
#include <QDir>
#include <QFile>
#include <QTextStream>

#include "keepassxmlstreamreader.h"
#include "keepassxmlstreamwriter.h"

EntryStorage::EntryStorage(QObject *parent) :
    QObject(parent),
    useStorageIdentifier(false)
{
    setStoragePath(getStorageFilePath());

    qDebug("Initializing QCA...");
    initializer = new QCA::Initializer(QCA::Practical, 256);
    qDebug("QCA initialized.");

    QCA::scanForPlugins();
    qDebug("QCA Plugin Diagnostics Context: %s", QCA::pluginDiagnosticText().toUtf8().constData());

    QStringList capabilities;
    capabilities = QCA::supportedFeatures();
    qDebug("QCA supports: %s", capabilities.join(",").toUtf8().constData());

    model = new EntryListModel(this);
    proxyModel = new EntrySortFilterProxyModel(this);
    proxyModel->setSourceModel(model);
    connect(model, SIGNAL(countChanged(int)), proxyModel, SIGNAL(countChanged(int)));

    connect(model, SIGNAL(changed()), this, SLOT(storeModel()));
}

EntryStorage::~EntryStorage(){
    key.clear();

    if(initializer != NULL){
        delete initializer;
    }
    if(model != NULL) {
        disconnect(model, SIGNAL(changed()), this, SLOT(storeModel()));
        delete model;
    }
}

bool EntryStorage::equalsStoredHash(QString hash){
    return (key == QCA::PBKDF2().makeKey(hash.toLatin1(), passwordSalt, KEY_GEN_LENGTH, KEY_GEN_ITERATIONS));
}

bool EntryStorage::equalsStoredPassword(QString password){
    return (key == QCA::PBKDF2().makeKey(hashPassword(password), passwordSalt, KEY_GEN_LENGTH, KEY_GEN_ITERATIONS));
}

QString EntryStorage::getBase64Hash(QString password){
    return QString(hashPassword(password).toByteArray().toBase64());
}

QString EntryStorage::getStorageDirPath() {
#ifdef MEEGO_EDITION_HARMATTAN
    return QDesktopServices::storageLocation(QDesktopServices::DataLocation);
#else
    return QDir::homePath() + "/." + DEFAULT_STORAGE;
#endif
}

QString EntryStorage::getStorageFilePath() {
    return getStorageDirPath() + ENCRYPTED_FILE;
}

QCA::SecureArray EntryStorage::hashPassword(QString password){
    return QCA::Hash(PASSWORD_HASH_ALGORITHM).hash(QCA::SecureArray(QByteArray(password.toUtf8().constData())));
}

void EntryStorage::loadAndDecryptDataUsingHash(QString hash){
    qDebug("Creating symmetric key from given hash.");
    key = QCA::SymmetricKey(QByteArray::fromBase64(QByteArray().append(hash)));

    loadAndDecryptData();
}

void EntryStorage::loadAndDecryptDataUsingPassword(QString password){
    setPassword(password);
    migrateSymmetricKey(password);
    migrateStorageIdentifier(password);
    loadAndDecryptData();
}

bool EntryStorage::loadAndDecryptData() {
    QByteArray encryptedData;
    qDebug("Opening storage file for reading...");
    qDebug("Using file: %s", m_storagePath.toUtf8().constData());
    QFile storageFile(m_storagePath);

    if(! storageFile.exists()){
        qDebug("Seems we have a new file...");
        emit newFileOpened();
        return false;
    }

    if(storageFile.open(QIODevice::ReadOnly)){
        if (useStorageIdentifier) {
            qDebug("Storage identifier found. Skipping first line for loading encrypted data.");
            storageFile.readLine();
        } else {
            qDebug("No storage identifier found.");
        }

        encryptedData = storageFile.readAll();
        storageFile.close();
    }else{
        QString msg = "Failed to open storage file for reading...";
        qErrnoWarning(msg.toUtf8().constData());
        emit operationFailed(msg);
        return false;
    }
    qDebug("File successfully read.");
    qDebug("Read %d bytes.", encryptedData.size());
    QCA::MemoryRegion tempInput(encryptedData);

    qDebug("Create cipher for decrypting.");
    QCA::Cipher *cipher;
    if (useStorageIdentifier) {
        cipher = new QCA::Cipher(CIPHER_TYPE, CIPHER_MODE, CIPHER_PADDING, QCA::Decode, key, cbcIv);
    } else {
        cipher = new QCA::Cipher(CIPHER_TYPE, CIPHER_MODE, CIPHER_PADDING, QCA::Decode, key);
    }

    qDebug("Perform decryption.");
    QByteArray decrypted = cipher->process(tempInput).toByteArray();
    if(!cipher->ok()){
        QString msg = "Decryption failed.";
        qErrnoWarning(msg.toUtf8().constData());
        emit decryptionFailed();
        return false;
    }
    qDebug("Successfully decrypted.");

    qDebug("Size of decrypted data: %d", decrypted.size());
    qDebug("Going to add entries to model...");
    model->addFromByteArray(decrypted);

    qDebug("Decryption successful, creating backup, just in case.");
    QFile::remove(m_storagePath + BACKUP_SUFFIX);
    QFile::copy(m_storagePath, m_storagePath + BACKUP_SUFFIX);

    qDebug("Emitting decryptionSuccess() signal...");
    emit decryptionSuccess();
    return true;
}

/*
 * In newer versions we use the password hash as symmetric key. In older ones just the plain password was used.
 * Check if we are dealing with an old file by trying to open it with the plain password.
 * If we found an old file store it using the hashed password.
 */
void EntryStorage::migrateSymmetricKey(QString password){
    qDebug("SymmetricKey migration: Opening storage file for reading...");
    QByteArray encryptedData;

    qDebug("SymmetricKey migration: using file: %s", m_storagePath.toUtf8().constData());
    QFile storageFile(m_storagePath);

    if(! storageFile.exists()){
        qDebug("SymmetricKey migration: we have a new file...");
        return;
    }

    if(storageFile.open(QIODevice::ReadOnly)){
        encryptedData = storageFile.readAll();
        storageFile.close();
    }else{
        qDebug("Failed to open storage file for reading...");
        emit storageOpenError();
        return;
    }
    qDebug("SymmetricKey migration: file successfully read.");
    qDebug("SymmetricKey migration: read %d bytes.", encryptedData.size());
    QCA::MemoryRegion tempInput(encryptedData);

    qDebug("Checking if we need to migrate the password.");
    qDebug("SymmetricKey migration: creating old symmetric key.");
    QCA::SymmetricKey oldKey(QByteArray(password.toUtf8().constData()));
    qDebug("SymmetricKey migration: create old cipher for decrypting.");
    QCA::Cipher oldCipher(CIPHER_TYPE, CIPHER_MODE, CIPHER_PADDING, QCA::Decode, oldKey);
    qDebug("SymmetricKey migration: perform decryption.");
    QByteArray oldDecrypted = oldCipher.process(tempInput).toByteArray();
    if(oldCipher.ok()){
        qDebug("SymmetricKey migration: decryption succeeded. We are now going to store the data using the new key.");
        encryptAndStoreData(oldDecrypted);
        qDebug("SymmetricKey migration: done.");
        return;
    }

    qDebug("SymmetricKey migration: nothing to do.");
}

void EntryStorage::migrateStorageIdentifier(QString password){
    if (hasStorageIdentifierLine()) {
        qDebug("Storage identifier line found, not migrating.");
        return;
    }

    QByteArray encryptedData;

    qDebug("StorageIdentifier migration: Opening storage file for reading...");
    qDebug("StorageIdentifier migration: using file: %s", m_storagePath.toUtf8().constData());
    QFile storageFile(m_storagePath);

    if(! storageFile.exists()){
        qDebug("StorageIdentifier migration: we have a new file...");
        return;
    }

    if(storageFile.open(QIODevice::ReadOnly)){
        encryptedData = storageFile.readAll();
        storageFile.close();
    }else{
        qDebug("StorageIdentifier migration: Failed to open storage file for reading...");
        emit storageOpenError();
        return;
    }
    qDebug("StorageIdentifier migration: file successfully read.");
    qDebug("StorageIdentifier migration: read %d bytes.", encryptedData.size());
    QCA::MemoryRegion tempInput(encryptedData);

    qDebug("Checking if we need to migrate the password.");
    qDebug("StorageIdentifier migration: symmetric key the old way.");
    key = QCA::SymmetricKey(hashPassword(password));

    qDebug("StorageIdentifier migration: create old cipher for decrypting.");
    QCA::Cipher oldCipher(CIPHER_TYPE, CIPHER_MODE, CIPHER_PADDING, QCA::Decode, key);
    qDebug("StorageIdentifier migration: perform decryption.");
    QByteArray oldDecrypted = oldCipher.process(tempInput).toByteArray();
    if(oldCipher.ok()){
        qDebug("StorageIdentifier migration: decryption succeeded. We are now going to store the data using the new key.");
        passwordSalt = QCA::InitializationVector(KEY_GEN_IV_LENGTH);
        key = QCA::PBKDF2().makeKey(hashPassword(password), passwordSalt, KEY_GEN_LENGTH, KEY_GEN_ITERATIONS);
        useStorageIdentifier = true;
        encryptAndStoreData(oldDecrypted);
        qDebug("StorageIdentifier migration: done.");
        return;
    }

    qDebug("StorageIdentifier migration: nothing to do.");
}

void EntryStorage::openStorage(){
    QString storageDirPath = getStorageDirPath();
    QDir().mkpath(storageDirPath);

    qDebug("Path to storage file: %s", m_storagePath.toUtf8().constData());
    QFile storageFile(m_storagePath);
    if(storageFile.exists()){
        emit storageOpenSuccess();
    }else{
        emit storageOpenSuccessNewPassword();
    }
    if(storageFile.isOpen()){
        storageFile.close();
    }
}

void EntryStorage::setPassword(QString password){
    if (password.isEmpty() || password == "") {
        qDebug("Clearing key.");
        key.clear();
        return;
    }

    qDebug("Creating password hash.");
    QCA::SecureArray passwordHash = hashPassword(password);

    useStorageIdentifier = hasStorageIdentifierLine();

    qDebug("Creating symmetric key.");
    if (useStorageIdentifier) {
        qDebug("Creating key via PBKDF2.");
        key = QCA::PBKDF2().makeKey(passwordHash, passwordSalt, KEY_GEN_LENGTH, KEY_GEN_ITERATIONS);
        qDebug() << "Generated key with size: " << key.size();
    } else {
        qDebug("Migrating the storage.");
        migrateStorageIdentifier(password);
    }
}


void EntryStorage::storeModel(){
    qDebug("Storing model...");

    qDebug("Get data from model.");
    qDebug("Entries in model: %d", model->rowCount());
    encryptAndStoreData(model->toByteArray());
}

void EntryStorage::encryptAndStoreData(const QByteArray rawData){
    qDebug("Entering encryptAndStoreData...");

    if(key == QCA::SymmetricKey(hashPassword(""))){
        qDebug("Warning: attempted to store data with an unset or empty password.\nData will not be saved.");
        return;
    }

    qDebug("Encrypting and storing data.");
    QCA::MemoryRegion data(rawData);

    qDebug("Create cipher.");
    QCA::Cipher *cipher;
    if (useStorageIdentifier) {
        cbcIv = QCA::InitializationVector(CBC_IV_LENGTH);
        cipher = new QCA::Cipher(CIPHER_TYPE, CIPHER_MODE, CIPHER_PADDING, QCA::Encode, key, cbcIv);
    } else {
        cipher = new QCA::Cipher(CIPHER_TYPE, CIPHER_MODE, CIPHER_PADDING, QCA::Encode, key);
    }

    qDebug("Encrypt data.");
    QByteArray encrypted = cipher->process(data).toByteArray();
    if(!cipher->ok()){
        QString msg = "Encryption failed.";
        qErrnoWarning(msg.toUtf8().constData());
        emit operationFailed(msg);
        return;
    }
    qDebug("Successfully encrypted data.");

    qDebug("Opening storage file for writing...");
    QFile storageFile(getStorageFilePath());
    if(storageFile.isOpen() || storageFile.open(QIODevice::ReadWrite)){
        storageFile.resize(0);

        if (useStorageIdentifier) {
            qDebug("Writing storage identifier line.");
            storageFile.write(STORAGE_IDENTIFIER);
            storageFile.write("\t");
            storageFile.write(passwordSalt.toByteArray().toBase64());
            storageFile.write("\t");
            storageFile.write(cbcIv.toByteArray().toBase64());
            storageFile.write(CSV_NL);
            qDebug("Wrote storage identifier line.");
        }

        int count = storageFile.write(encrypted);
        qDebug("%d bytes written.", count);
        storageFile.close();
    }else{
        QString msg = "Failed to open storage file for writing...";
        qErrnoWarning(msg.toUtf8().constData());
        emit operationFailed(msg);
        return;
    }
    qDebug("File successfully written.");
}

void EntryStorage::exportKeePassXml(){
    KeePassXmlStreamWriter writer;
    writer.exportList(model->getEntryList());
}

void EntryStorage::importKeePassXml(){
    KeePassXmlStreamReader reader;
    model->appendEntries(reader.openFileForImport());
}

QString EntryStorage::getRandomKeyAsString(){
    QCA::SecureArray array(RANDOM_KEY_LENGTH);
    array = QCA::Random::randomArray(RANDOM_KEY_LENGTH);
    return QString(array.toByteArray().toBase64());
}

bool EntryStorage::canDecrypt(QString password){
    qDebug("Entering canDecrypt()...");

    QByteArray encryptedData;
    qDebug("canDecrypt(): Opening storage file for reading...");
    qDebug("canDecrypt(): Using file: %s", m_storagePath.toUtf8().constData());
    QFile storageFile(m_storagePath);

    if(! storageFile.exists()){
        qDebug("canDecrypt(): Seems we have a new file...");
        emit newFileOpened();
        return false;
    }

    if(storageFile.open(QIODevice::ReadOnly)){
        storageFile.readLine();
        encryptedData = storageFile.readAll();
        storageFile.close();
    }else{
        QString msg = "canDecrypt(): Failed to open storage file for reading...";
        qErrnoWarning(msg.toUtf8().constData());
        emit operationFailed(msg);
        return false;
    }
    qDebug("canDecrypt(): File successfully read.");
    qDebug("canDecrypt(): Read %d bytes.", encryptedData.size());
    QCA::MemoryRegion tempInput(encryptedData);

    qDebug("canDecrypt(): Create key for decrypting.");
    QCA::SymmetricKey tempKey = QCA::PBKDF2().makeKey(hashPassword(password), passwordSalt,
                                                KEY_GEN_LENGTH, KEY_GEN_ITERATIONS);

    qDebug("canDecrypt(): Create cipher for decrypting.");
    QCA::Cipher cipher(CIPHER_TYPE, CIPHER_MODE, CIPHER_PADDING, QCA::Decode, tempKey);

    qDebug("canDecrypt(): Perform decryption.");
    cipher.process(tempInput);
    return cipher.ok();
}

bool EntryStorage::hasStorageIdentifierLine() {
    qDebug("Checking existance of storage identifier line...");
    bool ret = false;

    qDebug("Using file: %s", m_storagePath.toUtf8().constData());
    QFile storageFile(m_storagePath);

    if(! storageFile.exists()){
        qDebug("Seems we have a new file...");
        return true;
    }

    if(storageFile.open(QIODevice::ReadOnly)){
        QByteArray firstLine = storageFile.readLine();

        if (! firstLine.startsWith(STORAGE_IDENTIFIER)) {
            qDebug("No storage identifier found.");
            ret = false;
        } else {
            qDebug() << "Found storage identifier in first line: " << firstLine;
            QList<QByteArray> identifierElements = firstLine.split('\t');

            if (identifierElements.length() != 3) {
                emit operationFailed("Failed! Storage identifier length not 3.");
                return false;
            }

            ret = true;
            useStorageIdentifier = true;
            passwordSalt = QCA::InitializationVector(QByteArray::fromBase64(identifierElements.at(1)));
            cbcIv = QCA::InitializationVector(QByteArray::fromBase64(identifierElements.at(2)));
        }
    }
    storageFile.close();

    return ret;
}

void EntryStorage::setStoragePath(QString path) {
    m_storagePath = path;
}
