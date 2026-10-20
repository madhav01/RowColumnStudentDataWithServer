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
    }

}
