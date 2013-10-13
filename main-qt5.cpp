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
#include <QGuiApplication>
#include <QQuickView>
#include <QProcess>
#include <QtQml>

#include "entry.h"
#include "entrylistmodel.h"
#include "entrystorage.h"

#include "qmlclipboardadapter.h"
#include "settingsadapter.h"

#ifdef SYNC_TO_IMAP_SUPPORT
#include <synctoimap.h>
#endif

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    qDebug("Starting MeePasswords...");

#if defined(LINUX_DESKTOP)
    putenv("QT_PLUGIN_PATH=lib/qca/plugins");
    SyncToImap::init();
#endif

    QGuiApplication *app = new QGuiApplication(argc, argv);
    QQuickView *view = new QQuickView();

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

    view->setResizeMode(QQuickView::SizeRootObjectToView);
    view->setSource(QUrl("qrc:/qml/qtquick2/main.qml"));
    view->resize(400, 500);
    view->show();

    int ret = app->exec();

#if defined(LINUX_DESKTOP)
    SyncToImap::shutdown();
#endif

    return ret;
}

