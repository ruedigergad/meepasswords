#ifndef STORAGE_H
#define STORAGE_H

#include <QObject>
#include <aegis_storage.h>

class Storage : public QObject
{
    Q_OBJECT
public:
    explicit Storage(QObject *parent = 0);

signals:

public slots:

private:
    aegis::storage *aegisStorage;

};

#endif // STORAGE_H
