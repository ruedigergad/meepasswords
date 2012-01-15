#ifndef SIGNONADAPTER_H
#define SIGNONADAPTER_H

#include <QObject>
#include <signon-qt/SignOn/authservice.h>
#include <signon-qt/SignOn/identity.h>
#include <signon-qt/SignOn/identityinfo.h>

#define MEEPASSWORDS_CAPTION "Identity used by MeePasswords to identify the owner of the store."
#define MEEPASSWORDS_REALM "MeePasswords"
#define MEEPASSWORDS_USERNAME "MeePasswordsUserName"

/**
  * Adapter to access SignOn functionality via QML.
  */
class SignOnAdapter : public QObject
{
    Q_OBJECT
public:
    explicit SignOnAdapter(QObject *parent = 0);
    ~SignOnAdapter();

public slots:
    /**
      * Authenticate user. On successful authentication authSuccess is emitted,
      * authError is emitted otherwise.
      */
    void authenticate();
    /**
      * Create a new Identity. On success identityCreated is emitted,
      * identityCreationError is emitted otherwise.
      */
    void createIdentity(QString password);
    /**
      * Tries to load an existing Idenity. On success identityLoaded is emitted,
      * identityNotFound is emitted otherwise.
      */
    void loadIdentity();

signals:
    void authError();
    void authSuccess();

    void identityCreated();
    void identityCreationError();
    void identityLoaded();
    void identityNotFound(const SignOn::Error &err);

private slots:
    void authServiceError(const SignOn::Error &err);
    void credentialsStoreSuccess(quint32 id);
    void identityQuerySuccess(const QList<SignOn::IdentityInfo > &identityList);

private:
    SignOn::AuthService *authService;
    SignOn::Identity *identity;
    SignOn::IdentityInfo *identityInfo;

};

#endif // SIGNONADAPTER_H
