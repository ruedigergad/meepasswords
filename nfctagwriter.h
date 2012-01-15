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

#ifndef NFCTAGWRITER_H
#define NFCTAGWRITER_H

#include <QObject>
#include <QNearFieldManager>
#include <QNearFieldTarget>

QTM_USE_NAMESPACE
class NfcTagWriter : public QObject
{
    Q_OBJECT
public:
    explicit NfcTagWriter(QObject *parent = 0);
    ~NfcTagWriter();

    Q_INVOKABLE void writeTextTag(QString text);

public slots:
    void stopWriting();

signals:
    void writeSuccess();
    void writeFailed(QString errorMsg);

private slots:
    void targetDetected(QNearFieldTarget *target);
    void targetError(QNearFieldTarget::Error error, const QNearFieldTarget::RequestId &reqId);
    void targetLost(QNearFieldTarget *target);

private:
    void startWriting();

    QNearFieldManager *nfcManager;

    QNearFieldTarget::RequestId currentReqId;
    QString text;
    bool writing;

};

#endif // NFCTAGWRITER_H
