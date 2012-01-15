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

#ifndef MCOMBOBOXQMLADAPTER_H
#define MCOMBOBOXQMLADAPTER_H

#include <QObject>
#include <QtGui/QGraphicsProxyWidget>

#include <meegotouch/MComboBox>

class MComboBoxQmlAdapter : public QGraphicsProxyWidget
{
    Q_OBJECT
    Q_PROPERTY(qreal height READ height WRITE setHeight NOTIFY heightChanged)
    Q_PROPERTY(qreal width READ width WRITE setWidth NOTIFY widthChanged)
public:
    explicit MComboBoxQmlAdapter(QGraphicsItem *parent = 0);
    ~MComboBoxQmlAdapter();

    void setHeight(qreal height){
        if(preferredHeight() != height){
            setPreferredHeight(height);
            adjustSize();
            emit heightChanged();
        }
    }
    qreal height(){ return preferredHeight(); }

    void setWidth(qreal width){
        if(preferredWidth() != width){
            setPreferredWidth(width);
            adjustSize();
            emit widthChanged();
        }
    }
    qreal width(){ return preferredWidth(); }

    Q_INVOKABLE void focus(){ m_comboBox->click(); }

signals:
    void heightChanged();
    void widthChanged();

public slots:
    void resizeComboBox(){ m_comboBox->resize(size()); }
    void test();

private:
    MComboBox *m_comboBox;


};

#endif // MCOMBOBOXQMLADAPTER_H
