import QtQuick
import QtQuick.Controls.Native

Rectangle{
    id:root

    //1.Sizing Respose width, fixed crisp card height
    width: parent ? parent.width : 450
    height: 52
    radius: 8

    //Data property passed from parent list
    property var studentData:({})
    property bool isSelected: false
    property int itemIndex: 0
    signal inspectClicked(int studentId)

    //styling & states
    color: isSelected ? "#1e293b" : mouseArea.containsMouse ? "#170233" : "#0f172a"
    border.color: isSelected ? "#38bdf8" : "#334155"
    border.width: isSelected ? 2 :1

    //Full-card click area

    MouseArea{
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if(root.studentData && root.studentData.id !== undefined){
                root.inspectClicked(root.studentData.id)
            }
        }
    }

    //================================================================
    //The Row Positioner:
    //Arrange all child elements horizontally
    //Childer NEVER set their own x or horizontalCenter anchors
    //================================================================

    Row{
        id: contentRow
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 12
        spacing: 10

        //1. Index Badge(Uses Positioner attached property)
        Rectangle{
            width: 28;height: 28
            radius: 6
            anchors.verticalCenter: parent.verticalCenter

            //Positioner.isFirstItem demo: top student get a gold tint!
            color: (root.itemIndex ===0) ? "#854d0e" : "#1e293b"

            Text{
                anchors.centerIn: parent
                //Positioner.index demo : 0-based index from positioner
                text: (root.itemIndex+1)
                font.bold: true
                font.pixelSize: 11
                color: (root.itemIndex ===0) ? "#fef08a" : "#94a3b8"
            }
        }
        //Avatar Badge
        Rectangle{
            width: 32;height: 32
            radius: 16
            color: "#0284c7"
            anchors.verticalCenter: parent.verticalCenter

            Text{
                anchors.centerIn: parent
                text: (root.studentData.name && root.studentData.name.length>0) ? root.studentData.name.charAt(0).toUpperCase() : "S"
                font.bold: true
                font.pixelSize: 14
                color: "#ffffff"
            }
        }
        //3. Student name & ID
        Column{
            width: 120
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text{
                text: root.studentData.name || "Student"
                font.bold: true
                font.pixelSize: 13
                elide: Text.ElideRight
                width: parent.width
                color: "#f8fafc"
            }
            Text{
                text: "ID: #" + (root.studentData.id || "")
                font.pixelSize: 10
                color: "#94a3b8"
            }
        }
        //4.Age Badge
        Rectangle{
            width: 52;height: 24
            radius: 4
            color: "#1e293b"
            border.color: "#334155"
            anchors.verticalCenter: parent.verticalCenter

            Text{
                anchors.centerIn: parent
                text: "Age: " + (root.studentData.age || "-")
                font.pixelSize: 10
                color: "#cbd5e1"
            }
        }

        //5.Department Badge
        Rectangle{
            width: 90; height: 24
            radius: 4
            color: "#14532d"
            border.color: "#22c55e"
            anchors.verticalCenter: parent.verticalCenter

            Text{
                anchors.centerIn: parent
                text: root.studentData.department || "CS"
                font.pixelSize: 10
                color: "#86efac"
                elide: Text.ElideRight
            }
        }

        //Status pill
        Rectangle{
            width: 60;height: 22
            radius: 11
            color: (root.studentData.status === "Active") ? "#064e3b" : "#701a75"
            anchors.verticalCenter: parent.verticalCenter

            Text{
                anchors.centerIn: parent
                text: root.studentData.status || "Active"
                font.bold: true
                font.pixelSize: 9
                color: (root.studentData.status === "Active") ? "#34d399" : "#f472b6"
            }
        }
    }
    //7. INSPECT BUTTON
    Rectangle{
        width: 65; height: 26
        radius: 5
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 12
        color: root.isSelected ? "#38bdf8" : "#334155"

        Text{
            anchors.centerIn: parent
            text: root.isSelected ? "Active" : "Inspect"
            font.pixelSize: 10
            font.bold: true
            color: root.isSelected ? "#0f172a" : "#f1f5f9"
        }
    }

}
