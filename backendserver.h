#ifndef BACKENDSERVER_H
#define BACKENDSERVER_H

#include <QObject>
#include <QQmlEngine>

class BackendServer : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit BackendServer(QObject *parent = nullptr);

signals:
};

#endif // BACKENDSERVER_H
