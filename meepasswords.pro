# Add more folders to ship with the application, here

message(Building with Qt version: $$QT_VERSION)

exists($$QMAKE_INCDIR_QT"/../applauncherd/MDeclarativeCache"): {
    message(Harmattan Build)
    MEEGO_VERSION_MAJOR     = 1
    MEEGO_VERSION_MINOR     = 2
    MEEGO_VERSION_PATCH     = 0
    MEEGO_EDITION           = harmattan

    DEFINES += MEEGO_EDITION_HARMATTAN NFC_ENABLED SYNC_TO_IMAP_SUPPORT QDECLARATIVE_BOOSTER
    #PKGCONFIG += aegis-crypto
    RESOURCES += harmattan2.qrc

    CONFIG += mobility
    MOBILITY += connectivity

    CONFIG += link_pkgconfig
    PKGCONFIG += qmfclient qca2
} else:simulator {
    DEFINES += NFC_ENABLED
    RESOURCES += harmattan.qrc
    CONFIG += mobility
    MOBILITY += connectivity
} else:exists($$QMAKE_INCDIR_QT"/../bbndk.h"): {
    message(BB10 Build)

    DEFINES += BB10_BUILD SYNC_TO_IMAP_SUPPORT

    RESOURCES += bb10.qrc

    LIBS += -lbbdata -lbb -lbbcascades
    QT += declarative xml opengl

    INCLUDEPATH += \
        lib/include \
        lib/include/QtCrypto

    LIBS += \
        -L$$PWD/lib/link/bb10 \
        -lqca \
        -lqmfclient

    bb10Libs.source = lib/build/bb10
    bb10Libs.target = lib

    DEPLOYMENTFOLDERS += bb10Libs

    barDescriptor.files = bar-descriptor.xml
    barDescriptor.path = $${TARGET}

    INSTALLS += barDescriptor
}  else:win32 {
    message(Windows Build)

    DEFINES += WINDOWS_DESKTOP SYNC_TO_IMAP_SUPPORT
    DEFINES += _UNICODE

#    CONFIG += console

    INCLUDEPATH += \
        lib/include \
        lib/include/QtCrypto

    LIBS += \
        -Llib/build/windows/x86 \
        -lqmfclient \
        -lqca2

    RC_FILE = qtc_packaging/windows/meepasswords.rc

    RESOURCES += desktop.qrc
} else {
    message(Linux Desktop Build)
    DEFINES += LINUX_DESKTOP SYNC_TO_IMAP_SUPPORT
    RESOURCES += desktop.qrc
    QT += opengl

    LIBS += \
        -Wl,-rpath lib/qmf/lib

    # TODO: Dynamically determine architecture.
    arch = x86_64
    os = linux
    qmfLibs.target = lib

    isEqual(QT_MAJOR_VERSION, 5) {
        message(Qt5 Build)

        DEFINES += QT5_BUILD

        INCLUDEPATH += \
            lib/qt5/include \
            lib/qt5/include/QtCrypto

        LIBS += \
            -L$$PWD/lib/qt5/build/linux/x86_64 \
            -lqca-qt5 \
            -L$$PWD/lib/qt5/build/linux/x86_64/qmf/lib \
            -lqmfclient5 \
            -Wl,-rpath lib

        QT += qml quick

        RESOURCES += qtquick2.qrc

        qmfLibs.source = lib/qt5/build/$${os}/$${arch}/qmf
    } else {
        message(Qt4 Build)

        INCLUDEPATH += \
            lib/include

        LIBS += \
            -L$$PWD/lib/link/linux/x86_64 \
            -lqmfclient

        qmfLibs.source = lib/build/$${os}/$${arch}/qmf

        CONFIG += link_pkgconfig
        PKGCONFIG += qca2
    }

    DEPLOYMENTFOLDERS += qmfLibs
}

contains(DEFINES, QT5_BUILD) {
    message(Including qtquick2_common.qrc)
    RESOURCES += qtquick2_common.qrc
} else {
    message(Including old QtQuick 1.1 based common QML files.)
    RESOURCES += common.qrc
}

contains(DEFINES, SYNC_TO_IMAP_SUPPORT): {
    message(Building sync support...)
    HEADERS += \
        imapstorage.h \
        imapaccountlistmodel.h \
        imapaccounthelper.h
    SOURCES += \
        imapstorage.cpp \
        imapaccountlistmodel.cpp \
        imapaccounthelper.cpp
    contains(DEFINES, QT5_BUILD) {
        RESOURCES += qtquick2_synctoimap.qrc
    } else {
        RESOURCES += synctoimap.qrc
    }
}

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

QT+= declarative
maemo5:QT += maemo5
symbian:TARGET.UID3 = 0xE008F4C9

# Smart Installer package's UID
# This UID is from the protected range and therefore the package will
# fail to install if self-signed. By default qmake uses the unprotected
# range value if unprotected UID is defined for the application and
# 0x2002CCCF value if protected UID is given to the application
#symbian:DEPLOYMENT.installer_header = 0x2002CCCF

# Allow network access on Symbian
symbian:TARGET.CAPABILITY += NetworkServices

# If your application uses the Qt Mobility libraries, uncomment the following
# lines and add the respective components to the MOBILITY variable.
# CONFIG += mobility
# MOBILITY +=

HEADERS += \
    entry.h \
    entrystorage.h \
    entrylistmodel.h \
    keepassxmlstreamreader.h \
    keepassxmlstreamwriter.h \
    qmlclipboardadapter.h \
    entrysortfilterproxymodel.h \
    filehelper.h \
    settingsadapter.h

# The .cpp file which was generated for your project. Feel free to hack it.

SOURCES += \
    entry.cpp \
    entrystorage.cpp \
    entrylistmodel.cpp \
    keepassxmlstreamreader.cpp \
    keepassxmlstreamwriter.cpp \
    entrysortfilterproxymodel.cpp \
    filehelper.cpp \
    settingsadapter.cpp

contains(DEFINES, QT5_BUILD) {
    SOURCES += main-qt5.cpp
} else {
    SOURCES += main.cpp
}

contains(DEFINES, NFC_ENABLED) {
    HEADERS += nfctagwriter.h
    SOURCES += nfctagwriter.cpp
}

OTHER_FILES += \
    qml/harmattan/MainPage.qml \
    qml/harmattan/main.qml \
    meepasswords.desktop \
    meepasswords.svg \
    meepasswords.png \
    meepasswords_64x64.png \
    meepasswords_150x150.png \
    splash.png \
    splash.svg \
    qtc_packaging/debian_fremantle/rules \
    qtc_packaging/debian_fremantle/copyright \
    qtc_packaging/debian_fremantle/control \
    qtc_packaging/debian_fremantle/compat \
    qtc_packaging/debian_fremantle/changelog \
    qtc_packaging/debian_harmattan/rules \
    qtc_packaging/debian_harmattan/copyright \
    qtc_packaging/debian_harmattan/control \
    qtc_packaging/debian_harmattan/compat \
    qtc_packaging/debian_harmattan/changelog \
    qtc_packaging/debian_harmattan/meepasswords.aegis \
    qml/common/EntryDelegate.qml \
    qml/common/EntryListView.qml \
    qml/common/EntryShowDialog.qml \
    qml/common/MessageDialog.qml \
    qml/common/MeePasswordsToolBar.qml \
    qml/common/PasswordChangeDialog.qml \
    qml/harmattan/PasswordInputPage.qml \
    qml/harmattan/EntryInputPage.qml \
    qml/harmattan/EditEntrySheet.qml \
    qml/harmattan/AboutDialog.qml \
    qml/harmattan/ErrorDialog.qml \
    qml/bb10/main.qml \
    qml/desktop/main.qml \
    qml/desktop/common/Dialog.qml \
    qml/desktop/common/CommonDialog.qml \
    qml/desktop/common/CommonButton.qml \
    qml/desktop/common/CommonToolBar.qml \
    qml/desktop/common/ConfirmationDialog.qml \
    qml/desktop/common/CommonToolIcon.qml \
    qml/desktop/common/CommonTextField.qml \
    qml/desktop/common/CommonTextArea.qml \
    qml/harmattan/ConfirmationDialog.qml \
    res/fremantle/meepasswords.desktop \
    res/fremantle/meepasswords.png \
    qml/harmattan/CommonTextArea.qml \
    qml/harmattan/CommonTextField.qml \
    qml/harmattan/CommonDialog.qml \
    qml/harmattan/CommonButton.qml \
    qml/common/constants.js \
    qml/harmattan/NfcWriteDialog.qml \
    qml/harmattan/EntryDelegate.qml \
    qml/harmattan/LabeledInput.qml \
    qml/harmattan/ShowEntryPage.qml \
    qml/harmattan/EntryLabel.qml \
    qml/common/FastScroll.qml \
    qml/common/FastScrollStyle.qml \
    qml/common/FastScroll.js \
    qml/common/MainFlickable.qml \
    qml/common/PasswordInputRectangle.qml \
    qml/common/EditEntryRectangle.qml \
    qml/common/AboutDialog.qml \
    qml/common/Menu.qml \
    qml/common/TextInputDialog.qml \
    qml/common/SelectionDialog.qml \
    qml/common/ImapAccountSettingsSheet.qml \
    qml/common/SyncToImapBase.qml \
    qml/common/SyncDirToImap.qml \
    qml/common/SyncFileToImap.qml \
    qml/common/ProgressDialog.qml \
    bar-descriptor.xml \
    qml/common/Merger.qml \
    qml/desktop/common/CommonFlickable.qml \
    qml/common/SyncMessageDeleter.qml \
    qml/harmattan/main2.qml \
    qml/harmattan/main3.qml \
    qml/qtquick2/main.qml \
    qml/qtquick2/common/Dialog.qml \
    qml/qtquick2/common/CommonDialog.qml \
    qml/qtquick2/common/CommonButton.qml \
    qml/qtquick2/common/CommonToolBar.qml \
    qml/qtquick2/common/ConfirmationDialog.qml \
    qml/qtquick2/common/CommonToolIcon.qml \
    qml/qtquick2/common/CommonTextField.qml \
    qml/qtquick2/common/CommonTextArea.qml \
    qml/qtquick2_common/constants.js \
    qml/qtquick2_common/EntryDelegate.qml \
    qml/qtquick2_common/EntryListView.qml \
    qml/qtquick2_common/MessageDialog.qml \
    qml/qtquick2_common/MeePasswordsToolBar.qml \
    qml/qtquick2_common/PasswordChangeDialog.qml \
    qml/qtquick2_common/FastScroll.qml \
    qml/qtquick2_common/FastScrollStyle.qml \
    qml/qtquick2_common/FastScroll.js \
    qml/qtquick2_common/PasswordInputRectangle.qml \
    qml/qtquick2_common/EditEntryRectangle.qml \
    qml/qtquick2_common/AboutDialog.qml \
    qml/qtquick2_common/Menu.qml \
    qml/qtquick2_common/TextInputDialog.qml \
    qml/qtquick2_common/SelectionDialog.qml \
    qml/qtquick2_common/ImapAccountSettingsSheet.qml \
    qml/qtquick2_common/SyncToImapBase.qml \
    qml/qtquick2_common/SyncDirToImap.qml \
    qml/qtquick2_common/SyncFileToImap.qml \
    qml/qtquick2_common/ProgressDialog.qml \
    qml/qtquick2_common/Merger.qml \
    qml/qtquick2_common/SyncMessageDeleter.qml \
    qml/qtquick2_common/EntryListViewRectangle.qml


# Please do not modify the following two lines. Required for deployment.
include(deployment.pri)
qtcAddDeployment()

splash.files = splash.png
splash.path = /opt/meepasswords
INSTALLS += splash

contains(DEFINES, QDECLARATIVE_BOOSTER): {
    message(Enabling qdeclarative booster.)
    CONFIG += qdeclarative-boostable
    QMAKE_CXXFLAGS += -fPIC -fvisibility=hidden -fvisibility-inlines-hidden
    QMAKE_LFLAGS += -pie -rdynamic
}
