#ifndef ENTRYSORTFILTERPROXYMODEL_H
#define ENTRYSORTFILTERPROXYMODEL_H

#include <QSortFilterProxyModel>
#include <QStringList>

#include "entrylistmodel.h"

class EntrySortFilterProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
    // Needed to make SectionScroller happy.
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    explicit EntrySortFilterProxyModel(QObject *parent = 0);

    Q_INVOKABLE QStringList getItemNames() const;
    Q_INVOKABLE void addOrUpdateEntry(QString name, QString category, QString userName, QString password, QString notes, int id);
    Q_INVOKABLE void clear();
    Q_INVOKABLE QStringList deletedUuids();
    Q_INVOKABLE void removeAt(int index);
    Q_INVOKABLE void removeById(int id);
    Q_INVOKABLE void removeByUuid(int uuid);

    // Needed to make SectionScroller happy.
    Q_INVOKABLE Entry* get(int index);
    Q_INVOKABLE int rowCount(const QModelIndex &parent = QModelIndex()) const {
        return ((EntryListModel*)sourceModel())->rowCount(parent);
    }

signals:
    void countChanged(int count);

protected:
    bool lessThan(const QModelIndex &left, const QModelIndex &right) const;

public slots:
    //void sortByDate();
    //void sortByTitle();

};


#endif // ENTRYSORTFILTERPROXYMODEL_H
