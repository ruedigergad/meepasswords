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

#include <QDebug>
#include <QtCore/QtGlobal>

#include <QCoreApplication>
#include <QApplication>
#include <QQuickView>
#include <QProcess>
#include <QtQml>

#if defined(MER_EDITION_SAILFISH)
#include <sailfishapp.h>
#endif

#if defined(LINUX_DESKTOP)
#include <QIcon>
#endif

#include "entry.h"
#include "entrylistmodel.h"
#include "entrystorage.h"

#include "qmlclipboardadapter.h"
#include "settingsadapter.h"

#ifdef SYNC_TO_IMAP_SUPPORT
#include <envvarhelper.h>
#include <synctoimap.h>
#endif

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    qDebug("Starting MeePasswords...");

#if defined(MER_EDITION_SAILFISH)
    QCoreApplication::addLibraryPath("/usr/share/harbour-meepasswords/qca/plugins");
//    EnvVarHelper::appendToEnvironmentVariable("LD_LIBRARY_PATH", "/usr/share/harbour-meepasswords/qca/lib");
//    EnvVarHelper::appendToEnvironmentVariable("QT_PLUGIN_PATH", "/usr/share/harbour-meepasswords/qca/plugins");
    QGuiApplication *app = SailfishApp::application(argc, argv);
    QQuickView *view = SailfishApp::createView();
#elif defined(LINUX_DESKTOP)
    EnvVarHelper::appendToEnvironmentVariable("QT_PLUGIN_PATH", EnvVarHelper::getOwnLibPath() + "/qca/plugins");
    QApplication *app = new QApplication(argc, argv);
    QQuickView *view = new QQuickView();
#endif
#ifdef SYNC_TO_IMAP_SUPPORT
    SyncToImap::init();
#endif

    QCoreApplication::setOrganizationName("ruedigergad.com");
    QCoreApplication::setOrganizationDomain("ruedigergad.com");
    QCoreApplication::setApplicationName("meepasswords");

    qmlRegisterType<Entry>("meepasswords", 1, 0, "Entry");
    qmlRegisterType<EntryListModel>("meepasswords", 1, 0, "EntryListModel");
    qmlRegisterType<EntrySortFilterProxyModel>("meepasswords", 1, 0, "EntrySortFilterProxyModel");
    qmlRegisterType<EntryStorage>("meepasswords", 1, 0, "EntryStorage");

    qmlRegisterType<QmlClipboardAdapter>("meepasswords", 1, 0, "QClipboard");
    qmlRegisterType<SettingsAdapter>("meepasswords", 1, 0, "SettingsAdapter");

//TODO
    app->setApplicationName("MeePasswords");
    app->setApplicationDisplayName("MeePasswords");

#if defined(LINUX_DESKTOP)
    QIcon icon(":/meepasswords_64x64.png");
    view->setIcon(icon);
#endif

    view->setResizeMode(QQuickView::SizeRootObjectToView);
    view->setSource(QUrl("qrc:/main.qml"));
#if defined(MER_EDITION_SAILFISH)
    view->show();
#elif defined(LINUX_DESKTOP)
    view->resize(400, 500);
    view->show();
#endif

    int ret = app->exec();

#if defined(LINUX_DESKTOP)
    SyncToImap::shutdown();
#endif

    return ret;
}

