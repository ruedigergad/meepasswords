#include "signonadapter.h"


SignOnAdapter::SignOnAdapter(QObject *parent) :
    QObject(parent)
{
    identity = NULL;
    identityInfo = NULL;

    authService = new SignOn::AuthService();
    connect(authService, SIGNAL(error(SignOn::Error)), this, SLOT(authServiceError(SignOn::Error)));
}

SignOnAdapter::~SignOnAdapter(){
    delete authService;

    if(identity != NULL){
        delete identity;
    }
    if(identityInfo != NULL){
        delete identityInfo;
    }
}

void SignOnAdapter::authenticate(){

}

void SignOnAdapter::createIdentity(QString password){
    identityInfo = new SignOn::IdentityInfo();

    identityInfo->setCaption(QString(MEEPASSWORDS_CAPTION));
    identityInfo->setRealms(QStringList(QString(MEEPASSWORDS_REALM)));
    identityInfo->setUserName(QString(MEEPASSWORDS_USERNAME));
    identityInfo->setSecret(password, true);

    qDebug("Creating identity.");
    identity = SignOn::Identity::newIdentity(*identityInfo);

    connect(identity, SIGNAL(credentialsStored(quint32)), this, SLOT(credentialsStoreSuccess(quint32)));
    qDebug("Storing credentials.");
    identity->storeCredentials(*identityInfo);
}

void SignOnAdapter::loadIdentity(){
    SignOn::AuthService::IdentityFilter filter;

    filter.insert(SignOn::AuthService::Username, SignOn::AuthService::IdentityRegExp(MEEPASSWORDS_USERNAME));
    filter.insert(SignOn::AuthService::Caption, SignOn::AuthService::IdentityRegExp(MEEPASSWORDS_CAPTION));
    filter.insert(SignOn::AuthService::Realm, SignOn::AuthService::IdentityRegExp(MEEPASSWORDS_REALM));

    connect(authService, SIGNAL(identities(QList<SignOn::IdentityInfo>)), this, SLOT(identityQuerySuccess(QList<SignOn::IdentityInfo>)));

    authService->queryIdentities(filter);
}

void SignOnAdapter::authServiceError(const SignOn::Error &err){
    qDebug("AuthService Error: %d", err.type());
    emit identityLoaded();
}

void SignOnAdapter::credentialsStoreSuccess(quint32 id){
    qDebug("Credentials successfully stored: %d", id);
}

void SignOnAdapter::identityQuerySuccess(const QList<SignOn::IdentityInfo> &identityList){
    if(identityList.size() == 1){
        identityInfo = new SignOn::IdentityInfo(identityList.at(0));
        identity = SignOn::Identity::existingIdentity(identityInfo->id());
        emit identityLoaded();
    }else{
        qDebug("%d", identityList.size());
        emit identityNotFound(SignOn::Error::IdentityNotFound);
    }
}

