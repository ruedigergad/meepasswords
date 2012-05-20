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
    QObject(parent)
{
/*
#ifdef MEEGO_EDITION_HARMATTAN
    aegisStorage = NULL;
#endif
*/

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

    connect(model, SIGNAL(changed()), this, SLOT(storeModel()));

    key = NULL;
}

EntryStorage::~EntryStorage(){
/*
#ifdef MEEGO_EDITION_HARMATTAN
    if(aegisStorage != NULL){
        delete aegisStorage;
    }
#endif
*/
    if(key != NULL){
        delete key;
    }
    if(initializer != NULL){
        delete initializer;
    }
    if(model != NULL) {
        disconnect(model, SIGNAL(changed()), this, SLOT(storeModel()));
        delete model;
    }
}

bool EntryStorage::equalsStoredHash(QString hash){
    return (key != NULL && *key == QCA::SymmetricKey(QByteArray::fromBase64(QByteArray().append(hash))));
}

bool EntryStorage::equalsStoredPassword(QString password){
    return (key != NULL && *key == QCA::SymmetricKey(hashPassword(password)));
}

QString EntryStorage::getBase64Hash(QString password){
    return QString(hashPassword(password).toByteArray().toBase64());
}

QCA::SecureArray EntryStorage::hashPassword(QString password){
    return QCA::Hash(PASSWORD_HASH_ALGORITHM).hash(QCA::SecureArray(QByteArray(password.toUtf8().constData())));
}

void EntryStorage::loadAndDecryptDataUsingHash(QString hash){
    if(key != NULL){
        delete key;
    }

    qDebug("Creating symmetric key from given hash.");
    key = new QCA::SymmetricKey(QByteArray::fromBase64(QByteArray().append(hash)));

    loadAndDecryptData();
}

void EntryStorage::loadAndDecryptDataUsingPassword(QString password){
    setPassword(password);
    migrateSymmetricKey(password);
    loadAndDecryptData();
}

void EntryStorage::loadAndDecryptData(){
    QByteArray encryptedData;
    qDebug("Opening storage file for reading...");
#ifdef MEEGO_EDITION_HARMATTAN
    QString storagePath = QDesktopServices::storageLocation(QDesktopServices::DataLocation) + QString(DEFAULT_STORAGE) + ENCRYPTED_FILE;
#else
    QString storagePath = QDir::homePath() + "/." + DEFAULT_STORAGE + ENCRYPTED_FILE;
#endif
    qDebug("Using file: %s", storagePath.toUtf8().constData());
    QFile storageFile(storagePath);

    if(! storageFile.exists()){
        qDebug("Seems we have a new file...");
        emit newFileOpened();
        return;
    }

    if(storageFile.open(QIODevice::ReadOnly)){
        encryptedData = storageFile.readAll();
        storageFile.close();
    }else{
        QString msg = "Failed to open storage file for reading...";
        qErrnoWarning(msg.toUtf8().constData());
        emit operationFailed(msg);
        return;
    }
    qDebug("File successfully read.");
    qDebug("Read %d bytes.", encryptedData.size());
    QCA::MemoryRegion tempInput(encryptedData);

    qDebug("Create cipher for decrypting.");
    QCA::Cipher cipher(CIPHER_TYPE, CIPHER_MODE, CIPHER_PADDING, QCA::Decode, *key);

    qDebug("Perform decryption.");
    QByteArray decrypted = cipher.process(tempInput).toByteArray();
    if(!cipher.ok()){
        QString msg = "Decryption failed.";
        qErrnoWarning(msg.toUtf8().constData());
        emit decryptionFailed();
        return;
    }
    qDebug("Successfully decrypted.");

    qDebug("Size of decrypted data: %d", decrypted.size());
    qDebug("Going to add entries to model...");
    model->addFromByteArray(decrypted);

    qDebug("Emitting decryptionSuccess() signal...");
    emit decryptionSuccess();
}

/*
 * In newer versions we use the password hash as symmetric key. In older ones just the plain password was used.
 * Check if we are dealing with an old file by trying to open it with the plain password.
 * If we found an old file store it using the hashed password.
 */
void EntryStorage::migrateSymmetricKey(QString password){
    qDebug("SymmetricKey migration: Opening storage file for reading...");
    QByteArray encryptedData;

#ifdef MEEGO_EDITION_HARMATTAN
    QString storagePath = QDesktopServices::storageLocation(QDesktopServices::DataLocation) + QString(DEFAULT_STORAGE) + ENCRYPTED_FILE;
#else
    QString storagePath = QDir::homePath() + "/." + DEFAULT_STORAGE + ENCRYPTED_FILE;
#endif
    qDebug("SymmetricKey migration: using file: %s", storagePath.toUtf8().constData());
    QFile storageFile(storagePath);

    if(! storageFile.exists()){
        qDebug("SymmetricKey migration: we have a new file...");
        return;
    }

    if(storageFile.open(QIODevice::ReadOnly)){
        encryptedData = storageFile.readAll();
        storageFile.close();
    }else{
        qDebug("Failed to open storage file for reading...");
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
    }else{
        qDebug("SymmetricKey migration: nothing to do.");
    }
    qDebug("SymmetricKey migration: done.");
}

/*
#ifdef MEEGO_EDITION_HARMATTAN
bool EntryStorage::migrateStorage(){
    QByteArray encryptedData;

    void *raw_data;
    size_t length;

    int ret = aegisStorage->get_file(ENCRYPTED_FILE, &raw_data, &length);
    if(ret != 0){
        QString msg;
        QTextStream(&msg) << "Error opening encrypted file from storage for data migration: " << ret;
        qErrnoWarning(msg.toUtf8().constData());
        emit operationFailed(msg);
        return false;
    }else if(length == 0){
        qDebug("Empty file...");
        emit newFileOpened();
        return false;
    }

    encryptedData = QByteArray((char *) raw_data, length);
    qDebug("Read %d bytes of data. Going to store data at new location.", length);

    QFile storageFile(QDesktopServices::storageLocation(QDesktopServices::DataLocation) + QString("/") + QString(DEFAULT_STORAGE) + QString(ENCRYPTED_FILE));

    if(storageFile.isOpen() || storageFile.open(QIODevice::ReadWrite)){
        storageFile.resize(0);
        int count = storageFile.write(encryptedData);
        qDebug("%d bytes written to new location.", count);
        storageFile.close();
    }else{
        QString msg = "Failed to open storage file for writing during migration...";
        qErrnoWarning(msg.toUtf8().constData());
        emit operationFailed(msg);
        return false;
    }
    qDebug("Data successfully migrated.");
    return true;
}
#endif
*/

void EntryStorage::openStorage(){

#ifdef MEEGO_EDITION_HARMATTAN
    QString storageDirPath = QDesktopServices::storageLocation(QDesktopServices::DataLocation) + QString(DEFAULT_STORAGE);

//    QDir storageDir(storageDirPath);

//    if(! storageDir.exists()){
//        /*
//         * Going to migrate data from Aegis to a location in the file system.
//         * This operation is quite risky as we are messing with live data and probably have only one shot.
//         */
//        QDir().mkpath(storageDirPath);
//        aegisStorage = new aegis::storage(DEFAULT_STORAGE, NULL, aegis::storage::vis_private, aegis::storage::prot_encrypted);

//        if(aegisStorage->status() == aegis::storage::writable){
//            qDebug("Success opening storage for writing.");

//            if(aegisStorage->contains_file(ENCRYPTED_FILE)){
//                qDebug("Found existing file. Going to migrate file to new location.");

//                /*
//                 * Remove directory if an error occured to notify us on the next start that we need to try again.
//                 */
//                if(! migrateStorage()){
//                    QDir().rmdir(storageDirPath);
//                }
//            }
//        }
//    }
#else
    QString storageDirPath = QDir::home().absolutePath() + QString("/.") + QString(DEFAULT_STORAGE);
#endif
    QDir().mkpath(storageDirPath);

    QString storagePath = storageDirPath + QString(ENCRYPTED_FILE);
    qDebug("Path to storage file: %s", storagePath.toUtf8().constData());
    QFile storageFile(storagePath);
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
    if(key != NULL){
        delete key;
    }

    qDebug("Creating password hash.");
    QCA::SecureArray passwordHash = hashPassword(password);
    qDebug("Creating symmetric key.");
    key = new QCA::SymmetricKey(passwordHash);
}


void EntryStorage::storeModel(){
    qDebug("Storing model...");

    qDebug("Get data from model.");
    qDebug("Entries in model: %d", model->rowCount());
    encryptAndStoreData(model->toByteArray());
}

void EntryStorage::encryptAndStoreData(const QByteArray rawData){
    qDebug("Encrypting and storing data.");
    QCA::MemoryRegion data(rawData);

    qDebug("Create cipher.");
    QCA::Cipher cipher(CIPHER_TYPE, CIPHER_MODE, CIPHER_PADDING, QCA::Encode, *key);

    qDebug("Encrypt data.");
    QByteArray encrypted = cipher.process(data).toByteArray();
    if(!cipher.ok()){
        QString msg = "Encryption failed.";
        qErrnoWarning(msg.toUtf8().constData());
        emit operationFailed(msg);
        return;
    }
    qDebug("Successfully encrypted data.");

    qDebug("Opening storage file for writing...");
#ifdef MEEGO_EDITION_HARMATTAN
    QFile storageFile(QDesktopServices::storageLocation(QDesktopServices::DataLocation) + QString("/") + QString(DEFAULT_STORAGE) + QString(ENCRYPTED_FILE));
#else
    QFile storageFile(QDir::homePath() + QString("/.") + QString(DEFAULT_STORAGE) + QString(ENCRYPTED_FILE));
#endif
    if(storageFile.isOpen() || storageFile.open(QIODevice::ReadWrite)){
        storageFile.resize(0);
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
    setPassword(password);

    QByteArray encryptedData;
    qDebug("canDecrypt(): Opening storage file for reading...");
#ifdef MEEGO_EDITION_HARMATTAN
    QString storagePath = QDesktopServices::storageLocation(QDesktopServices::DataLocation) + QString(DEFAULT_STORAGE) + ENCRYPTED_FILE;
#else
    QString storagePath = QDir::homePath() + "/." + DEFAULT_STORAGE + ENCRYPTED_FILE;
#endif
    qDebug("canDecrypt(): Using file: %s", storagePath.toUtf8().constData());
    QFile storageFile(storagePath);

    if(! storageFile.exists()){
        qDebug("canDecrypt(): Seems we have a new file...");
        emit newFileOpened();
        return false;
    }

    if(storageFile.open(QIODevice::ReadOnly)){
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

    qDebug("canDecrypt(): Create cipher for decrypting.");
    QCA::Cipher cipher(CIPHER_TYPE, CIPHER_MODE, CIPHER_PADDING, QCA::Decode, *key);

    qDebug("canDecrypt(): Perform decryption.");
    cipher.process(tempInput).toByteArray();
    return cipher.ok();
}
