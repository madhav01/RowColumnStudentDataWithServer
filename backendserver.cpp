#include "backendserver.h"

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QJsonDocument>
#include <QUrl>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>
#include <utility>

BackendServer::BackendServer(QObject *parent)
    : QObject{parent}
{
    m_netManager = new QNetworkAccessManager(this);
    fetchStudentsFromServer();
}

void BackendServer::fetchStudentsFromServer()
{
    const QUrl url{
        "http://127.0.0.1:8080/students"
    };

    QNetworkRequest request{url};

    QNetworkReply *reply = m_netManager->get(request);

    connect(reply,&QNetworkReply::finished,this,[reply,this]{
        if(reply->error() != QNetworkReply::NoError){
            qWarning()<<"Network Error:"<<reply->errorString();
            emit errorOccurred(reply->errorString());
            reply->deleteLater();
            return;
        }
        //2.Read bytes and parse JSON Array
        QByteArray data = reply->readAll();
        QJsonDocument doc = QJsonDocument::fromJson(data);
        QJsonArray array = doc.array();

        //3.Poppulate m_students
        m_students.clear();
        for(const auto &val : std::as_const(array)){
            m_students.append(val.toObject().toVariantMap());
        }
        //Now notify QML that the list is ready!
        emit studentsChanged();

        //5.Automatically select the first student (if list not empty)
        if(!m_students.isEmpty()){
            selectStudent(m_students.first().toMap()["id"].toInt());
        }
        //6. Free network memory safely
        reply->deleteLater();
    });
}
void BackendServer::selectStudent(int studentId)
{
    //Search m_student for the student matching studentId
    for(const auto &item : std::as_const(m_students)){
        auto student = item.toMap();
        if(student["id"].toInt()==studentId){
            m_selectedStudent = student;
            emit selectedStudentChanged();
            break;
        }
    }
}