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
//#include <aegis_crypto.h>
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

//#include "mcomboboxqmladapter.h"
//#include "mtexteditqmladapter.h"
#include "qcomboboxqmladapter.h"
#include "qmlclipboardadapter.h"
//#include "qlineeditqmladapter.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
#ifdef MEEGO_EDITION_HARMATTAN
//    MApplication app(argc, argv);
    QApplication *app = MDeclarativeCache::qApplication(argc, argv);
    QDeclarativeView *view = MDeclarativeCache::qDeclarativeView();

//    char *app_id;
//    aegis_application_id(getpid(), &app_id);
//    qDebug("Application Id: %s", app_id);
#else
    QApplication::setGraphicsSystem("raster");
    QApplication *app = new QApplication(argc, argv);
    QDeclarativeView *view = new QDeclarativeView();

    qDebug() << "Qt Build Key: " << QLibraryInfo::buildKey() << "   Qt Build Date: " << QLibraryInfo::buildDate();
#endif

    qmlRegisterType<Entry>("meepasswords", 1, 0, "Entry");
    qmlRegisterType<EntryListModel>("meepasswords", 1, 0, "EntryListModel");
    qmlRegisterType<EntrySortFilterProxyModel>("meepasswords", 1, 0, "EntrySortFilterProxyModel");
    qmlRegisterType<EntryStorage>("meepasswords", 1, 0, "EntryStorage");

#ifdef NFC_ENABLED
    qmlRegisterType<NfcTagWriter>("meepasswords", 1, 0, "NfcTagWriter");
#endif

//    qmlRegisterType<MComboBoxQmlAdapter>("meepasswords", 1, 0, "MComboBox");
//    qmlRegisterType<MTextEditQmlAdapter>("meepasswords", 1, 0, "MTextEdit");
    qmlRegisterType<QComboBoxQmlAdapter>("meepasswords", 1, 0, "QComboBox");
    qmlRegisterType<QmlClipboardAdapter>("meepasswords", 1, 0, "QClipboard");
//    qmlRegisterType<QLineEditQmlAdapter>("meepasswords", 1, 0, "QLineEdit");

    /*
     * Well, according to
     * http://doc.qt.nokia.com/4.7-snapshot/qdeclarativeperformance.html
     * the following shall help increasing the performance.
     * However, painting on a QGLWidget resulted in a major performance loss,
     * at least on an N900 using the experimental Qt version.
     */
    view->setAttribute(Qt::WA_OpaquePaintEvent);
    view->setAttribute(Qt::WA_NoSystemBackground);
    view->viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
    view->viewport()->setAttribute(Qt::WA_NoSystemBackground);

    view->setWindowTitle("MeePasswords");

#if defined(MEEGO_EDITION_HARMATTAN)
    view->setSource(QUrl("qrc:/qml/harmattan/main.qml"));
    view->showFullScreen();
#elif defined(QT_SIMULATOR)
    view->setSource(QUrl("qrc:/qml/harmattan/main.qml"));
    view->showFullScreen();
#else
    view->setResizeMode(QDeclarativeView::SizeRootObjectToView);
    view->setSource(QUrl("qrc:/qml/desktop/main.qml"));
#endif

#ifdef Q_WS_MAEMO_5
    view->setAttribute(Qt::WA_Maemo5AutoOrientation, true);
    view->resize(800, 424);
    view->show();
#else
    view->resize(600, 800);
    view->show();
#endif

    return app->exec();
}
