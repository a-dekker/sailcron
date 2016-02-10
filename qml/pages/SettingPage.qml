import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sailcron.Settings 1.0

Dialog {
    id: settingsPage
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
        }
    }
}
