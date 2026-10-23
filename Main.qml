import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import RowColumnStudentDataWithServer

ApplicationWindow {
    id: window
    width: 640
    height: 480
    minimumWidth: 200
    minimumHeight: 250
    visible: true
    title: qsTr("Server Data Test")
    visibility: Window.Maximized

    BackendServer{
        id: serverData
        onErrorOccurred: (errorMessage) => {
            console.warn("Backend error occurred:", errorMessage)
        }
    }
    Row{
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        //===============================================================
        //Left Half: Student List (a Column holding each student row item
        //or showing status/warning/loading states)
        //===============================================================
        Column{
            width: parent.width * 0.55
            height: parent.height
            spacing: 10

            //Title Label + Refresh Button
            Row {
                width: parent.width - 14
                height: 24
                spacing: 8

                Text{
                    text: "📋 Active Students List (Row Positioners)"
                    font.bold: true
                    font.pixelSize: 14
                    color: "#171717"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item {
                    width: 1
                    height: 1
                    Layout.fillWidth: true
                }

                // Header Refresh Button
                Rectangle {
                    width: 26
                    height: 26
                    radius: 13
                    color: headerRefreshArea.containsMouse ? "#e2e8f0" : "transparent"
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "⟳"
                        font.bold: true
                        font.pixelSize: 16
                        color: serverData.isLoading ? "#94a3b8" : "#334155"
                    }

                    MouseArea {
                        id: headerRefreshArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        enabled: !serverData.isLoading
                        onClicked: serverData.fetchStudentsFromServer()
                    }
                }
            }

            // Main Content Area
            Item {
                width: parent.width
                height: parent.height - 34

                // -----------------------------------------------------------
                // 1. Loading State
                // -----------------------------------------------------------
                Rectangle {
                    anchors.fill: parent
                    anchors.rightMargin: 14
                    radius: 10
                    color: "#0f172a"
                    border.color: "#334155"
                    border.width: 1
                    visible: serverData.isLoading

                    Column {
                        anchors.centerIn: parent
                        spacing: 12

                        BusyIndicator {
                            anchors.horizontalCenter: parent.horizontalCenter
                            running: serverData.isLoading
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Connecting to server..."
                            font.bold: true
                            font.pixelSize: 14
                            color: "#f8fafc"
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "GET http://127.0.0.1:8080/students"
                            font.pixelSize: 11
                            color: "#64748b"
                        }
                    }
                }

                // -----------------------------------------------------------
                // 2. Warning / Error State (Server Inactive or HTTP Error e.g. 404)
                // -----------------------------------------------------------
                Rectangle {
                    anchors.fill: parent
                    anchors.rightMargin: 14
                    radius: 10
                    color: "#0f172a"
                    border.color: (serverData.statusCode === 404) ? "#f43f5e" : "#f59e0b"
                    border.width: 1.5
                    visible: !serverData.isLoading && serverData.hasError

                    Column {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 16

                        // Header with Icon & Status Tag
                        Row {
                            spacing: 12
                            width: parent.width

                            // Icon Circle
                            Rectangle {
                                width: 44
                                height: 44
                                radius: 22
                                color: (serverData.statusCode === 404) ? "#881337" : "#451a03"
                                border.color: (serverData.statusCode === 404) ? "#f43f5e" : "#f59e0b"
                                border.width: 1
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: (serverData.statusCode === 404) ? "✕" : "⚠️"
                                    font.pixelSize: 20
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 4

                                Row {
                                    spacing: 8

                                    Text {
                                        text: (serverData.statusCode === 404)
                                              ? "404 Not Found"
                                              : (serverData.statusCode > 0
                                                 ? ("HTTP Error: " + serverData.statusCode)
                                                 : "Server Is Not Active")
                                        font.bold: true
                                        font.pixelSize: 16
                                        color: "#f8fafc"
                                    }

                                    // Badge
                                    Rectangle {
                                        height: 20
                                        width: statusTagText.implicitWidth + 12
                                        radius: 4
                                        color: (serverData.statusCode === 404) ? "#e11d48" : (serverData.statusCode > 0 ? "#dc2626" : "#d97706")
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            id: statusTagText
                                            anchors.centerIn: parent
                                            text: (serverData.statusCode > 0)
                                                  ? ("HTTP " + serverData.statusCode)
                                                  : "Offline"
                                            font.pixelSize: 10
                                            font.bold: true
                                            color: "#ffffff"
                                        }
                                    }
                                }

                                Text {
                                    text: (serverData.statusCode === 404)
                                          ? "The requested endpoint '/students' was not found on this server."
                                          : (serverData.statusCode > 0
                                             ? "The backend server returned an error response."
                                             : "Could not connect to the Drogon backend server.")
                                    font.pixelSize: 11
                                    color: "#94a3b8"
                                }
                            }
                        }

                        // Diagnostic Box
                        Rectangle {
                            width: parent.width
                            height: errorDetailCol.implicitHeight + 18
                            radius: 8
                            color: "#1e293b"
                            border.color: "#334155"
                            border.width: 1

                            Column {
                                id: errorDetailCol
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 6

                                Text {
                                    text: "Diagnostic Details:"
                                    font.bold: true
                                    font.pixelSize: 11
                                    color: "#e2e8f0"
                                }

                                Text {
                                    width: parent.width
                                    text: serverData.errorMessage || "Network connection failed."
                                    font.pixelSize: 11
                                    color: "#fca5a5"
                                    wrapMode: Text.WrapAnywhere
                                }

                                Text {
                                    width: parent.width
                                    text: (serverData.statusCode === 0)
                                          ? "💡 Troubleshooting: Please start your backend server (e.g. Drogon C++ on port 8080) and click 'Retry Connection'."
                                          : (serverData.statusCode === 404
                                             ? "💡 Troubleshooting: Verify that the route 'http://127.0.0.1:8080/students' is registered in your server."
                                             : "💡 Troubleshooting: Check your backend server logs for details.")
                                    font.pixelSize: 10
                                    color: "#94a3b8"
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }

                        // Retry Action Button
                        Rectangle {
                            width: 150
                            height: 36
                            radius: 6
                            color: retryMouse.containsMouse ? "#0284c7" : "#0ea5e9"

                            Row {
                                anchors.centerIn: parent
                                spacing: 8

                                Text {
                                    text: "⟳"
                                    font.bold: true
                                    font.pixelSize: 14
                                    color: "#ffffff"
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: "Retry Connection"
                                    font.bold: true
                                    font.pixelSize: 12
                                    color: "#ffffff"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: retryMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: serverData.fetchStudentsFromServer()
                            }
                        }
                    }
                }

                // -----------------------------------------------------------
                // 3. No Data Available State (Server active, but array is empty)
                // -----------------------------------------------------------
                Rectangle {
                    anchors.fill: parent
                    anchors.rightMargin: 14
                    radius: 10
                    color: "#0f172a"
                    border.color: "#334155"
                    border.width: 1
                    visible: !serverData.isLoading && !serverData.hasError && (serverData.students.length === 0)

                    Column {
                        anchors.centerIn: parent
                        spacing: 12
                        width: parent.width - 40

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "📭"
                            font.pixelSize: 32
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "No Student Data Available"
                            font.bold: true
                            font.pixelSize: 15
                            color: "#f8fafc"
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "The server is active and reachable, but returned 0 student records."
                            font.pixelSize: 12
                            color: "#94a3b8"
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }

                        Rectangle {
                            width: 120
                            height: 34
                            radius: 6
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: emptyRefreshMouse.containsMouse ? "#334155" : "#1e293b"
                            border.color: "#475569"

                            Text {
                                anchors.centerIn: parent
                                text: "⟳ Refresh"
                                font.bold: true
                                font.pixelSize: 12
                                color: "#f8fafc"
                            }

                            MouseArea {
                                id: emptyRefreshMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: serverData.fetchStudentsFromServer()
                            }
                        }
                    }
                }

                // -----------------------------------------------------------
                // 4. Data Available State (Populated Students List)
                // -----------------------------------------------------------
                Flickable{
                    anchors.fill: parent
                    visible: !serverData.isLoading && !serverData.hasError && (serverData.students.length > 0)
                    contentHeight: studentListColumn.implicitHeight
                    clip: true

                    Column{
                        id: studentListColumn
                        width: parent.width - 14  // ✅ Leaves a clean 14px space for the ScrollBar!
                        spacing: 8

                        //Repeater creates a Student Row Item for every student in c++!
                        Repeater{
                            model: serverData.students
                            StudentRowItemNetwork{
                                studentData: modelData
                                itemIndex: index
                                isSelected: serverData.selectedStudent && (serverData.selectedStudent.id === modelData.id)
                                onInspectClicked: (id)=>serverData.selectStudent(id)
                            }
                        }
                    }
                    ScrollBar.vertical: ScrollBar{
                        policy: ScrollBar.AsNeeded
                    }
                }
            }
        }

        //Right half: student Metadata inspector (Column Positioner)
        StudentMetaColumnNetwork{
            width: parent.width * 0.45 - 16
            height: parent.height
            studentData: serverData.selectedStudent
        }
    }
}
