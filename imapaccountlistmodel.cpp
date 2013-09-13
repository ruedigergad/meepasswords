/*
 *  Copyright 2013 Ruediger Gad
 *
 *  This file is part of MeePasswords.
 *
 *  MeePasswords is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  MeePasswords is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with MeePasswords.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "imapaccountlistmodel.h"
#include <QSettings>

ImapAccountListModel::ImapAccountListModel(QObject *parent) :
    QSortFilterProxyModel(parent)
{
    accountListModel = new QMailAccountListModel();
    accountListModel->setSynchronizeEnabled(true);
    setSourceModel(accountListModel);

    m_roles[AccountNameRole] = "accountName";
    m_roles[AccountIdRole] = "accountId";
}

QVariant ImapAccountListModel::data(const QModelIndex &index, int role) const{
    if (index.row() < 0)
        return QVariant();

    QModelIndex sourceModelIndex = mapToSource(index);

    if(role == AccountNameRole) {
        qulonglong syncAccountid = QSettings().value("syncAccountId", -1).toULongLong();
        qulonglong currentAccountId = accountListModel->idFromIndex(sourceModelIndex).toULongLong();
        QString accountName = accountListModel->data(sourceModelIndex, QMailAccountListModel::NameTextRole).toString();
        if (currentAccountId == syncAccountid) {
            accountName += " *";
        }
        return accountName;
    } else if (role == AccountIdRole)
        return accountListModel->idFromIndex(sourceModelIndex).toULongLong();

    return QVariant();
}

int ImapAccountListModel::rowCount(const QModelIndex &parent) const{
    return accountListModel->rowCount(parent);
}
