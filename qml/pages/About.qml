import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: aboutPage
    allowedOrientations: Orientation.Portrait | Orientation.Landscape
                         | Orientation.LandscapeInverted
    property bool largeScreen: Screen.sizeCategory === Screen.Large ||
                               Screen.sizeCategory === Screen.ExtraLarge
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
                visible: isPortrait || largeScreen
            }
            Separator {
                color: Theme.primaryColor
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Qt.AlignHCenter
                visible: isPortrait || largeScreen
            }
            Label {
                text: "Sailcron"
                font.pixelSize: largeScreen ? Theme.fontSizeHuge : Theme.fontSizeExtraLarge
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                    source: largeScreen ? "/usr/share/icons/hicolor/256x256/apps/harbour-sailcron.png" : "/usr/share/icons/hicolor/86x86/apps/harbour-sailcron.png"
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
                visible: isPortrait || largeScreen
            }
            Separator {
                color: Theme.primaryColor
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Qt.AlignHCenter
                visible: isPortrait || largeScreen
            }
            Label {
                text: "© Arno Dekker 2016"
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Label {
                x: Theme.paddingLarge
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeTiny
                text: "Using <a href='#'>Cron Descriptor</a> for human readable strings"
                linkColor: Theme.highlightColor
                onLinkActivated: Qt.openUrlExternally(
                                     "https://github.com/Salamek/cron-descriptor")
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
