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
    if (m_isLoading) {
        return;
    }

    m_isLoading = true;
    emit isLoadingChanged();

    m_hasError = false;
    emit hasErrorChanged();

    m_errorMessage.clear();
    emit errorMessageChanged();

    m_statusCode = 0;
    emit statusCodeChanged();

    const QUrl url{
        "http://127.0.0.1:8080/students"
    };

    QNetworkRequest request{url};

    QNetworkReply *reply = m_netManager->get(request);

    connect(reply, &QNetworkReply::finished, this, [reply, this]{
        m_isLoading = false;
        emit isLoadingChanged();

        int httpStatus = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        m_statusCode = httpStatus;
        emit statusCodeChanged();

        if (reply->error() != QNetworkReply::NoError) {
            m_hasError = true;
            emit hasErrorChanged();

            QString errorDesc;
            if (httpStatus > 0) {
                errorDesc = QString("HTTP %1: %2").arg(httpStatus).arg(reply->errorString());
            } else {
                errorDesc = QString("Server is not active (%1)").arg(reply->errorString());
            }

            m_errorMessage = errorDesc;
            emit errorMessageChanged();

            qWarning() << "Network Error:" << errorDesc;
            emit errorOccurred(errorDesc);

            m_students.clear();
            emit studentsChanged();
            m_selectedStudent.clear();
            emit selectedStudentChanged();

            reply->deleteLater();
            return;
        }

        // 2. Read bytes and parse JSON Array
        QByteArray data = reply->readAll();
        QJsonParseError parseError;
        QJsonDocument doc = QJsonDocument::fromJson(data, &parseError);

        if (parseError.error != QJsonParseError::NoError || !doc.isArray()) {
            m_hasError = true;
            emit hasErrorChanged();

            QString errorDesc = (parseError.error != QJsonParseError::NoError)
                ? QString("JSON parse error: %1").arg(parseError.errorString())
                : QString("Invalid response format: Expected JSON array of students");

            m_errorMessage = errorDesc;
            emit errorMessageChanged();

            qWarning() << "Data Error:" << errorDesc;
            emit errorOccurred(errorDesc);

            m_students.clear();
            emit studentsChanged();
            m_selectedStudent.clear();
            emit selectedStudentChanged();

            reply->deleteLater();
            return;
        }

        QJsonArray array = doc.array();

        // 3. Populate m_students
        m_students.clear();
        for (const auto &val : std::as_const(array)) {
            m_students.append(val.toObject().toVariantMap());
        }
        // Now notify QML that the list is ready!
        emit studentsChanged();

        // 5. Automatically select the first student (if list not empty)
        if (!m_students.isEmpty()) {
            selectStudent(m_students.first().toMap()["id"].toInt());
        } else {
            m_selectedStudent.clear();
            emit selectedStudentChanged();
        }

        // 6. Free network memory safely
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