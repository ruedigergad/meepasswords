# Add more folders to ship with the application, here

#exists($$QMAKE_INCDIR_QT"/../applauncherd/MDeclarativeCache"):!contains(MEEGO_EDITION,harmattan): {
exists($$QMAKE_INCDIR_QT"/../applauncherd/MDeclarativeCache"): {
    MEEGO_VERSION_MAJOR     = 1
    MEEGO_VERSION_MINOR     = 2
    MEEGO_VERSION_PATCH     = 0
    MEEGO_EDITION           = harmattan

    DEFINES += MEEGO_EDITION_HARMATTAN NFC_ENABLED
    PKGCONFIG += aegis-crypto
    RESOURCES += harmattan.qrc

    CONFIG += mobility
    MOBILITY += connectivity
} else:simulator {
    DEFINES += NFC_ENABLED
    RESOURCES += harmattan.qrc
    CONFIG += mobility
    MOBILITY += connectivity
} else {
   RESOURCES += desktop.qrc
}

RESOURCES += common.qrc

CONFIG += link_pkgconfig
PKGCONFIG += qca2

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
    qlineeditqmladapter.h \
#    mtexteditqmladapter.h \
#    mcomboboxqmladapter.h \
    qcomboboxqmladapter.h \
    keepassxmlstreamreader.h \
    keepassxmlstreamwriter.h \
    qmlclipboardadapter.h \
    entrysortfilterproxymodel.h

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp \
    entry.cpp \
    entrystorage.cpp \
    entrylistmodel.cpp \
    qlineeditqmladapter.cpp \
#    mtexteditqmladapter.cpp \
#    mcomboboxqmladapter.cpp \
    qcomboboxqmladapter.cpp \
    keepassxmlstreamreader.cpp \
    keepassxmlstreamwriter.cpp \
    entrysortfilterproxymodel.cpp

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
    qml/common/EntryListView.qml \
    qml/common/EntryShowDialog.qml \
    qml/common/MessageDialog.qml \
    qml/common/PasswordChangeDialog.qml \
    qml/harmattan/PasswordInputPage.qml \
    qml/harmattan/EntryInputPage.qml \
    qml/harmattan/EditEntrySheet.qml \
    qml/harmattan/AboutDialog.qml \
    qml/harmattan/ErrorDialog.qml \
    qml/desktop/main.qml \
    qml/desktop/PasswordInputPage.qml \
    qml/desktop/MainPage.qml \
    qml/desktop/Dialog.qml \
    qml/desktop/EditEntryDialog.qml \
    qml/desktop/ConfirmationDialog.qml \
    qml/desktop/Menu.qml \
    qml/desktop/AboutDialog.qml \
    qml/harmattan/ConfirmationDialog.qml \
    res/fremantle/meepasswords.desktop \
    res/fremantle/meepasswords.png \
    qml/desktop/CommonTextArea.qml \
    qml/desktop/CommonTextField.qml \
    qml/harmattan/CommonTextArea.qml \
    qml/harmattan/CommonTextField.qml \
    qml/desktop/CommonDialog.qml \
    qml/harmattan/CommonDialog.qml \
    qml/harmattan/CommonButton.qml \
    qml/desktop/CommonButton.qml \
    qml/common/constants.js \
    qml/harmattan/NfcWriteDialog.qml \
    qml/harmattan/EntryDelegate.qml \
    qml/desktop/EntryDelegate.qml \
    qml/harmattan/LabeledInput.qml \
    qml/harmattan/ShowEntryPage.qml \
    qml/harmattan/EntryLabel.qml \
    qml/harmattan/FastScroll.qml \
    qml/harmattan/FastScrollStyle.qml \
    qml/harmattan/FastScroll.js

# Please do not modify the following two lines. Required for deployment.
include(deployment.pri)
qtcAddDeployment()

splash.files = splash.png
splash.path = /opt/meepasswords
INSTALLS += splash

# enable booster
CONFIG += qdeclarative-boostable
QMAKE_CXXFLAGS += -fPIC -fvisibility=hidden -fvisibility-inlines-hidden
QMAKE_LFLAGS += -pie -rdynamic



