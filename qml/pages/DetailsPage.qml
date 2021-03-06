import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: cronEntryDetailPage

    property string execCommand: ""
    property string aliasCommand: ""
    property string detail_minute: ""
    property string detail_hour: ""
    property string detail_dom: ""
    property string detail_month: ""
    property string detail_dow: ""
    property string detail_lnbr: ""
    property string timeString: detail_minute + " " + detail_hour + " " + detail_dom
                                + " " + detail_month + " " + detail_dow
    property string timeStringHuman: ""

    // Place our content in a Column.  The PageHeader is always placed at the top
    // of the page, followed by our content.
    onStatusChanged: {
        if (status == PageStatus.Active) {
            console.log("status changed")
            if (detail_minute === "pop") {
                pageStack.pop()
            }
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Edit")
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("AddPage.qml"), {
                                                    "linenumber": detail_lnbr,
                                                    "str_minute": detail_minute,
                                                    "str_hour": detail_hour,
                                                    "str_dom": detail_dom,
                                                    "str_month": detail_month,
                                                    "str_dow": detail_dow,
                                                    "commandTXT": execCommand,
                                                    "aliasTXT": aliasCommand
                                                })
                    dialog.accepted.connect(onDialogAccepted)
                }
                function onDialogAccepted() {
                    detail_minute = "pop"
                    // back to mainpage
                    // pageStack.completeAnimation()
                    // pageStack.pop()
                    // pageStack.replace(Qt.resolvedUrl("MainPage.qml"))
                }
            }
        }

        VerticalScrollDecorator {
        }

        Column {
            id: column
            width: cronEntryDetailPage.width
            // set spacing considering the width/height ratio
            spacing: cronEntryDetailPage.height / cronEntryDetailPage.width
                     > 1.6 ? Theme.paddingMedium : Theme.paddingSmall
            PageHeader {
                title: qsTr("Cron entry details")
            }
            Label {
                x: Theme.paddingLarge
                text: qsTr("User")
            }
            Label {
                x: Theme.paddingLarge
                width: parent.width - Theme.paddingLarge
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                text: mainapp.current_cron_user
                wrapMode: Text.Wrap
            }
            Label {
                x: Theme.paddingLarge
                text: qsTr("Command displayed")
            }
            Label {
                x: Theme.paddingLarge
                width: parent.width - Theme.paddingLarge
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                text: aliasCommand
                wrapMode: Text.Wrap
            }
            Label {
                x: Theme.paddingLarge
                text: qsTr("Command to execute")
            }
            Label {
                x: Theme.paddingLarge
                width: parent.width - Theme.paddingLarge
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                text: execCommand
                wrapMode: Text.Wrap
            }
            Label {
                x: Theme.paddingLarge
                text: qsTr("Cron format execution time")
            }
            Label {
                x: Theme.paddingLarge
                width: parent.width - Theme.paddingLarge
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                text: timeString
            }
            Label {
                x: Theme.paddingLarge
                text: qsTr("Human readable execution time")
                wrapMode: Text.Wrap
            }
            Label {
                x: Theme.paddingLarge
                width: parent.width - Theme.paddingLarge
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                text: timeStringHuman
                wrapMode: Text.WordWrap
            }
        }
    }
}
