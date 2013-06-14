/*
 *  Copyright 2013 Ruediger Gad
 *
 *  This file is part of Q To-Do.
 *
 *  Q To-Do is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Q To-Do is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Q To-Do.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef IMAPACCOUNTLISTMODEL_H
#define IMAPACCOUNTLISTMODEL_H

#include <QObject>
#include <QSortFilterProxyModel>
#include <qmfclient/qmailaccountlistmodel.h>

class ImapAccountListModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount)
public:
    enum EntryRoles {
        AccountNameRole = Qt::UserRole + 1,
        AccountIdRole
    };

    explicit ImapAccountListModel(QObject *parent = 0);

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    Q_INVOKABLE void reload();
    Q_INVOKABLE int rowCount(const QModelIndex &parent = QModelIndex()) const;
    
signals:
    
public slots:

private:
    QMailAccountListModel *accountListModel;
    
};

#endif // IMAPACCOUNTLISTMODEL_H
