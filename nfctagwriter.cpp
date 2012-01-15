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

#include "nfctagwriter.h"
#include <QTextStream>
#include <QNdefMessage>
#include <QNdefNfcTextRecord>
#include <QNearFieldTagType2>
#include <QNearFieldTagType4>
#include <QList>
#include <QUrl>
#include <QVariant>
#include <QDebug>

NfcTagWriter::NfcTagWriter(QObject *parent) :
    QObject(parent)
{
    writing = false;
    nfcManager = new QNearFieldManager();

    connect(nfcManager, SIGNAL(targetDetected(QNearFieldTarget*)), this, SLOT(targetDetected(QNearFieldTarget*)));
    connect(nfcManager, SIGNAL(targetLost(QNearFieldTarget*)), this, SLOT(targetLost(QNearFieldTarget*)));

    connect(this, SIGNAL(writeSuccess()), this, SLOT(stopWriting()));
}

NfcTagWriter::~NfcTagWriter(){
    delete nfcManager;
}

void NfcTagWriter::startWriting(){
    qDebug("Starting device detection for writing.");
    writing = true;
    nfcManager->setTargetAccessModes(QNearFieldManager::NdefWriteTargetAccess);
    nfcManager->startTargetDetection();
}

void NfcTagWriter::stopWriting(){
    qDebug("Stoping current process.");
    nfcManager->setTargetAccessModes(QNearFieldManager::NoTargetAccess);
    nfcManager->stopTargetDetection();
    writing = false;
}

void NfcTagWriter::targetDetected(QNearFieldTarget *target){
    qDebug("Detected NFC target.");
    qDebug("Target type: %d", target->type());
    qDebug() << "Supported access methods: " << (int) target->accessMethods();
    qDebug() << "Is processing command: " << target->isProcessingCommand();
    qDebug() << "Has NDEF message: " << target->hasNdefMessage();
    qDebug() << "UID is: " << target->uid().toHex() << " length is: " << target->uid().length();
    qDebug() << "URL is: " << target->url().toString();

    connect(target, SIGNAL(ndefMessagesWritten()), this, SIGNAL(writeSuccess()));
    connect(target, SIGNAL(error(QNearFieldTarget::Error, QNearFieldTarget::RequestId)), this, SLOT(targetError(QNearFieldTarget::Error, QNearFieldTarget::RequestId)));

    if(target->type() == QNearFieldTarget::NfcTagType2){
        QNearFieldTagType2 *nfcType2 = qobject_cast<QNearFieldTagType2 *>(target);
        qDebug("NFC type 2 version: %d", nfcType2->version());
        qDebug("Memory size: %d", nfcType2->memorySize());

//        qDebug("Trying to read message.");
//        currentReqId = target->readNdefMessages();

//        qDebug("Trying to write a block of data.");
//        currentReqId = nfcType2->writeBlock(0, QByteArray("abcd"));

//        qDebug("Waiting for completion");
//        if(target->waitForRequestCompleted(currentReqId)){
//            qDebug("Completed with:");
//            QVariant response = target->requestResponse(currentReqId);
//            qDebug() << "Response: " << response;
//        }else{
//            qDebug("Timed out.");
//        }
//        return;
    }

    if(target->type() == QNearFieldTarget::NfcTagType4){
        QNearFieldTagType4 *nfcType4 = qobject_cast<QNearFieldTagType4 *>(target);
        qDebug("NFC type 4 version: %d", nfcType4->version());
    }

    QNdefMessage message;
    QNdefNfcTextRecord record;
    record.setText("meepasswords:" + text);
    message.append(record);

    qDebug("Writing NFC tag.");
    currentReqId = target->writeNdefMessages(QList<QNdefMessage>() << message);
}

void NfcTagWriter::targetError(QNearFieldTarget::Error error, const QNearFieldTarget::RequestId &reqId){
    qDebug("Entering targetError slot.");
    if(currentReqId == reqId){
        QString errString;

        switch (error) {
        case QNearFieldTarget::NoError:
            errString = "NoError";
            break;
        case QNearFieldTarget::UnsupportedError:
            errString = "UnsupportedError";
            break;
        case QNearFieldTarget::TargetOutOfRangeError:
            errString = "TargetOutOfRangeError";
            break;
        case QNearFieldTarget::NoResponseError:
            errString = "NoResponseError";
            break;
        case QNearFieldTarget::ChecksumMismatchError:
            errString = "ChecksumMismatchError";
            break;
        case QNearFieldTarget::InvalidParametersError:
            errString = "InvalidParametersError";
            break;
        case QNearFieldTarget::NdefReadError:
            errString = "NdefReadError";
            break;
        case QNearFieldTarget::NdefWriteError:
            errString = "NdefWriteError";
            break;
        default:
            errString = "Unknown error";
        }

        QString msg;
        QTextStream(&msg) << "Failed with error: " << errString << " - " << error;
        qErrnoWarning(msg.toUtf8().constData());
        emit writeFailed(msg);
    }
}

void NfcTagWriter::targetLost(QNearFieldTarget *){
    qDebug("Lost NFC target.");
    if(writing){
        emit writeFailed("Lost contact to NFC tag while writing.");
        stopWriting();
        return;
    }
}

void NfcTagWriter::writeTextTag(QString text){
    if(! nfcManager->isAvailable()){
        emit writeFailed("NFC is not available. Please enable NFC and try again.");
        return;
    }

    if(writing){
        emit writeFailed("Already writing a tag.");
        return;
    }

    this->text = text;
    startWriting();
}

