/*
 *  Copyright 2011 Ruediger Gad
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

#ifndef QCOMBOBOXQMLADAPTER_H
#define QCOMBOBOXQMLADAPTER_H

#include <QComboBox>
#include <QGraphicsProxyWidget>
#include <QObject>
#include <QStringList>

#include "entrylistmodel.h"

class CustomComboBox : public QComboBox {
    Q_OBJECT
public:
    explicit CustomComboBox(QWidget *parent = 0) : QComboBox(parent){}

protected:
    void focusInEvent(QFocusEvent *event){ QComboBox::focusInEvent(event); emit focusIn(); }
    void focusOutEvent(QFocusEvent *event){ QComboBox::focusOutEvent(event); emit focusOut(); }

signals:
    void focusIn();
    void focusOut();
};

class QComboBoxQmlAdapter : public QGraphicsProxyWidget
{
    Q_OBJECT
    Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)
public:
    explicit QComboBoxQmlAdapter(QGraphicsItem *parent = 0);
    ~QComboBoxQmlAdapter();

    void setText(const QString text) { m_comboBox->setEditText(text); }
    QString text() { return m_comboBox->currentText(); }

    Q_INVOKABLE void setItems(const QStringList &items);

signals:
    void focusIn();
    void focusOut();

    void textChanged(QString text);

private:
    CustomComboBox *m_comboBox;

};

#endif // QCOMBOBOXQMLADAPTER_H
