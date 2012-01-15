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

#ifndef MTEXTEDITQMLADAPTER_H
#define MTEXTEDITQMLADAPTER_H

#include <QObject>
#include <QtGui/QGraphicsProxyWidget>

#include <meegotouch/MTextEdit>

class MTextEditQmlAdapter : public QGraphicsProxyWidget
{
    Q_OBJECT
    Q_PROPERTY(qreal height READ height WRITE setHeight NOTIFY heightChanged)
    Q_PROPERTY(qreal width READ width WRITE setWidth NOTIFY widthChanged)
    Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)

public:
    explicit MTextEditQmlAdapter(QGraphicsItem *parent = 0);
    ~MTextEditQmlAdapter();

    void setText(QString text){
        if(text != textEdit->text()){
            textEdit->setText(text);
        }
    }
    QString text(){ return textEdit->text(); }

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

    Q_INVOKABLE void focus(){ setFocus(); }

signals:
    void textChanged();

    void heightChanged();
    void widthChanged();

public slots:

private slots:
    void resizeTextEdit(){ textEdit->resize(size()); }

private:
    MTextEdit *textEdit;

};

#endif // MTEXTEDITQMLADAPTER_H
