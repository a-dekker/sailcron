import QtQuick 2.2
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.5
import harbour.sailcron.Launcher 1.0
import Nemo.Notifications 1.0

Dialog {
    id: addPage
    canAccept: (isValidCron === true && minutesField.text !== "" && hoursField.text
                !== "" && dotmField.text !== "" && monthField.text !== "" && dowField.text
                !== "" && commandField.text !== "") || (isValidCron
                                                        && special_toggle.checked)

    App {
        id: bar
    }

    property string timeStringHuman: ""
    property bool timeStringIsValid: false
    property string cronString: ""
    property string commandTXT: ""
    property string aliasTXT: ""
    property bool isValidCron: false
    property string linenumber: ""
    property string str_minute: ""
    property string str_hour: ""
    property string str_dom: ""
    property string str_month: ""
    property string str_dow: ""
    property string special: ""

    Component.onCompleted: {
        if (str_minute.substring(0, 1) === "@") {
            special = str_minute
            minutesField.text = ''
            special_toggle.checked = true
        }
    }

    onAccepted: {
        check_validity()
        if (isValidCron === true) {
            var data
            if (special_toggle.checked) {
                cronString = '@' + cronString
            }
            if (linenumber === "") {
                // add cron entry
                data = bar.launch(
                            "/usr/share/harbour-sailcron/helper/sailcronhelper append " + Qt.btoa(
                                cronString) + " " + mainapp.current_cron_user + " " + Qt.btoa(
                                commandField.text) + "~separator~" + Qt.btoa(
                                aliasField.text))
                console.log(data)
            } else {
                data = bar.launch("/usr/share/harbour-sailcron/helper/sailcronhelper edit "
                                  + linenumber + " " + mainapp.current_cron_user + " "
                                  + Qt.btoa(cronString) + " " + Qt.btoa(
                                      commandField.text) + "~separator~" + Qt.btoa(aliasField.text))
                mainapp.changestatus = "edited"
                console.log(data)
            }
        }
    }

    function specialNbr() {
        switch (str_minute) {
        case "@reboot":
            return 0
        case "@yearly":
            return 1
        case "@annually":
            return 1
        case "@monthly":
            return 2
        case "@weekly":
            return 3
        case "@daily":
            return 4
        case "@hourly":
            return 5
        default:
            return 0
        }
    }

    function banner(notificationType, message) {
        notification.close()
        var notificationCategory
        switch (notificationType) {
        case "OK":
            notificationCategory = "x-jolla.store.sideloading-success"
            break
        case "INFO":
            notificationCategory = "x-jolla.lipstick.credentials.needUpdate.notification"
            break
        case "WARNING":
            notificationCategory = "x-jolla.store.error"
            break
        case "ERROR":
            notificationCategory = "x-jolla.store.error"
            break
        }
        notification.category = notificationCategory
        notification.previewBody = message
        notification.previewSummary = "Sailcron"
        notification.publish()
    }

    function check_validity() {
        if (special_toggle.checked) {
            cronString = special.replace('@', '')
        } else {
            cronString = minutesField.text + " " + hoursField.text + " "
                    + dotmField.text + " " + monthField.text + " " + dowField.text
        }
        // sync python call else timeStringValid is not filled on time ?
        timeStringIsValid = py.call_sync("valid_cron.validate_cron",
                                         [cronString.trim()])
        if (timeStringIsValid == false) {
            banner("ERROR", qsTr("Invalid cron syntax!"))
            isValidCron = false
        } else {
            // sync python call else timeStringHuman is not filled on time ?
            timeStringHuman = py.call_sync("pretty_cron.get_pretty",
                                           [1, cronString])
            if (timeStringHuman.indexOf("error") >= 0) {
                banner("ERROR", '❌ ' + qsTr("Invalid cron syntax!"))
                isValidCron = false
            } else {
                banner("OK", '✓ ' + qsTr("Cron syntax valid"))
                isValidCron = true
            }
        }
    }

    Notification {
        id: notification
        itemCount: 1
    }

    objectName: "AddPage"

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        clip: true

        ScrollDecorator {
        }

        Column {
            id: col
            spacing: 5
            width: parent.width
            DialogHeader {

                acceptText: qsTr("Save")
                cancelText: qsTr("Cancel")
            }
            SectionHeader {
                text: (linenumber === "" ? qsTr("Add cron entry") : qsTr(
                                               "Edit cron entry")) + " ("
                      + mainapp.current_cron_user + ")"
            }
            TextSwitch {
                id: special_toggle
                text: qsTr("Special")
                description: qsTr("Use alternative cron time indicator")
                onCheckedChanged: {
                    if (checked) {
                        special = '@' + specialtime.value
                    }
                }
            }
            ComboBox {
                id: specialtime
                label: qsTr("Interval")
                description: qsTr("Choose the preferred moment.")
                visible: special_toggle.checked
                currentIndex: specialNbr()
                width: col.width
                menu: ContextMenu {
                    MenuItem {
                        text: "reboot"
                    } // 1
                    MenuItem {
                        text: "yearly"
                    } // 2
                    MenuItem {
                        text: "monthly"
                    } // 3
                    MenuItem {
                        text: "weekly"
                    } // 4
                    MenuItem {
                        text: "daily"
                    } // 5
                    MenuItem {
                        text: "hourly"
                    } // 6
                }
                onCurrentIndexChanged: {
                    special = '@' + specialtime.value
                }
            }
            Label {
                width: col.width - Theme.paddingLarge * 2
                x: Theme.paddingLarge
                y: Theme.paddingLarge
                text: "<b>" + qsTr(
                          "Minutes past every hour") + "</b><br>" + qsTr(
                          "Range from 0-59. Wildcard (*) means every minute, */15 every 15 minutes.")
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                visible: !special_toggle.checked
            }
            TextField {
                id: minutesField
                font.pixelSize: Theme.fontSizeSmall
                inputMethodHints: Qt.ImhNoPredictiveText
                placeholderText: qsTr('Enter minutes')
                validator: RegExpValidator {
                    regExp: /[*]{0,1}[0-9,-/]{0,25}/
                }
                text: str_minute
                width: col.width / 2
                maximumLength: 25
                EnterKey.enabled: text.trim().length > 0
                EnterKey.onClicked: {
                    hoursField.focus = true
                }
                visible: !special_toggle.checked
            }
            Label {
                width: col.width - Theme.paddingLarge * 2
                x: Theme.paddingLarge
                y: Theme.paddingLarge
                text: "<b>" + qsTr("Hours") + "</b><br>" + qsTr(
                          "Range from 0-23. Wildcard (*) means every hour, */2 every other hour. Multiple hours like 7-11 or 6,7,9")
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                visible: !special_toggle.checked
            }
            TextField {
                id: hoursField
                font.pixelSize: Theme.fontSizeSmall
                inputMethodHints: Qt.ImhNoPredictiveText
                placeholderText: qsTr('Enter hours')
                EnterKey.enabled: text.trim().length > 0
                validator: RegExpValidator {
                    regExp: /[*]{0,1}[0-9,-/]{0,25}/
                }
                text: str_hour
                width: col.width / 2
                maximumLength: 25
                EnterKey.onClicked: {
                    dotmField.focus = true
                }
                visible: !special_toggle.checked
            }
            Label {
                width: col.width - Theme.paddingLarge * 2
                x: Theme.paddingLarge
                y: Theme.paddingLarge
                text: "<b>" + qsTr("Day of the month") + "</b><br>" + qsTr(
                          "Range from 1-31. Wildcard (*) means every day. Multiple days like 1-11 or 20,21")
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                visible: !special_toggle.checked
            }
            TextField {
                id: dotmField
                font.pixelSize: Theme.fontSizeSmall
                inputMethodHints: Qt.ImhNoPredictiveText
                placeholderText: qsTr('Enter day of month')
                EnterKey.enabled: text.trim().length > 0
                validator: RegExpValidator {
                    regExp: /[*]{0,1}[0-9,-]{0,25}/
                }
                text: str_dom
                width: col.width / 1.5
                maximumLength: 25
                EnterKey.onClicked: {
                    monthField.focus = true
                }
                visible: !special_toggle.checked
            }
            Label {
                width: col.width - Theme.paddingLarge * 2
                x: Theme.paddingLarge
                y: Theme.paddingLarge
                text: "<b>" + qsTr("Month") + "</b><br>" + qsTr(
                          "Range from 1-12. Wildcard (*) means every month. Multiple months like 2-4 or 2,5")
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                visible: !special_toggle.checked
            }
            TextField {
                id: monthField
                font.pixelSize: Theme.fontSizeSmall
                placeholderText: qsTr('Enter month')
                inputMethodHints: Qt.ImhNoPredictiveText
                EnterKey.enabled: text.trim().length > 0
                validator: RegExpValidator {
                    regExp: /[*]{0,1}[0-9A-Z,-]{0,25}/
                }
                text: str_month
                width: col.width / 2
                maximumLength: 25
                EnterKey.onClicked: {
                    dowField.focus = true
                }
                visible: !special_toggle.checked
            }
            Label {
                width: col.width - Theme.paddingLarge * 2
                x: Theme.paddingLarge
                y: Theme.paddingLarge
                text: "<b>" + qsTr("Day of the week") + "</b><br>" + qsTr(
                          "Range from 0-6. Wildcard (*) means every day of the week. Sunday is 0 (or enter SUN). Multiple days of the week like 2-4 or 2,5")
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                visible: !special_toggle.checked
            }
            TextField {
                id: dowField
                font.pixelSize: Theme.fontSizeSmall
                font.capitalization: Font.AllUppercase
                inputMethodHints: Qt.ImhNoPredictiveText
                placeholderText: qsTr('Enter day of week')
                validator: RegExpValidator {
                    regExp: /[*]{0,1}[0-9A-Z,-]{0,25}/
                }
                EnterKey.enabled: text.trim().length > 0
                text: str_dow
                width: col.width / 1.5
                maximumLength: 25
                EnterKey.onClicked: {
                    commandField.focus = true
                }
                visible: !special_toggle.checked
            }
            Label {
                width: col.width - Theme.paddingLarge * 2
                x: Theme.paddingLarge
                y: Theme.paddingLarge
                text: "<b>" + qsTr("Command") + "</b><br>" + qsTr(
                          "This command will be executed if it is matched with the time")
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
            }
            TextField {
                id: commandField
                text: commandTXT
                font.pixelSize: Theme.fontSizeSmall
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                placeholderText: qsTr("Enter command here")
                maximumLength: 400
                width: col.width - Theme.paddingLarge * 2
                EnterKey.enabled: text.trim().length > 0
                EnterKey.onClicked: {
                    aliasField.focus = true
                }
            }
            Label {
                width: col.width - Theme.paddingLarge * 2
                x: Theme.paddingLarge
                y: Theme.paddingLarge
                text: "<b>" + qsTr("Custom text") + "</b><br>" + qsTr(
                          "Show a more meaningful command text, e.g. 'Flightmode on'")
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
            }
            TextField {
                id: aliasField
                text: aliasTXT
                font.pixelSize: Theme.fontSizeSmall
                inputMethodHints: Qt.ImhNoPredictiveText
                placeholderText: qsTr("Enter custom text here")
                maximumLength: 100
                width: col.width - Theme.paddingLarge * 2
                EnterKey.enabled: text.trim().length > 0
                EnterKey.onClicked: {
                    aliasField.focus = false
                }
            }
            Label {
                width: col.width - Theme.paddingLarge * 2
                x: Theme.paddingLarge
                y: Theme.paddingLarge
                text: timeStringHuman
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                visible: isValidCron
                wrapMode: Text.Wrap
            }
            Python {
                id: py

                Component.onCompleted: {
                    // Add the directory of this .qml file to the search path
                    addImportPath(Qt.resolvedUrl('.'))
                    // Import the main module
                    importModule('pretty_cron', function () {
                        console.log('pretty_cron module is now imported')
                    })
                    importModule('valid_cron', function () {
                        console.log('valid_cron module is now imported')
                    })
                }
                onError: {
                    // when an exception is raised, this error handler will be called
                    isValidCron = false
                    console.log('python error: ' + traceback)
                }
            }
            Button {
                id: check_cron_string
                enabled: (minutesField.text !== "" && hoursField.text !== ""
                          && dotmField.text !== "" && monthField.text !== ""
                          && dowField.text !== "") || special_toggle.checked
                text: qsTr("Verify cron time")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    check_validity()
                }
            }
            Label {
                // just some whitespace
                text: " "
            }
        }
    }
}
