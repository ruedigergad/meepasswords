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

#ifndef SETTINGSADAPTER_H
#define SETTINGSADAPTER_H

#include <QObject>
#include <QSettings>

class SettingsAdapter : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString fastScrollAnchor READ fastScrollAnchor WRITE setFastScrollAnchor NOTIFY fastScrollAnchorChanged)
    Q_PROPERTY(bool clickToOpen READ clickToOpen WRITE setClickToOpen NOTIFY clickToOpenChanged)
    Q_PROPERTY(int fontSize READ getFontSize WRITE setFontSize NOTIFY fontSizeChanged)

public:
    explicit SettingsAdapter(QObject *parent = 0);
    
    bool clickToOpen();
    QString fastScrollAnchor();
    int getFontSize();

    void setClickToOpen(bool val);
    void setFastScrollAnchor(QString anchor);
    void setFontSize(int fontSize);

signals:
    void fastScrollAnchorChanged(QString anchor);
    void clickToOpenChanged(bool val);
    void fontSizeChanged(int fontSize);
    
public slots:
    
private:
    bool m_clickToOpen;
    QString m_fastScrollAnchor;
    int m_fontSize;

};

#endif // SETTINGSADAPTER_H
