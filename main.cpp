/*
 *  Copyright 2011 - 2013 Ruediger Gad
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

#ifdef MEEGO_EDITION_HARMATTAN
#include <applauncherd/MDeclarativeCache>
#endif

#include <QDebug>

#include <QtCore/QtGlobal>
#include <QtDeclarative>

#include "entry.h"
#include "entrylistmodel.h"
#include "entrystorage.h"

#ifdef NFC_ENABLED
#include "nfctagwriter.h"
#endif

#if defined(BB10_BUILD)
#include <QGLWidget>
#endif

//#include "mcomboboxqmladapter.h"
//#include "mtexteditqmladapter.h"
//#include "qcomboboxqmladapter.h"
#include "qmlclipboardadapter.h"
#include "settingsadapter.h"
//#include "qlineeditqmladapter.h"

#include "filehelper.h"
#ifdef SYNC_TO_IMAP_SUPPORT
#include "imapaccounthelper.h"
#include "imapaccountlistmodel.h"
#include "imapstorage.h"
#endif

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    qDebug("Starting MeePasswords...");

#ifdef WINDOWS_DESKTOP
    putenv("QMF_PLUGINS=plugins");
#elif defined(LINUX_DESKTOP)
    putenv("QMF_PLUGINS=lib/qmf/plugins");
#elif defined(BB10_BUILD)
    QApplication::setStartDragDistance(40);
    QApplication::setStartDragTime(500);
    QApplication::setDoubleClickInterval(400);
#endif

#ifdef MEEGO_EDITION_HARMATTAN
//    MApplication app(argc, argv);
    QApplication *app = MDeclarativeCache::qApplication(argc, argv);
    QDeclarativeView *view = MDeclarativeCache::qDeclarativeView();

//    char *app_id;
//    aegis_application_id(getpid(), &app_id);
//    qDebug("Application Id: %s", app_id);
#else
//    QApplication::setGraphicsSystem("raster");
    QApplication *app = new QApplication(argc, argv);
    QDeclarativeView *view = new QDeclarativeView();
#endif
    qDebug() << "Qt Build Key: " << QLibraryInfo::buildKey() << "   Qt Build Date: " << QLibraryInfo::buildDate();

    QCoreApplication::setOrganizationName("ruedigergad.com");
    QCoreApplication::setOrganizationDomain("ruedigergad.com");
    QCoreApplication::setApplicationName("meepasswords");

    QTextCodec::setCodecForCStrings(QTextCodec::codecForName("UTF-8"));
    QTextCodec::setCodecForLocale(QTextCodec::codecForName("UTF-8"));
    QTextCodec::setCodecForTr(QTextCodec::codecForName("UTF-8"));

    /*
     * Some versions may need to start messageserver.
     */
#ifdef WINDOWS_DESKTOP
    QString messageServerRunningQuery = "tasklist | find /N \"messageserver.exe\"";
    QString messageServerExecutable = "messageserver.exe";
#endif
#ifdef LINUX_DESKTOP
    QString messageServerRunningQuery = "ps -el | grep messageserver";
    QString messageServerExecutable = QCoreApplication::applicationDirPath() + "/lib/qmf/bin/messageserver";
#endif
#if defined(LINUX_DESKTOP) || defined(WINDOWS_DESKTOP)
    QProcess queryMessageServerRunning;
    queryMessageServerRunning.start(messageServerRunningQuery);
    queryMessageServerRunning.waitForFinished(-1);

    bool messageServerStarted = false;
    QProcess messageServerProcess;
    if (queryMessageServerRunning.exitCode() != 0) {
        qDebug("Starting messageserver...");
        qDebug() << "messageserver executable: " << messageServerExecutable;
        messageServerProcess.start(messageServerExecutable);
        messageServerStarted = true;
    } else {
        qDebug("Messageserver is already running.");
    }

    SettingsAdapter().setFastScrollAnchor("right");
#endif
#ifdef BB10_BUILD
    QProcess messageServerProcess;
    qDebug("Starting messageserver...");
    messageServerProcess.start("app/native/lib/qmf/bin/messageserver");
#endif

    qmlRegisterType<Entry>("meepasswords", 1, 0, "Entry");
    qmlRegisterType<EntryListModel>("meepasswords", 1, 0, "EntryListModel");
    qmlRegisterType<EntrySortFilterProxyModel>("meepasswords", 1, 0, "EntrySortFilterProxyModel");
    qmlRegisterType<EntryStorage>("meepasswords", 1, 0, "EntryStorage");

#ifdef SYNC_TO_IMAP_SUPPORT
    qmlRegisterType<FileHelper>("SyncToImap", 1, 0, "FileHelper");
    qmlRegisterType<ImapAccountHelper>("SyncToImap", 1, 0, "ImapAccountHelper");
    qmlRegisterType<ImapAccountListModel>("SyncToImap", 1, 0, "ImapAccountListModel");
    qmlRegisterType<ImapStorage>("SyncToImap", 1, 0, "ImapStorage");
#endif

#ifdef NFC_ENABLED
    qmlRegisterType<NfcTagWriter>("meepasswords", 1, 0, "NfcTagWriter");
#endif

    qmlRegisterType<QmlClipboardAdapter>("meepasswords", 1, 0, "QClipboard");
    qmlRegisterType<SettingsAdapter>("meepasswords", 1, 0, "SettingsAdapter");

    /*
     * Well, according to
     * http://doc.qt.nokia.com/4.7-snapshot/qdeclarativeperformance.html
     * the following shall help increasing the performance.
     * However, painting on a QGLWidget resulted in a major performance loss,
     * at least on an N900 using the experimental Qt version.
     */
#ifndef BB10_BUILD
    view->setAttribute(Qt::WA_OpaquePaintEvent);
    view->setAttribute(Qt::WA_NoSystemBackground);
    view->viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
    view->viewport()->setAttribute(Qt::WA_NoSystemBackground);
#endif

    view->setWindowTitle("MeePasswords");

#if defined(MEEGO_EDITION_HARMATTAN)
    // Hack to automatically copy the data from an old installation.
    if (FileHelper().exists("/home/user/.local/share/data/MeePasswords_DefaultStorage/encrypted.raw")) {
        qDebug("Copying old storage.");
        FileHelper().mkdir("/home/user/.local/share/data/ruedigergad.com/meepasswords");
        FileHelper().cp("/home/user/.local/share/data/MeePasswords_DefaultStorage/encrypted.raw", "/home/user/.local/share/data/ruedigergad.com/meepasswords/encrypted.raw");
    }

    view->setSource(QUrl("qrc:/qml/harmattan/main2.qml"));
    view->showFullScreen();
#elif defined(QT_SIMULATOR)
    view->setSource(QUrl("qrc:/qml/harmattan/main.qml"));
    view->showFullScreen();
#elif defined(BB10_BUILD)
    view->setViewport(new QGLWidget());
    view->setViewportUpdateMode(QGraphicsView::FullViewportUpdate);
    view->setSource(QUrl("qrc:/qml/bb10/main.qml"));
    view->setResizeMode(QDeclarativeView::SizeRootObjectToView);
    view->showMaximized();
#else
    view->setResizeMode(QDeclarativeView::SizeRootObjectToView);
    view->setSource(QUrl("qrc:/qml/desktop/main.qml"));
    view->resize(400, 500);
    view->show();
#endif

//#ifdef Q_WS_MAEMO_5
//    view->setAttribute(Qt::WA_Maemo5AutoOrientation, true);
//    view->resize(800, 424);
//    view->show();
//#endif

    int ret = app->exec();

#if defined(LINUX_DESKTOP) || defined(WINDOWS_DESKTOP)
    if (messageServerStarted) {
        qDebug("Stopping messageserver...");
        messageServerProcess.kill();
    }
#endif
#ifdef BB10_BUILD
    qDebug("Stopping messageserver...");
    messageServerProcess.kill();
#endif

    return ret;
}
