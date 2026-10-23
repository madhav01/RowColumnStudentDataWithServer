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
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged FINAL)
    Q_PROPERTY(bool hasError READ hasError NOTIFY hasErrorChanged FINAL)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged FINAL)
    Q_PROPERTY(int statusCode READ statusCode NOTIFY statusCodeChanged FINAL)
public:
    explicit BackendServer(QObject *parent = nullptr);

    //Getters
    QVariantList students()const{return m_students;}
    QVariantMap selectedStudent()const {return m_selectedStudent;}
    QVariantList changelogs() const {return m_changelogs;}
    bool isLoading() const { return m_isLoading; }
    bool hasError() const { return m_hasError; }
    QString errorMessage() const { return m_errorMessage; }
    int statusCode() const { return m_statusCode; }

    //Action called by QML when user interacts
    Q_INVOKABLE void selectStudent(int studentId);
    Q_INVOKABLE void fetchStudentsFromServer();

signals:
    void studentsChanged();
    void selectedStudentChanged();
    void changelogsChanged();
    void isLoadingChanged();
    void hasErrorChanged();
    void errorMessageChanged();
    void statusCodeChanged();
    void errorOccurred(const QString &errorMessage);
private:
    // Network Manager instance
    QNetworkAccessManager *m_netManager = nullptr;

    QVariantList m_students;
    QVariantMap m_selectedStudent;
    QVariantList m_changelogs;
    bool m_isLoading = false;
    bool m_hasError = false;
    QString m_errorMessage;
    int m_statusCode = 0;

    // 👈 Helper functions
    void fetchChangelogs(int studentId);
};

#endif // BACKENDSERVER_H
