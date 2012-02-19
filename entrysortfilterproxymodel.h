#ifndef ENTRYSORTFILTERPROXYMODEL_H
#define ENTRYSORTFILTERPROXYMODEL_H

#include <QSortFilterProxyModel>
#include <QStringList>

#include "entrylistmodel.h"

class EntrySortFilterProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
    // Needed to make SectionScroller happy.
    Q_PROPERTY(int count READ rowCount)

public:
    explicit EntrySortFilterProxyModel(QObject *parent = 0);

    Q_INVOKABLE QStringList getItemNames() const;
    Q_INVOKABLE void addOrUpdateEntry(QString name, QString category, QString userName, QString password, QString notes, int id);
    Q_INVOKABLE void clear();
    Q_INVOKABLE void removeById(int id);

    // Needed to make SectionScroller happy.
    Q_INVOKABLE Entry* get(int index) { return ((EntryListModel*)sourceModel())->get(index); }
    Q_INVOKABLE int rowCount(const QModelIndex &parent = QModelIndex()) const {
        return ((EntryListModel*)sourceModel())->rowCount(parent);
    }

protected:
    bool lessThan(const QModelIndex &left, const QModelIndex &right) const;

public slots:
    //void sortByDate();
    //void sortByTitle();

};


#endif // ENTRYSORTFILTERPROXYMODEL_H
