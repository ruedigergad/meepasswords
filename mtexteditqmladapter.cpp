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

#include "mtexteditqmladapter.h"

#include <meegotouch/mtexteditmodel.h>

MTextEditQmlAdapter::MTextEditQmlAdapter(QGraphicsItem *parent) :
    QGraphicsProxyWidget(parent)
{
    textEdit = new MTextEdit(MTextEditModel::SingleLine, "", this);
    setFlag(QGraphicsItem::ItemIsFocusable, true);
    setFocusPolicy(Qt::StrongFocus);
    setFocusProxy(textEdit);

    connect(this, SIGNAL(heightChanged()), this, SLOT(resizeTextEdit()));
    connect(this, SIGNAL(widthChanged()), this, SLOT(resizeTextEdit()));

    connect(textEdit, SIGNAL(textChanged()), this, SIGNAL(textChanged()));
}

MTextEditQmlAdapter::~MTextEditQmlAdapter(){
    delete textEdit;
}
