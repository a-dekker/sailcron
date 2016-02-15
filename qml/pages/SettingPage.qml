import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sailcron.Launcher 1.0
import harbour.sailcron.Settings 1.0

Dialog {
    id: settingsPage

    App {
        id: bar
    }

    property string isStarted
    property string isEnabled

    allowedOrientations: Orientation.Portrait | Orientation.Landscape
                         | Orientation.LandscapeInverted
    canAccept: true

    onAccepted: {
        if (cron_user.currentIndex === 0) {
            myset.setValue("default_cron", "nemo")
        }
        if (cron_user.currentIndex === 1) {
            myset.setValue("default_cron", "root")
        }
        myset.sync()
    }

    objectName: "SettingPage"

    function checkCronStatus() {
        isStarted = bar.launch(
            "/usr/share/harbour-sailcron/helper/sailcronhelper isStarted")
        console.log(isStarted)
        isEnabled = bar.launch(
            "/usr/share/harbour-sailcron/helper/sailcronhelper isEnabled")
        console.log(isEnabled)
    }

    Component.onCompleted: {
        checkCronStatus()
                    }

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        MySettings {
            id: myset
        }

        clip: true

        ScrollDecorator {
        }

        Column {
            id: col
            spacing: isPortrait ? Theme.paddingLarge : Theme.paddingMedium
            width: parent.width
            DialogHeader {

                acceptText: qsTr("Save")
                cancelText: qsTr("Cancel")
            }
            SectionHeader {
                text: qsTr("Settings")
                visible: isPortrait
            }

            ComboBox {
                id: cron_user
                width: parent.width
                label: qsTr("Default cron user") + ":"
                description: qsTr("Which users crontab is shown at startup")
                currentIndex: myset.value("default_cron") === "root" ? 1 : 0
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("nemo") // 0
                    }
                    MenuItem {
                        text: qsTr("root") // 1
                    }
                }
            }
            SectionHeader {
                text: qsTr("Cron(d) daemon actions")
            }
            Row {
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                spacing: (width / 2) * 0.1
                height: Theme.itemSizeMedium + Theme.paddingMedium
                Button {
                    id: startButton
                    anchors.bottom: parent.bottom
                    width: (parent.width / 2) * 0.95
                    text: qsTr("Start")
                    enabled: isStarted === "false"
                    onClicked: {
                        bar.launch(
                        "/usr/share/harbour-sailcron/helper/sailcronhelper start_cron")
                        checkCronStatus()
                    }
                }
                Button {
                    id: stopButton
                    anchors.bottom: parent.bottom
                    width: (parent.width / 2) * 0.95
                    text: qsTr("Stop")
                    enabled: isStarted === "true"
                    onClicked: {
                        bar.launch(
                        "/usr/share/harbour-sailcron/helper/sailcronhelper stop_cron")
                        checkCronStatus()
                    }
                }
            }
            Row {
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                spacing: (width / 2) * 0.1
                height: Theme.itemSizeMedium + Theme.paddingMedium
                Button {
                    id: enabledButton
                    anchors.bottom: parent.bottom
                    width: (parent.width / 2) * 0.95
                    text: qsTr("Autostart")
                    enabled: isEnabled !== "enabled"
                    onClicked: {
                        bar.launch(
                        "/usr/share/harbour-sailcron/helper/sailcronhelper enable_cron")
                        checkCronStatus()
                    }
                }
                Button {
                    id: disableButton
                    anchors.bottom: parent.bottom
                    width: (parent.width / 2) * 0.95
                    text: qsTr("No autostart")
                    enabled: isEnabled === "enabled"
                    onClicked: {
                        bar.launch(
                        "/usr/share/harbour-sailcron/helper/sailcronhelper disable_cron")
                        checkCronStatus()
                    }
                }
            }
        }
    }
}
