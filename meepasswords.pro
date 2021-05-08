# Add more folders to ship with the application, here

android: {
    message(Android build with Qt version: $$QT_VERSION)
    TEMPLATE = app

    QT += concurrent qml quick widgets xml

    DEFINES += QT5_BUILD
    DEFINES += ANDROID

    INCLUDEPATH += \
        lib/qt5/include \
        lib/qt5/include/QtCrypto

    LIBS += \
        -L$$PWD/lib/qt5/build/android/android-24/qca \
        -l:libqca-qt5_armeabi-v7a.so \
        -L$$PWD/lib/qt5/build/android/android-24/openssl \
        -l:libcrypto.so \
        -l:libssl.so

    HEADERS += \
        entry.h \
        entrylistmodel.h \
        entrystorage.h \
        keepassxmlstreamreader.h \
        keepassxmlstreamwriter.h \
        qmlclipboardadapter.h \
        entrysortfilterproxymodel.h \
        settingsadapter.h

    SOURCES += \
        entry.cpp \
        entrylistmodel.cpp \
        entrystorage.cpp \
        keepassxmlstreamreader.cpp \
        keepassxmlstreamwriter.cpp \
        entrysortfilterproxymodel.cpp \
        settingsadapter.cpp \
        main-qt5.cpp

    RESOURCES += qtquick2_android.qrc

    # Additional import path used to resolve QML modules in Qt Creator's code model
    QML_IMPORT_PATH =

    # Default rules for deployment.
    x86 {
        target.path = /libs/x86
    } else: armeabi-v7a {
        target.path = /libs/armeabi-v7a
    } else {
        target.path = /libs/armeabi
    }
    export(target.path)

    # This does not work. Likeley because of:
    # https://forum.qt.io/topic/108470/installs-ignores-res-folder/6
    qca-ossl.files = \
        $$PWD/lib/qt5/build/android/android-24/qca/qca-qt5/crypto/libqca-ossl_armeabi-v7a.so
    qca-ossl.path = /libs/armeabi-v7a/crypto

    INSTALLS += target qca-ossl
    export(INSTALLS)

    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

    OTHER_FILES += \
        android/AndroidManifest.xml

    DISTFILES += \
        android/AndroidManifest.xml \
        android/build.gradle \
        android/build.gradle \
        android/gradle/wrapper/gradle-wrapper.jar \
        android/gradle/wrapper/gradle-wrapper.jar \
        android/gradle/wrapper/gradle-wrapper.properties \
        android/gradle/wrapper/gradle-wrapper.properties \
        android/gradlew \
        android/gradlew \
        android/gradlew.bat \
        android/gradlew.bat \
        android/res/values/libs.xml

    ANDROID_ABIS = armeabi-v7a

    ANDROID_EXTRA_LIBS = $$PWD/lib/qt5/build/android/android-24/openssl/libcrypto.so $$PWD/lib/qt5/build/android/android-24/openssl/libssl.so $$PWD/lib/qt5/build/android/android-24/qca/libqca-qt5_armeabi-v7a.so $$PWD/lib/qt5/build/android/android-24/qca/qca-qt5/crypto/libqca-ossl_armeabi-v7a.so
} else {
    message(Building with Qt version: $$QT_VERSION)

    isEqual(QT_MAJOR_VERSION, 5) {
        message(Qt5 Build)

        DEFINES += QT5_BUILD

        QT += qml quick

        RESOURCES += qtquick2_common.qrc
    } else {
        RESOURCES += common.qrc
    }

    exists("/usr/lib/qt5/qml/Sailfish/Silica/SilicaGridView.qml"): {
        message(SailfishOS build)

        TARGET = harbour-meepasswords

        DEFINES += QDECLARATIVE_BOOSTER
        DEFINES += MER_EDITION_SAILFISH
        DEFINES += SYNC_TO_IMAP_SUPPORT
        MER_EDITION = sailfish

        QT += widgets
        RESOURCES += qtquick2_sailfish.qrc
        CONFIG += crypto

        CONFIG += sailfishapp

        CONFIG += link_pkgconfig
        PKGCONFIG += qmfclient5 sailfishapp

        QMAKE_LFLAGS += '-Wl,-rpath,/usr/share/harbour-meepasswords/qca/lib'

        sailfishQcaLib.files = lib_sailfish/qca/lib/libqca-qt5.so.2
        sailfishQcaLib.path = /usr/share/harbour-meepasswords/qca/lib
        sailfishQcaPlugins.files = lib_sailfish/qca/plugins/libqca-ossl.so lib_sailfish/qca/plugins/libqca-logger.so lib_sailfish/qca/plugins/libqca-softstore.so
        sailfishQcaPlugins.path = /usr/share/harbour-meepasswords/qca/plugins/qca-qt5
        INSTALLS += sailfishQcaLib sailfishQcaPlugins
    } else:exists($$QMAKE_INCDIR_QT"/../applauncherd/MDeclarativeCache"): {
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

        DEFINES += WINDOWS_DESKTOP
        DEFINES += _UNICODE

    #    CONFIG += console

        INCLUDEPATH += \
            lib/include \
            lib/include/QtCrypto

        LIBS += \
            -Llib/build/windows/x86 \
            -lqca2
#            -lqmfclient \

        RC_FILE = qtc_packaging/windows/meepasswords.rc

        RESOURCES += desktop.qrc
    } else {
        message(Linux Desktop Build)
        DEFINES += LINUX_DESKTOP QT5_BUILD
        RESOURCES += desktop.qrc
        QT += opengl

        HEADERS += envvarhelper.h
        SOURCES += envvarhelper.cpp

        # TODO: Dynamically determine architecture.
        arch = x86_64
        os = linux

        INCLUDEPATH += \
            lib/qt5/include \
            lib/qt5/include/QtCrypto

        LIBS += \
            -L$$PWD/lib/qt5/build/linux/x86_64/qca \
            -lqca-qt5
#            -L$$PWD/synctoimap/lib/build/linux/x86_64/qmf/lib \
#            -lqmfclient5
        QMAKE_LFLAGS += '-Wl,-rpath,\'\$$ORIGIN/lib/qca\''
#        QMAKE_LFLAGS += '-Wl,-rpath,\'\$$ORIGIN/lib/qca:\$$ORIGIN/lib/qmf/lib\''

        QT += qml quick

        RESOURCES += \
            qtquick2_desktop.qrc

        desktopQcaLibs.source = lib/qt5/build/linux/x86_64/qca
        desktopQcaLibs.target = lib
#        desktopQmfLibs.source = synctoimap/lib/build/linux/x86_64/qmf
#        desktopQmfLibs.target = lib
        DEPLOYMENTFOLDERS += desktopQcaLibs
    }

    contains(DEFINES, SYNC_TO_IMAP_SUPPORT): {
        message(Building sync support...)
        HEADERS += \
            synctoimap/src/envvarhelper.h \
            synctoimap/src/filehelper.h \
            synctoimap/src/imapstorage.h \
            synctoimap/src/imapaccountlistmodel.h \
            synctoimap/src/imapaccounthelper.h \
            synctoimap/src/synctoimap.h
        INCLUDEPATH += \
            synctoimap/src \
            synctoimap/lib/include
        SOURCES += \
            synctoimap/src/envvarhelper.cpp \
            synctoimap/src/filehelper.cpp \
            synctoimap/src/imapstorage.cpp \
            synctoimap/src/imapaccountlistmodel.cpp \
            synctoimap/src/imapaccounthelper.cpp \
            synctoimap/src/synctoimap.cpp
        contains(DEFINES, QT5_BUILD) {
            RESOURCES += qtquick2_synctoimap.qrc
        } else {
            RESOURCES += synctoimap.qrc
        }
    }

    # Additional import path used to resolve QML modules in Creator's code model
    QML_IMPORT_PATH =

    #QT+= declarative
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
        settingsadapter.h

    # The .cpp file which was generated for your project. Feel free to hack it.

    SOURCES += \
        entry.cpp \
        entrystorage.cpp \
        entrylistmodel.cpp \
        keepassxmlstreamreader.cpp \
        keepassxmlstreamwriter.cpp \
        entrysortfilterproxymodel.cpp \
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
        rpm/harbour-meepasswords.spec \
        rpm/harbour-meepasswords.yaml \
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
        qml/qtquick2/common/constants.js \
        qml/qtquick2/common/EntryDelegate.qml \
        qml/qtquick2/common/EntryListView.qml \
        qml/qtquick2/common/MainFlickable.qml \
        qml/qtquick2/common/MessageDialog.qml \
        qml/qtquick2/common/MeePasswordsToolBar.qml \
        qml/qtquick2/common/PasswordChangeDialog.qml \
        qml/qtquick2/common/FastScroll.qml \
        qml/qtquick2/common/FastScrollStyle.qml \
        qml/qtquick2/common/FastScroll.js \
        qml/qtquick2/common/PasswordInputRectangle.qml \
        qml/qtquick2/common/EditEntryRectangle.qml \
        qml/qtquick2/common/AboutDialog.qml \
        qml/qtquick2/common/Menu.qml \
        qml/qtquick2/common/TextInputDialog.qml \
        qml/qtquick2/common/SelectionDialog.qml \
        qml/qtquick2/common/ImapAccountSettingsSheet.qml \
        qml/qtquick2/common/ProgressDialog.qml \
        qml/qtquick2/common/Merger.qml \
        qml/qtquick2/common/EntryListViewRectangle.qml \
        qml/qtquick2/android/main.qml \
        qml/qtquick2/android/common/MainFlickable.qml \
        qml/qtquick2/desktop/main.qml \
        qml/qtquick2/desktop/common/Dialog.qml \
        qml/qtquick2/desktop/common/CommonDialog.qml \
        qml/qtquick2/desktop/common/CommonButton.qml \
        qml/qtquick2/desktop/common/CommonToolBar.qml \
        qml/qtquick2/desktop/common/ConfirmationDialog.qml \
        qml/qtquick2/desktop/common/CommonEntryListView.qml \
        qml/qtquick2/desktop/common/CommonToolIcon.qml \
        qml/qtquick2/desktop/common/CommonTextField.qml \
        qml/qtquick2/desktop/common/CommonTextArea.qml \
        qml/qtquick2/sailfish/main.qml \
        qml/qtquick2/sailfish/common/Dialog.qml \
        qml/qtquick2/sailfish/common/CommonDialog.qml \
        qml/qtquick2/sailfish/common/CommonButton.qml \
        qml/qtquick2/sailfish/common/CommonToolBar.qml \
        qml/qtquick2/sailfish/common/ConfirmationDialog.qml \
        qml/qtquick2/sailfish/common/CommonToolIcon.qml \
        qml/qtquick2/sailfish/common/CommonTextField.qml \
        qml/qtquick2/sailfish/common/CommonTextArea.qml \
        synctoimap/qml/synctoimap/SyncToImapBase.qml \
        synctoimap/qml/synctoimap/SyncDirToImap.qml \
        synctoimap/qml/synctoimpa/SyncFileToImap.qml \
        synctoimap/qml/synctoimap/SyncMessageDeleter.qml \
        qml/qtquick2/sailfish/common/CommonEntryListView.qml \
        qml/qtquick2/desktop/common/CommonEntryDelegate.qml \
        qml/qtquick2/sailfish/common/CommonEntryDelegate.qml \
        qml/qtquick2/desktop/common/CommonPlaceHolder.qml \
        qml/qtquick2/sailfish/common/CommonPlaceHolder.qml



    # Please do not modify the following two lines. Required for deployment.
    include(deployment.pri)
    qtcAddDeployment()

    contains(DEFINES, MER_EDITION_SAILFISH) {
        RESOURCES += \
            qtquick2_sailfish.qrc
    } else {
        splash.files = splash.png
        splash.path = /opt/meepasswords
        INSTALLS += splash
    }

    contains(DEFINES, QDECLARATIVE_BOOSTER): {
        message(Enabling qdeclarative booster.)
        CONFIG += qdeclarative-boostable
        QMAKE_CXXFLAGS += -fPIC -fvisibility=hidden -fvisibility-inlines-hidden
        QMAKE_LFLAGS += -pie -rdynamic
    }
}
