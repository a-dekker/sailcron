import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sailcron.Launcher 1.0
import org.nemomobile.notifications 1.0
import harbour.sailcron.Settings 1.0
import io.thp.pyotherside 1.4


// using cron_descriptor: https://github.com/Salamek/cron-descriptor
// using python-crontab : https://code.launchpad.net/python-crontab
Page {
    id: mainPage
    allowedOrientations: Orientation.Portrait | Orientation.Landscape
                         | Orientation.LandscapeInverted

    App {
        id: bar
    }

    MySettings {
        id: myset
    }

    property string lineNbr
    property string isEnabled
    property string minutes
    property string hours
    property string dayOfMonth
    property string month
    property string dayOfWeek
    property string command_string

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

    Notification {
        id: notification
        itemCount: 1
    }

    function loadConfig() {
        if (myset.contains("default_cron")) {
            current_cron_user = myset.value("default_cron").toString()
        } else {
            current_cron_user = "nemo"
        }
    }

    function loadCron() {
        var myElement
        var cronString
        var aliasString
        var data = Qt.atob(
                    bar.launch(
                        "/usr/share/harbour-sailcron/helper/sailcronhelper readcron "
                        + mainapp.current_cron_user))
        data = data.split('\n')
        for (var i = 0; i < data.length - 1; i++) {
            myElement = data[i].split("~|")
            lineNbr = myElement[0].trim()
            isEnabled = myElement[1].trim()
            minutes = myElement[2].trim()
            hours = myElement[3].trim()
            dayOfMonth = myElement[4].trim()
            month = myElement[5].trim()
            dayOfWeek = myElement[6].trim()
            command_string = myElement[7].trim()
            // check if alias is present
            aliasString = bar.launch(
                        "/usr/share/harbour-sailcron/helper/sailcronhelper readalias " + Qt.btoa(
                            command_string)).trim()
            appendList(lineNbr, isEnabled, minutes, hours, dayOfMonth, month,
                       dayOfWeek, command_string, aliasString, "")
            // we did add an empty string for the human value
            // we deal with that async in the onReceived python part, with index-id as reference
            cronString = minutes + " " + hours + " " + dayOfMonth + " " + month + " " + dayOfWeek
            python.call("pretty_cron.get_pretty", [listCronModel.count, cronString])
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Activating) {
            if (mainapp.changestatus === "edited") {
                // reload
                listCronModel.clear()
                loadCron()
                mainapp.changestatus = ""
            }
        }
    }

    Component.onCompleted: {
        var cronpid = bar.launch("pgrep -f crond")
        if (cronpid === "") {
            banner("WARNING", qsTr("Cron daemon is not running!"))
        }
        loadConfig()
        loadCron()
    }

    // helper function to add lists to the list
    function appendList(lineNbr, isEnabled, minutes, hours, dayOfMonth, month, dayOfWeek, command_string, aliasString, timeStringHuman) {
        listCronModel.append({
                                 lineNbr: lineNbr,
                                 isEnabled: isEnabled,
                                 minutes: minutes,
                                 hours: hours,
                                 dayOfMonth: dayOfMonth,
                                 month: month,
                                 dayOfWeek: dayOfWeek,
                                 command_string: command_string,
                                 aliasString: aliasString,
                                 timeStringHuman: timeStringHuman
                             })
    }

    Python {
        id: python

        Component.onCompleted: {
            // Add the directory of this .qml file to the search path
            addImportPath(Qt.resolvedUrl('.'))
            // Import the main module
            importModule('pretty_cron', function () {
                console.log('pretty_cron module is now imported')
            })
            setHandler('result', function(result_index,human_string) {
                listCronModel.setProperty(result_index-1, "timeStringHuman", human_string)
                // console.log(result_index,human_string)
            });
        }
        onError: {
            // when an exception is raised, this error handler will be called
            console.log('python error: ' + traceback)
        }
        onReceived: {
            // asychronous messages from Python arrive here
            // in Python, this can be accomplished via pyotherside.send()
            // console.log(data[0]-1, "timeStringHuman", data[1])
        }
    }
    BusyIndicator {
        anchors.centerIn: parent
        running: listCronModel.count === 0
        size: BusyIndicatorSize.Large
    }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        SilicaListView {
            id: listPass
            width: parent.width
            height: parent.height
            // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
            PullDownMenu {
                MenuItem {
                    text: qsTr("About")
                    onClicked: pageStack.push(Qt.resolvedUrl("About.qml"))
                }
                MenuItem {
                    text: qsTr("Settings")
                    onClicked: pageStack.push(Qt.resolvedUrl("SettingPage.qml"))
                }
                MenuItem {
                    text: mainapp.current_cron_user
                          === "nemo" ? qsTr("Switch to user root") : qsTr(
                                           "Switch to user nemo")
                    onClicked: {
                        mainapp.current_cron_user
                                === "nemo" ? mainapp.current_cron_user
                                             = "root" : mainapp.current_cron_user = "nemo"
                        listCronModel.clear()
                        loadCron()
                    }
                }
                MenuItem {
                    text: qsTr("Add new entry")
                    onClicked: {
                        var dialog = pageStack.push(Qt.resolvedUrl(
                                                        "AddPage.qml"))
                        dialog.accepted.connect(function () {
                            listCronModel.clear()
                            loadCron()
                        })
                    }
                }
            }
            header: PageHeader {
                width: listPass.width
                title: qsTr("Sailcron" + " (" + current_cron_user + ")")
            }
            VerticalScrollDecorator {
            }
            model: ListModel {
                id: listCronModel
            }

            ViewPlaceholder {
                id: placeholder
                enabled: listPass.count === 0
                text: qsTr("No cron entries found for user ") + mainapp.current_cron_user
            }
            delegate: ListItem {
                id: listPassItem
                menu: contextMenu

                function enable() {
                    remorseAction(qsTr("Enabling") + " '" + listCronModel.get(
                                      index).command_string.substring(
                                      0, 20) + "'", function () {
                                          var infoString = listCronModel.get(
                                                      index).lineNbr
                                          var data = bar.launch(
                                                      "/usr/share/harbour-sailcron/helper/sailcronhelper enable " + infoString + " " + mainapp.current_cron_user)
                                          listCronModel.get(
                                                      index).isEnabled = "true"
                                      })
                }

                function disable() {
                    remorseAction(
                                qsTr("Disabling") + " '" + commandLabel.text.substring(
                                    0, 20) + "'", function () {
                                        var infoString = listCronModel.get(
                                                    index).lineNbr
                                        var data = bar.launch(
                                                    "/usr/share/harbour-sailcron/helper/sailcronhelper disable " + infoString + " " + mainapp.current_cron_user)
                                        listCronModel.get(
                                                    index).isEnabled = "false"
                                    })
                }
                function remove() {
                    remorseAction(
                                qsTr("Deleting") + " '" + commandLabel.text.substring(
                                    0, 20) + "'", function () {
                                        var infoString = listCronModel.get(
                                                    index).lineNbr
                                        var data = bar.launch(
                                                    "/usr/share/harbour-sailcron/helper/sailcronhelper delete " + infoString + " " + mainapp.current_cron_user)
                                        console.log(data)
                                        listCronModel.remove(index)
                                        // reload to prevent possible line number shift
                                        listCronModel.clear()
                                        loadCron()
                                    })
                }
                RemorseItem {
                    id: listRemorse
                }
                Item {
                    // background element with diagonal gradient
                    anchors.fill: parent
                    clip: true
                    Rectangle {
                        rotation: isPortrait ? 9 : 5
                        height: parent.height
                        x: -listPass.width
                        width: listPass.width * 2

                        gradient: Gradient {
                            GradientStop {
                                position: 0.0
                                color: Theme.rgba(Theme.primaryColor, 0)
                            }
                            GradientStop {
                                position: 1.0
                                color: Theme.rgba(Theme.primaryColor, 0.1)
                            }
                        }
                    }
                }

                Label {
                    id: commandLabel
                    text: aliasString === "" ? command_string : aliasString
                    font.pixelSize: Theme.fontSizeSmall
                    font.strikeout: isEnabled === "false"
                    width: parent.width
                    truncationMode: TruncationMode.Fade
                    x: Theme.paddingSmall
                    color: isEnabled === "true" ? Theme.primaryColor : Theme.secondaryColor
                }
                Label {
                    id: timeLabel
                    anchors.top: commandLabel.bottom
                    text: timeStringHuman
                    font.strikeout: isEnabled === "false"
                    x: Theme.paddingSmall
                    width: parent.width
                    truncationMode: TruncationMode.Fade
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                }
                Component {
                    id: contextMenu
                    ContextMenu {
                        MenuItem {
                            visible: isEnabled === "true"
                            text: qsTr("Edit")
                            onClicked: {
                                var dialog = pageStack.push(
                                            Qt.resolvedUrl("AddPage.qml"), {
                                                linenumber: listCronModel.get(
                                                                index).lineNbr,
                                                str_minute: listCronModel.get(
                                                                index).minutes,
                                                str_hour: listCronModel.get(
                                                              index).hours,
                                                str_dom: listCronModel.get(
                                                             index).dayOfMonth,
                                                str_month: listCronModel.get(
                                                               index).month,
                                                str_dow: listCronModel.get(
                                                             index).dayOfWeek,
                                                commandTXT: listCronModel.get(
                                                                index).command_string,
                                                aliasTXT: listCronModel.get(
                                                              index).aliasString
                                            })
                            }
                        }
                        MenuItem {
                            text: isEnabled === "true" ? qsTr("Disable") : qsTr(
                                                             "Enable")
                            onClicked: {
                                if (isEnabled === "true") {
                                    disable()
                                } else {
                                    enable()
                                }
                            }
                        }
                        MenuItem {
                            text: qsTr("Remove")
                            onClicked: {
                                remove()
                            }
                        }
                    }
                }
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("DetailsPage.qml"), {
                                       detail_minute: listCronModel.get(
                                                          index).minutes,
                                       detail_hour: listCronModel.get(
                                                        index).hours,
                                       detail_dom: listCronModel.get(
                                                       index).dayOfMonth,
                                       detail_month: listCronModel.get(
                                                         index).month,
                                       detail_dow: listCronModel.get(
                                                       index).dayOfWeek,
                                       execCommand: listCronModel.get(
                                                        index).command_string,
                                       aliasCommand: commandLabel.text,
                                       timeStringHuman: timeLabel.text,
                                       detail_lnbr: listCronModel.get(
                                                       index).lineNbr
                                   })
                }
            }
        }
    }
}
