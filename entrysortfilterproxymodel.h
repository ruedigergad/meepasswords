#ifndef ENTRYSORTFILTERPROXYMODEL_H
#define ENTRYSORTFILTERPROXYMODEL_H

#include <QSortFilterProxyModel>
#include <QStringList>

class EntrySortFilterProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
public:
    explicit EntrySortFilterProxyModel(QObject *parent = 0);

    Q_INVOKABLE QStringList getItemNames() const;
    Q_INVOKABLE void addOrUpdateEntry(QString name, QString category, QString userName, QString password, QString notes, int id);
    Q_INVOKABLE void clear();
    Q_INVOKABLE void removeById(int id);


protected:
    bool lessThan(const QModelIndex &left, const QModelIndex &right) const;

public slots:
    //void sortByDate();
    //void sortByTitle();

};


#endif // ENTRYSORTFILTERPROXYMODEL_H
