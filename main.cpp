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

#ifdef MEEGO_EDITION_HARMATTAN
#include <applauncherd/MDeclarativeCache>
#else
#include <QDebug>
#endif

#include <QtCore/QtGlobal>
#include <QtDeclarative>

#include "entry.h"
#include "entrylistmodel.h"
#include "entrystorage.h"

#ifdef NFC_ENABLED
#include "nfctagwriter.h"
#endif

#if defined(LINUX_DESKTOP) || defined(BB10_BUILD)
#include <QGLWidget>
#endif

//#include "mcomboboxqmladapter.h"
//#include "mtexteditqmladapter.h"
//#include "qcomboboxqmladapter.h"
#include "qmlclipboardadapter.h"
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

#if defined(BB10_BUILD)
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

    QTextCodec::setCodecForCStrings(QTextCodec::codecForName("UTF-8"));
    QTextCodec::setCodecForLocale(QTextCodec::codecForName("UTF-8"));
    QTextCodec::setCodecForTr(QTextCodec::codecForName("UTF-8"));

    qmlRegisterType<Entry>("meepasswords", 1, 0, "Entry");
    qmlRegisterType<EntryListModel>("meepasswords", 1, 0, "EntryListModel");
    qmlRegisterType<EntrySortFilterProxyModel>("meepasswords", 1, 0, "EntrySortFilterProxyModel");
    qmlRegisterType<EntryStorage>("meepasswords", 1, 0, "EntryStorage");

    qmlRegisterType<FileHelper>("meepasswords", 1, 0, "FileHelper");
#ifdef SYNC_TO_IMAP_SUPPORT
    qmlRegisterType<ImapAccountHelper>("meepasswords", 1, 0, "ImapAccountHelper");
    qmlRegisterType<ImapAccountListModel>("meepasswords", 1, 0, "ImapAccountListModel");
    qmlRegisterType<ImapStorage>("meepasswords", 1, 0, "ImapStorage");
#endif

#ifdef NFC_ENABLED
    qmlRegisterType<NfcTagWriter>("meepasswords", 1, 0, "NfcTagWriter");
#endif

    qmlRegisterType<QmlClipboardAdapter>("meepasswords", 1, 0, "QClipboard");

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
    view->setSource(QUrl("qrc:/qml/harmattan/main.qml"));
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
    view->setViewport(new QGLWidget());
    view->setSource(QUrl("qrc:/qml/desktop/main.qml"));
    view->resize(400, 500);
    view->show();
#endif

//#ifdef Q_WS_MAEMO_5
//    view->setAttribute(Qt::WA_Maemo5AutoOrientation, true);
//    view->resize(800, 424);
//    view->show();
//#endif

    return app->exec();
}
