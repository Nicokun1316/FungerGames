import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic

ApplicationWindow {
    id: window

    width: 860
    height: 560
    visible: true
    title: qsTr("FungerGames")
    color: "#f5efe4"

    component InfoRow: RowLayout {
        property string labelText: ""
        property string valueText: ""

        Layout.fillWidth: true
        spacing: 12

        Label {
            Layout.preferredWidth: 150
            text: labelText
            font.bold: true
            color: "#3f2f22"
        }

        Label {
            Layout.fillWidth: true
            text: valueText.length > 0 ? valueText : qsTr("Waiting for data")
            wrapMode: Text.Wrap
            color: "#5f4b3a"
        }
    }

    component ServiceCard: Frame {
        required property QtObject service
        required property string accentColor

        Layout.fillWidth: true
        background: Rectangle {
            radius: 18
            color: "#fffaf2"
            border.color: accentColor
            border.width: 2
        }

        contentItem: ColumnLayout {
            spacing: 14

            Label {
                Layout.fillWidth: true
                text: service.name
                font.pixelSize: 24
                font.bold: true
                color: "#2d2018"
            }

            Rectangle {
                Layout.preferredWidth: 170
                Layout.preferredHeight: 34
                radius: 17
                color: service.connected ? accentColor : "#d3875d"

                Label {
                    anchors.centerIn: parent
                    text: service.connected ? qsTr("Connected") : qsTr("Disconnected")
                    color: "#fffaf2"
                    font.bold: true
                }
            }

            InfoRow {
                labelText: qsTr("Service")
                valueText: service.payload.service || ""
            }

            InfoRow {
                visible: service === appController.deviceService
                labelText: qsTr("Device ID")
                valueText: visible ? (service.payload.deviceId || "") : ""
            }

            InfoRow {
                visible: service === appController.deviceService
                labelText: qsTr("Online")
                valueText: visible ? String(service.payload.online ?? "") : ""
            }

            InfoRow {
                visible: service === appController.deviceService
                labelText: qsTr("Temperature")
                valueText: visible ? ((service.payload.temperature ?? "") + " C") : ""
            }

            InfoRow {
                visible: service === appController.deviceService
                labelText: qsTr("Battery")
                valueText: visible ? ((service.payload.battery ?? "") + "%") : ""
            }

            InfoRow {
                visible: service === appController.gameService
                labelText: qsTr("Title")
                valueText: visible ? (service.payload.title || "") : ""
            }

            InfoRow {
                visible: service === appController.gameService
                labelText: qsTr("Players Online")
                valueText: visible ? String(service.payload.playersOnline ?? "") : ""
            }

            InfoRow {
                visible: service === appController.gameService
                labelText: qsTr("Round State")
                valueText: visible ? (service.payload.roundState || "") : ""
            }

            InfoRow {
                labelText: qsTr("Last Updated")
                valueText: service.lastUpdated
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#f7f0e5" }
            GradientStop { position: 1.0; color: "#e8dcc7" }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        Label {
            Layout.fillWidth: true
            text: qsTr("FungerGames Prototype Dashboard")
            font.pixelSize: 34
            font.bold: true
            color: "#231811"
        }

        Label {
            Layout.fillWidth: true
            text: qsTr("Live stub telemetry from two local Qt TCP services.")
            color: "#614b39"
            wrapMode: Text.Wrap
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 20

            ServiceCard {
                service: appController.deviceService
                accentColor: "#4c8c78"
            }

            ServiceCard {
                service: appController.gameService
                accentColor: "#9a5c2f"
            }
        }
    }
}
