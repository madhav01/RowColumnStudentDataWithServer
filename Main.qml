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

    BackendServer{
        id: serverData
    }
    Row{
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        //===============================================================
        //Left Half: Student List (a Column holding each student row item
        //===============================================================
        Column{
            width: parent.width * 0.55
            height: parent.height
            spacing: 10


            //Title Label
            Text{
                text: "📋 Active Students List (Row Positioners)"
                font.bold: true
                font.pixelSize: 14
                color: "#171717"
            }
            Flickable{
                width: parent.width
                height: parent.height - 30
                contentHeight: studentListColumn.implicitHeight
                clip: true

                Column{
                    id: studentListColumn
                    width: parent.width
                    spacing: 8

                    //Repeater creates a Student Row Item for every student in c++!
                    Repeater{
                        model: serverData.students
                        StudentRowItemNetwork{

                        }
                    }
                }
            }
        }

        //Right half: student Metadata inspector (Column Positioner)
        StudentMetaColumnNetwork{
            width: parent.width * 0.45 - 16
            height: parent.height
        }
    }
}
