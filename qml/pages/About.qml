import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: aboutPage
    allowedOrientations: Orientation.Portrait | Orientation.Landscape
                         | Orientation.LandscapeInverted
    property bool largeScreen: screen.width > 540

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        VerticalScrollDecorator {
        }

        Column {
            id: col
            spacing: Theme.paddingLarge
            width: parent.width
            PageHeader {
                title: qsTr("About")
            }
            SectionHeader {
                text: qsTr("Info")
                visible: isPortrait || (largeScreen && screen.width > 1080)
            }
            Separator {
                color: Theme.primaryColor
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Qt.AlignHCenter
                visible: isPortrait || (largeScreen && screen.width > 1080)
            }
            Label {
                text: "Sailcron"
                font.pixelSize: largeScreen ? Theme.fontSizeHuge : Theme.fontSizeExtraLarge
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: isLandscape ? (largeScreen ? "/usr/share/icons/hicolor/256x256/apps/harbour-sailcron.png" : "/usr/share/icons/hicolor/86x86/apps/harbour-sailcron.png") : (largeScreen ? "/usr/share/icons/hicolor/256x256/apps/harbour-sailcron.png" : "/usr/share/icons/hicolor/128x128/apps/harbour-sailcron.png")
            }
            Label {
                font.pixelSize: largeScreen ? Theme.fontSizeLarge : Theme.fontSizeMedium
                text: qsTr("Version") + " " + version
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.secondaryHighlightColor
            }
            Label {
                text: qsTr("Manage your crontabs")
                font.pixelSize: Theme.fontSizeSmall
                width: parent.width
                horizontalAlignment: Text.Center
                textFormat: Text.RichText
                wrapMode: Text.Wrap
                color: Theme.secondaryColor
            }
            SectionHeader {
                text: qsTr("Author")
                visible: isPortrait || (largeScreen && screen.width > 1080)
            }
            Separator {
                color: Theme.primaryColor
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Qt.AlignHCenter
                visible: isPortrait || (largeScreen && screen.width > 1080)
            }
            Label {
                text: "© Arno Dekker 2016-2017"
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Label {
                x: Theme.paddingLarge
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeTiny
                text: isPortrait ? "Using <a href=\"https://github.com/Salamek/cron-descriptor\">Cron Descriptor</a> for human readable strings" : "Using <a href=\"https://github.com/Salamek/cron-descriptor\">Cron Descriptor</a> for human readable strings and <a href=\"https://github.com/doctormo/python-crontab\">python-crontab</a> for validation checks"
                linkColor: Theme.highlightColor
                onLinkActivated: Qt.openUrlExternally(link)
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Label {
                x: Theme.paddingLarge
                visible: isPortrait
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeTiny
                text: "Using <a href='#'>python-crontab</a> for validation checks"
                linkColor: Theme.highlightColor
                onLinkActivated: Qt.openUrlExternally(
                                     "https://github.com/doctormo/python-crontab")
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
