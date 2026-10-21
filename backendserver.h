#ifndef BACKENDSERVER_H
#define BACKENDSERVER_H

#include <QObject>
#include <QQmlEngine>
#include <QVariant>
#include <QVariantMap>
#include <QString>

class QNetworkAccessManager;
class BackendServer : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    //Expose student data to QML
    Q_PROPERTY(QVariantList students READ students NOTIFY studentsChanged FINAL)
    Q_PROPERTY(QVariantMap selectedStudent READ selectedStudent NOTIFY selectedStudentChanged FINAL)
    Q_PROPERTY(QVariantList changelogs READ changelogs NOTIFY changelogsChanged FINAL)
public:
    explicit BackendServer(QObject *parent = nullptr);

    //Getters
    QVariantList students()const{return m_students;}
    QVariantMap selectedStudent()const {return m_selectedStudent;}
    QVariantList changelogs() const {return m_changelogs;}

    //Action called by QML when user interacts
    Q_INVOKABLE void selectStudent(int studentId);

signals:
    void studentsChanged();
    void selectedStudentChanged();
    void changelogsChanged();
private:
    // Network Manager instance
    QNetworkAccessManager *m_netManager = nullptr;

    QVariantList m_students;
    QVariantMap m_selectedStudent;
    QVariantList m_changelogs;

    // 👈 Add these two private helper functions:
    void fetchStudentsFromServer();
    void fetchChangelogs(int studentId);
};

#endif // BACKENDSERVER_H
