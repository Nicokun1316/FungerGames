import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import QtMultimedia

ApplicationWindow {
    id: window

    width: 1100
    height: 760
    visible: true
    title: qsTr("FungerGames")
    color: "#efe8d8"

    function mixColor(calmColor, cursedColor, progress) {
        const t = Math.max(0.0, Math.min(1.0, progress))
        return Qt.rgba(
                    calmColor.r + ((cursedColor.r - calmColor.r) * t),
                    calmColor.g + ((cursedColor.g - calmColor.g) * t),
                    calmColor.b + ((cursedColor.b - calmColor.b) * t),
                    calmColor.a + ((cursedColor.a - calmColor.a) * t))
    }

    readonly property bool overLimit: appController ? appController.overLimit : false
    readonly property real eyeOffsetX: ((appController ? appController.smoothedFocusX : 0.5) - 0.5) * 20
    readonly property real eyeOffsetY: ((appController ? appController.smoothedFocusY : 0.5) - 0.5) * 14
    readonly property real cursedScale: 1.0 + ((appController ? appController.overageRatio : 0.0) * 0.35)
    readonly property string modeLabel: overLimit ? qsTr("Cursed Mode") : qsTr("Calm Mode")
    readonly property string headerSubtitle: overLimit
                                            ? qsTr("Calorie limit exceeded - fridge is displeased")
                                            : qsTr("Today's intake is within healthy bounds")
    readonly property int dailyCalories: appController ? appController.dailyCalories : 0
    readonly property int dailyLimit: appController ? appController.dailyLimit : 0
    readonly property int dailyDeficit: appController ? appController.dailyDeficit : 0
    readonly property int calorieOverage: appController ? appController.calorieOverage : 0
    readonly property int eventCalories: appController ? appController.eventCalories : 0
    readonly property string latestContentType: appController && appController.latestContentType.length > 0
                                               ? appController.latestContentType
                                               : qsTr("Waiting")
    readonly property string latestEventType: appController && appController.latestEventType.length > 0
                                             ? appController.latestEventType
                                             : qsTr("event")
    readonly property string eventDisplay: appController
                                           ? qsTr("%1 %2")
                                                 .arg(latestContentType)
                                                 .arg(String(eventCalories) + qsTr(" kcal"))
                                           : qsTr("Waiting")
    readonly property real calmProgress: dailyLimit > 0 ? Math.min(dailyCalories / dailyLimit, 1.0) : 0.0
    readonly property real overageProgress: Math.min(calorieOverage / 800.0, 1.0)
    readonly property bool alarmActive: appController ? appController.alarmActive : false
    readonly property real themeTarget: dailyLimit > 0 ? Math.min(Math.max(dailyCalories / dailyLimit, 0.0), 1.0) : 0.0
    property real themeProgress: themeTarget
    property bool moodTransitionActive: false
    property bool moodTransitionToCursed: false
    property real moodTransitionProgress: 0.0

    readonly property color calmBgStart: "#F0E8D8"
    readonly property color cursedBgStart: "#110A03"
    readonly property color calmBgMid: "#F5F0E8"
    readonly property color cursedBgMid: "#1A1208"
    readonly property color calmBgEnd: "#EDE3D0"
    readonly property color cursedBgEnd: "#0E0A05"
    readonly property color calmTitleColor: "#1C1612"
    readonly property color cursedTitleColor: "#C8B89A"
    readonly property color calmSubtitleColor: "#6B1C1612"
    readonly property color cursedSubtitleColor: "#73C8B89A"
    readonly property color calmHeaderBorder: "#1A1C1612"
    readonly property color cursedHeaderBorder: "#408B2B18"
    readonly property color calmPanelColor: "#E0FDFAF4"
    readonly property color cursedPanelColor: "#D91A1208"
    readonly property color calmPanelBorder: "#1A1C1612"
    readonly property color cursedPanelBorder: "#4D8B2B18"
    readonly property color calmMutedText: "#731C1612"
    readonly property color cursedMutedText: "#73C8B89A"
    readonly property color calmSoftText: "#661C1612"
    readonly property color cursedSoftText: "#59C8B89A"
    readonly property color calmAccentColor: "#5C8B4A"
    readonly property color cursedAccentColor: "#C4742A"
    readonly property color calmAccentSurface: "#1A5C8B4A"
    readonly property color cursedAccentSurface: "#338B2B18"
    readonly property color calmStatSurface: "#E6FDFAF4"
    readonly property color cursedStatSurface: "#D9221A0E"

    readonly property color bgStart: mixColor(calmBgStart, cursedBgStart, themeProgress)
    readonly property color bgMid: mixColor(calmBgMid, cursedBgMid, themeProgress)
    readonly property color bgEnd: mixColor(calmBgEnd, cursedBgEnd, themeProgress)
    readonly property color titleColor: mixColor(calmTitleColor, cursedTitleColor, themeProgress)
    readonly property color subtitleColor: mixColor(calmSubtitleColor, cursedSubtitleColor, themeProgress)
    readonly property color headerBorder: mixColor(calmHeaderBorder, cursedHeaderBorder, themeProgress)
    readonly property color panelColor: mixColor(calmPanelColor, cursedPanelColor, themeProgress)
    readonly property color panelBorder: mixColor(calmPanelBorder, cursedPanelBorder, themeProgress)
    readonly property color mutedText: mixColor(calmMutedText, cursedMutedText, themeProgress)
    readonly property color softText: mixColor(calmSoftText, cursedSoftText, themeProgress)
    readonly property color accentColor: mixColor(calmAccentColor, cursedAccentColor, themeProgress)
    readonly property color accentSurface: mixColor(calmAccentSurface, cursedAccentSurface, themeProgress)
    readonly property color statSurface: mixColor(calmStatSurface, cursedStatSurface, themeProgress)

    Behavior on themeProgress {
        NumberAnimation {
            duration: 1200
            easing.type: Easing.InOutQuad
        }
    }

    SoundEffect {
        id: alarmSound
        source: "qrc:/qt/qml/FungerGames/assets/alarm-loop.wav"
        loops: SoundEffect.Infinite
        volume: 0.55
    }

    onAlarmActiveChanged: {
        if (alarmActive) {
            alarmSound.play()
        } else {
            alarmSound.stop()
        }
    }

    onOverLimitChanged: {
        moodTransitionToCursed = overLimit
        moodTransitionProgress = 0.0
        moodTransitionActive = true
        moodTransitionAnimation.restart()
    }

    NumberAnimation {
        id: moodTransitionAnimation
        target: window
        property: "moodTransitionProgress"
        from: 0.0
        to: 1.0
        duration: 1400
        easing.type: Easing.InOutCubic
        onFinished: window.moodTransitionActive = false
    }

    function deltaTextForCalories() {
        if (overLimit) {
            return qsTr("Limit breached")
        }
        return qsTr("Within target")
    }

    function deltaTextForEvent() {
        if (appController && appController.fridgeServiceLastUpdated.length > 0) {
            return appController.fridgeServiceLastUpdated
        }
        return qsTr("Awaiting sync")
    }

    function deficitLabel() {
        return overLimit ? qsTr("Overage") : qsTr("Deficit")
    }

    component ModePill: Rectangle {
        required property string labelText

        radius: 20
        color: accentSurface
        border.width: 1
        border.color: overLimit ? "#738B2B18" : "#595C8B4A"

        implicitWidth: label.implicitWidth + 28
        implicitHeight: 30

        Label {
            id: label
            anchors.centerIn: parent
            text: "\u25cf " + labelText
            color: accentColor
            font.family: "DM Mono"
            font.pixelSize: 10
            font.letterSpacing: 1.4
            font.capitalization: Font.AllUppercase
        }
    }

    component HeaderButton: Button {
        id: headerButton
        required property string labelText

        text: labelText
        padding: 0

        contentItem: Label {
            text: headerButton.text
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: overLimit ? "#C8B89A" : "#1C1612"
            font.family: "DM Sans"
            font.pixelSize: 12
            font.weight: 500
        }

        background: Rectangle {
            radius: 8
            border.width: 1
            border.color: overLimit ? "#808B2B18" : "#261C1612"
            color: overLimit ? "#338B2B18" : "#121C1612"
        }
    }

    component StatCard: Frame {
        required property string labelText
        required property string valueText
        property string unitText: ""
        property string deltaText: ""
        property bool deltaPositive: true

        Layout.fillWidth: true
        background: Rectangle {
            radius: 12
            color: statSurface
            border.width: 1
            border.color: overLimit ? "#598B2B18" : "#1A1C1612"
        }

        contentItem: ColumnLayout {
            spacing: 8

            Label {
                Layout.fillWidth: true
                text: labelText
                color: mutedText
                font.family: "DM Mono"
                font.pixelSize: 10
                font.weight: 500
                font.letterSpacing: 1.2
                font.capitalization: Font.AllUppercase
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                Label {
                    text: valueText
                    color: titleColor
                    font.family: "Playfair Display"
                    font.pixelSize: 26
                    font.weight: 500
                }

                Label {
                    visible: unitText.length > 0
                    text: unitText
                    color: softText
                    font.family: "DM Sans"
                    font.pixelSize: 12
                }
            }

            Label {
                visible: deltaText.length > 0
                Layout.fillWidth: true
                text: deltaText
                color: overLimit
                       ? (deltaPositive ? "#99C8B89A" : "#8B2B18")
                       : (deltaPositive ? "#5C8B4A" : "#8B2020")
                font.family: "DM Mono"
                font.pixelSize: 10
            }
        }
    }

    component StatusRow: RowLayout {
        required property string labelText
        required property bool ok

        Layout.fillWidth: true
        spacing: 8

        Label {
            Layout.fillWidth: true
            text: labelText
            color: titleColor
            opacity: 0.7
            font.family: "DM Sans"
            font.pixelSize: 12
        }

        RowLayout {
            spacing: 5

            Rectangle {
                width: 6
                height: 6
                radius: 3
                color: ok ? accentColor : "#8B2020"
            }

            Label {
                text: ok ? qsTr("OK") : qsTr("ERR")
                color: ok ? accentColor : "#8B2020"
                font.family: "DM Mono"
                font.pixelSize: 9
                font.letterSpacing: 0.6
            }
        }
    }

    component MoodTransitionOverlay: Item {
        readonly property real startX: (width * 0.5) - 80
        readonly property real startY: height * 0.14
        readonly property real endX: (width * 0.5) - 110
        readonly property real endY: height * 0.10
        readonly property real progress: moodTransitionProgress
        readonly property real travelX: startX + ((endX - startX) * progress)
        readonly property real travelY: startY + ((endY - startY) * progress) - (Math.sin(progress * Math.PI) * 78)
        readonly property real arcOffset: Math.sin(progress * Math.PI) * (moodTransitionToCursed ? 58 : -58)
        readonly property real blend: moodTransitionToCursed ? progress : (1.0 - progress)

        Item {
            x: parent.travelX + parent.arcOffset
            y: parent.travelY
            width: 220
            height: 255
            scale: 1.0 + (blend * 0.35)

            Rectangle {
                anchors.centerIn: parent
                width: 160 * (1.0 - (blend * 0.18))
                height: width
                radius: width / 2
                opacity: 1.0 - blend

                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#EAF3E6" }
                    GradientStop { position: 0.55; color: "#D6EACC" }
                    GradientStop { position: 1.0; color: "#B8D9A0" }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: 80
                    height: 96
                    radius: 10
                    color: "#D6EACC"
                    border.width: 2
                    border.color: "#5C8B4A"
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 38
                    width: 64
                    height: 30
                    radius: 10
                    color: "#C2DBA8"
                    border.width: 2
                    border.color: "#5C8B4A"
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 68
                    width: 64
                    height: 2
                    color: "#5C8B4A"
                }

                Rectangle {
                    x: 66
                    y: 58
                    width: 12
                    height: 12
                    radius: 6
                    color: "#2A4A2E"
                }

                Rectangle {
                    x: 82
                    y: 58
                    width: 12
                    height: 12
                    radius: 6
                    color: "#2A4A2E"
                }
            }

            Item {
                anchors.fill: parent
                opacity: blend

                Image {
                    anchors.centerIn: parent
                    width: 180
                    height: 220
                    source: "qrc:/qt/qml/FungerGames/assets/cursed-fridge-face.svg"
                    fillMode: Image.PreserveAspectFit
                    sourceSize.width: 360
                    sourceSize.height: 440
                    asynchronous: true
                }
            }
        }
    }

    component AlarmActionButton: Button {
        id: alarmButton
        required property string labelText
        property color borderColor: accentColor
        property color fillColor: accentSurface
        property color textColor: accentColor

        text: labelText
        padding: 0
        enabled: true

        contentItem: Label {
            text: alarmButton.text
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: alarmButton.enabled ? alarmButton.textColor : "#401C1612"
            font.family: "DM Sans"
            font.pixelSize: 13
            font.weight: 500
        }

        background: Rectangle {
            radius: 10
            border.width: 1
            border.color: alarmButton.enabled ? alarmButton.borderColor : "#1A1C1612"
            color: alarmButton.enabled ? alarmButton.fillColor : "#081C1612"
        }
    }

    component AlarmOverlay: Rectangle {
        color: "#D10A0804"

        Rectangle {
            anchors.centerIn: parent
            width: 420
            height: 520
            radius: 18
            color: "#180F06"
            border.width: 1
            border.color: "#808B2B18"

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 0
                width: 200
                height: 80
                radius: 40
                color: "#00FFFFFF"

                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#2EC4742A" }
                    GradientStop { position: 1.0; color: "#00C4742A" }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 32
                spacing: 16

                Label {
                    Layout.fillWidth: true
                    text: qsTr("FungerGames")
                    horizontalAlignment: Text.AlignHCenter
                    color: "#66C8B89A"
                    font.family: "DM Mono"
                    font.pixelSize: 10
                    font.letterSpacing: 2.2
                    font.capitalization: Font.AllUppercase
                }

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Alarm Duel")
                    horizontalAlignment: Text.AlignHCenter
                    color: "#C8B89A"
                    font.family: "Playfair Display"
                    font.pixelSize: 28
                    font.italic: true
                    font.weight: 500
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: "#00FFFFFF"

                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#00C4742A" }
                        GradientStop { position: 0.3; color: "#59C4742A" }
                        GradientStop { position: 0.7; color: "#59C4742A" }
                        GradientStop { position: 1.0; color: "#00C4742A" }
                    }
                }

                Item {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 56
                    Layout.preferredHeight: 68

                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: "#2C1E0E"
                        border.width: 2
                        border.color: "#6B3A1F"
                    }

                    Rectangle {
                        width: parent.width
                        height: 22
                        radius: 8
                        color: "#251809"
                        border.width: 2
                        border.color: "#6B3A1F"
                    }

                    Rectangle {
                        x: 0
                        y: 25
                        width: parent.width
                        height: 1
                        color: "#6B3A1F"
                    }

                    Rectangle {
                        x: 15
                        y: 36
                        width: 10
                        height: 12
                        radius: 5
                        color: "#6B1A08"
                    }

                    Rectangle {
                        x: 31
                        y: 36
                        width: 10
                        height: 12
                        radius: 5
                        color: "#6B1A08"
                    }

                    Rectangle {
                        x: 18
                        y: 39
                        width: 4
                        height: 5
                        radius: 2
                        color: "#1A0800"
                    }

                    Rectangle {
                        x: 34
                        y: 39
                        width: 4
                        height: 5
                        radius: 2
                        color: "#1A0800"
                    }

                }

                Label {
                    Layout.fillWidth: true
                    text: appController.challengeStatus
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    color: "#A6C8B89A"
                    font.family: "DM Sans"
                    font.pixelSize: 13
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 14
                    radius: 7
                    color: "#0FFFFFFF"
                    border.width: 1
                    border.color: "#4D8B2B18"

                    Rectangle {
                        x: width * 0.42
                        width: width * 0.18
                        height: parent.height
                        radius: 7
                        color: "#40C4742A"
                        border.width: 0
                    }

                    Rectangle {
                        visible: appController.strikeWindowOpen
                        x: width * 0.49
                        width: 3
                        height: parent.height
                        color: "#C8B89A"
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("TOO EARLY")
                        color: "#4DC8B89A"
                        font.family: "DM Mono"
                        font.pixelSize: 9
                    }

                    Label {
                        text: qsTr("STRIKE ZONE")
                        color: "#80C4742A"
                        font.family: "DM Mono"
                        font.pixelSize: 9
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("TOO LATE")
                        horizontalAlignment: Text.AlignRight
                        color: "#4DC8B89A"
                        font.family: "DM Mono"
                        font.pixelSize: 9
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

                AlarmActionButton {
                    Layout.fillWidth: true
                    labelText: appController.strikeWindowOpen ? qsTr("Strike") : qsTr("Hold")
                    borderColor: appController.strikeWindowOpen ? "#B3C4742A" : "#808B2B18"
                    fillColor: appController.strikeWindowOpen ? "#33C4742A" : "#268B2B18"
                    textColor: "#C4742A"
                    onClicked: appController.attemptChallenge()
                }
            }
        }
    }

    Component {
        id: calmMoodComponent

        Item {
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 28

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 160
                    height: 160
                    radius: 80

                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#EAF3E6" }
                        GradientStop { position: 0.55; color: "#D6EACC" }
                        GradientStop { position: 1.0; color: "#B8D9A0" }
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: 80
                        height: 96
                        radius: 10
                        color: "#D6EACC"
                        border.width: 2
                        border.color: "#5C8B4A"
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 38
                        width: 64
                        height: 30
                        radius: 10
                        color: "#C2DBA8"
                        border.width: 2
                        border.color: "#5C8B4A"
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 68
                        width: 64
                        height: 2
                        color: "#5C8B4A"
                    }

                    Rectangle {
                        x: 66
                        y: 58
                        width: 12
                        height: 12
                        radius: 6
                        color: "#2A4A2E"
                    }

                    Rectangle {
                        x: 82
                        y: 58
                        width: 12
                        height: 12
                        radius: 6
                        color: "#2A4A2E"
                    }

                    Rectangle {
                        x: 70
                        y: 61
                        width: 4
                        height: 4
                        radius: 2
                        color: "#FFFFFF"
                    }

                    Rectangle {
                        x: 86
                        y: 61
                        width: 4
                        height: 4
                        radius: 2
                        color: "#FFFFFF"
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 82
                        width: 26
                        height: 10
                        radius: 5
                        color: "#2A4A2E"
                    }
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 6

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("Good job today.")
                        color: "#2A4A2E"
                        font.family: "Playfair Display"
                        font.pixelSize: 22
                        font.weight: 500
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("You're %1 kcal under your limit. Your fridge is pleased with you.")
                              .arg(String(Math.max(0, dailyLimit - dailyCalories)))
                        color: "#A62A4A2E"
                        font.family: "DM Sans"
                        font.pixelSize: 13
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 280
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true

                        Label {
                            Layout.fillWidth: true
                            text: qsTr("%1 kcal consumed").arg(String(dailyCalories))
                            color: "#731C1612"
                            font.family: "DM Mono"
                            font.pixelSize: 10
                        }

                        Label {
                            text: qsTr("%1 limit").arg(String(dailyLimit))
                            color: "#731C1612"
                            font.family: "DM Mono"
                            font.pixelSize: 10
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 6
                        radius: 3
                        color: "#265C8B4A"

                        Rectangle {
                            width: parent.width * calmProgress
                            height: parent.height
                            radius: 3

                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "#5C8B4A" }
                                GradientStop { position: 1.0; color: "#7DB868" }
                            }
                        }
                    }
                }

                Flow {
                    Layout.alignment: Qt.AlignHCenter
                    width: 260
                    spacing: 8

                    Repeater {
                        model: [qsTr("Hydrated"), qsTr("On Track"), qsTr("Macro Balance")]

                        Rectangle {
                            required property string modelData
                            width: pillLabel.implicitWidth + 24
                            height: 28
                            radius: 14
                            color: modelData === qsTr("Macro Balance") ? "#107A7060" : "#105C8B4A"
                            border.width: 1
                            border.color: modelData === qsTr("Macro Balance") ? "#337A7060" : "#335C8B4A"

                            Label {
                                id: pillLabel
                                anchors.centerIn: parent
                                text: modelData
                                color: modelData === qsTr("Macro Balance") ? "#7A7060" : "#5C8B4A"
                                font.family: "DM Mono"
                                font.pixelSize: 10
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: cursedMoodComponent

        Item {
            property bool blink: false

            Timer {
                interval: 3200
                running: true
                repeat: true
                onTriggered: parent.blink = !parent.blink
            }

            Rectangle {
                anchors.fill: parent
                color: "#00000000"

                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#1F8B2B18" }
                    GradientStop { position: 1.0; color: "#008B2B18" }
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                function sendTarget(mx, my) {
                    if (width <= 0 || height <= 0) {
                        return
                    }

                    appController.sendFaceTrackingTarget(mx / width, my / height)
                }

                onPositionChanged: function(mouse) {
                    sendTarget(mouse.x, mouse.y)
                }
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20

                Item {
                    Layout.alignment: Qt.AlignHCenter
                    width: 220
                    height: 255
                    scale: cursedScale

                    Behavior on scale {
                        NumberAnimation { duration: 600; easing.type: Easing.OutBack }
                    }

                    Image {
                        anchors.centerIn: parent
                        width: 180
                        height: 220
                        source: "qrc:/qt/qml/FungerGames/assets/cursed-fridge-face.svg"
                        fillMode: Image.PreserveAspectFit
                        sourceSize.width: 360
                        sourceSize.height: 440
                        asynchronous: true
                    }

                    Rectangle {
                        x: 84 + eyeOffsetX
                        y: 120 + eyeOffsetY
                        width: 16
                        height: blink ? 4 : 20
                        radius: 8
                        color: "#1A0800"
                    }

                    Rectangle {
                        x: 120 + eyeOffsetX
                        y: 120 + eyeOffsetY
                        width: 16
                        height: blink ? 4 : 20
                        radius: 8
                        color: "#1A0800"
                    }

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        text: qsTr("IT IS WATCHING")
                        color: "#998B2B18"
                        font.family: "DM Mono"
                        font.pixelSize: 9
                        font.letterSpacing: 2.0
                        font.capitalization: Font.AllUppercase
                    }
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 6

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("You have sinned, %1 kcal over.").arg(String(calorieOverage))
                        color: "#C4742A"
                        font.family: "Playfair Display"
                        font.pixelSize: 18
                        font.italic: true
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("The fridge remembers. It always remembers.")
                        color: "#80C8B89A"
                        font.family: "DM Sans"
                        font.pixelSize: 12
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 260
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true

                        Label {
                            Layout.fillWidth: true
                            text: qsTr("%1 limit").arg(String(dailyLimit))
                            color: "#59C8B89A"
                            font.family: "DM Mono"
                            font.pixelSize: 10
                        }

                        Label {
                            text: qsTr("+%1 over").arg(String(calorieOverage))
                            color: "#59C8B89A"
                            font.family: "DM Mono"
                            font.pixelSize: 10
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 5
                        radius: 3
                        color: "#338B2B18"

                        Rectangle {
                            width: parent.width * overageProgress
                            height: parent.height
                            radius: 3

                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "#8B2B18" }
                                GradientStop { position: 1.0; color: "#C4742A" }
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent

        gradient: Gradient {
            GradientStop { position: 0.0; color: bgStart }
            GradientStop { position: 0.55; color: bgMid }
            GradientStop { position: 1.0; color: bgEnd }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 72
            color: "#00000000"
            border.width: 0

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 1
                color: headerBorder
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 32
                anchors.rightMargin: 32
                spacing: 16

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        radius: 8

                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: overLimit ? "#8B2B18" : "#2A4A2E" }
                            GradientStop { position: 1.0; color: overLimit ? "#C4742A" : "#5C8B4A" }
                        }

                        Canvas {
                            anchors.centerIn: parent
                            width: 18
                            height: 18
                            onPaint: {
                                const ctx = getContext("2d")
                                ctx.clearRect(0, 0, width, height)
                                ctx.strokeStyle = "white"
                                ctx.lineWidth = 1.5
                                ctx.strokeRect(3, 2, 12, 14)
                                ctx.beginPath()
                                ctx.moveTo(3, 7)
                                ctx.lineTo(15, 7)
                                ctx.stroke()
                                ctx.beginPath()
                                ctx.arc(6.5, 11, 1.5, 0, Math.PI * 2)
                                ctx.arc(11.5, 11, 1.5, 0, Math.PI * 2)
                                ctx.fillStyle = "white"
                                ctx.fill()
                            }
                        }
                    }

                    ColumnLayout {
                        spacing: 1

                        Label {
                            text: qsTr("FungerGames Fridge Watch")
                            color: titleColor
                            font.family: "Playfair Display"
                            font.pixelSize: 18
                            font.weight: 500
                        }

                        Label {
                            text: headerSubtitle
                            color: subtitleColor
                            font.family: "DM Sans"
                            font.pixelSize: 12
                        }
                    }
                }

                ModePill {
                    labelText: modeLabel
                }

                HeaderButton {
                    labelText: overLimit ? qsTr("Restore Calm") : qsTr("Watching")
                    enabled: false
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 32
            Layout.rightMargin: 32
            Layout.topMargin: 20
            spacing: 12

            StatCard {
                labelText: qsTr("Daily Calories")
                valueText: String(dailyCalories)
                unitText: qsTr("kcal")
                deltaText: deltaTextForCalories()
                deltaPositive: !overLimit
            }

            StatCard {
                labelText: qsTr("Daily Limit")
                valueText: String(dailyLimit)
                unitText: qsTr("kcal")
            }

            StatCard {
                labelText: deficitLabel()
                valueText: String(Math.abs(overLimit ? calorieOverage : dailyDeficit))
                unitText: qsTr("kcal")
                deltaText: overLimit ? qsTr("Limit breached") : qsTr("Great restraint")
                deltaPositive: !overLimit
            }

            StatCard {
                labelText: qsTr("Latest Event")
                valueText: latestContentType
                unitText: String(eventCalories) + qsTr(" kcal")
                deltaText: deltaTextForEvent()
                deltaPositive: !overLimit
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 32
            Layout.rightMargin: 32
            Layout.topMargin: 16
            Layout.bottomMargin: 24
            spacing: 16

            Frame {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 720
                background: Rectangle {
                    radius: 16
                    color: panelColor
                    border.width: 1
                    border.color: panelBorder
                }

                contentItem: ColumnLayout {
                    spacing: 0

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48
                        color: "#00000000"

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: 1
                            color: panelBorder
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 20
                            anchors.rightMargin: 20

                            Label {
                                text: qsTr("Fridge Mood")
                                color: mutedText
                                font.family: "DM Mono"
                                font.pixelSize: 9
                                font.letterSpacing: 1.8
                                font.capitalization: Font.AllUppercase
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Label {
                                text: overLimit ? qsTr("CURSED") : qsTr("CALM")
                                color: accentColor
                                font.family: "DM Mono"
                                font.pixelSize: 9
                                font.letterSpacing: 0.8
                            }
                        }
                    }

                    Loader {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        active: overLimit && !moodTransitionActive
                        asynchronous: true
                        sourceComponent: cursedMoodComponent
                    }

                    Loader {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        active: !overLimit && !moodTransitionActive
                        asynchronous: true
                        sourceComponent: calmMoodComponent
                    }

                    Loader {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        active: moodTransitionActive
                        asynchronous: true
                        sourceComponent: MoodTransitionOverlay {}
                    }
                }
            }

            ColumnLayout {
                Layout.preferredWidth: 300
                Layout.maximumWidth: 320
                Layout.minimumWidth: 280
                Layout.fillHeight: true
                spacing: 10

                Label {
                    text: qsTr("Alarm Clock")
                    color: mutedText
                    font.family: "DM Mono"
                    font.pixelSize: 9
                    font.letterSpacing: 1.8
                    font.capitalization: Font.AllUppercase
                }

                Frame {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    background: Rectangle {
                        radius: 14
                        color: overLimit ? "#E6221A0E" : "#EBFDFAF4"
                        border.width: 1
                        border.color: panelBorder
                    }

                    contentItem: ColumnLayout {
                        spacing: 16

                        Frame {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 240
                            background: Rectangle {
                                radius: 14
                                color: overLimit ? "#E6221A0E" : "#EBFDFAF4"
                                border.width: 1
                                border.color: panelBorder
                            }

                            contentItem: ColumnLayout {
                                spacing: 12

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    radius: 14
                                    color: "#00000000"

                                    Rectangle {
                                        anchors.fill: parent
                                        visible: alarmActive
                                        radius: 14
                                        color: "#00000000"

                                        gradient: Gradient {
                                            GradientStop { position: 0.0; color: overLimit ? "#268B2B18" : "#1A5C8B4A" }
                                            GradientStop { position: 1.0; color: "#00000000" }
                                        }
                                    }

                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: 12

                                        Label {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: alarmActive ? qsTr("\u26a1 ALARM ACTIVE") : qsTr("Next Alarm")
                                            color: mutedText
                                            font.family: "DM Mono"
                                            font.pixelSize: 9
                                            font.letterSpacing: 1.8
                                            font.capitalization: Font.AllUppercase
                                        }

                                        Label {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: appController ? appController.alarmDisplay : qsTr("--:--")
                                            color: alarmActive ? accentColor : titleColor
                                            font.family: "Playfair Display"
                                            font.pixelSize: 30
                                            font.weight: 500
                                            wrapMode: Text.Wrap
                                            horizontalAlignment: Text.AlignHCenter
                                        }

                                        Label {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: alarmActive ? qsTr("Wake up. Now.") : qsTr("Tomorrow - Weekday")
                                            color: softText
                                            font.family: "DM Sans"
                                            font.pixelSize: 12
                                        }
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.fillHeight: true
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            AlarmActionButton {
                                Layout.fillWidth: true
                                labelText: alarmActive ? qsTr("Re-trigger") : qsTr("Test Alarm")
                                onClicked: appController.triggerAlarm()
                            }

                            AlarmActionButton {
                                Layout.fillWidth: true
                                labelText: qsTr("Dismiss")
                                enabled: alarmActive
                                borderColor: overLimit ? "#998B2B18" : "#401C1612"
                                fillColor: overLimit ? "#408B2B18" : "#141C1612"
                                textColor: overLimit ? "#C4742A" : "#1C1612"
                                onClicked: appController.requestAlarmDismissal()
                            }
                        }

                        Frame {
                            Layout.fillWidth: true
                            background: Rectangle {
                                radius: 10
                                color: overLimit ? "#E6221A0E" : "#EBFDFAF4"
                                border.width: 1
                                border.color: panelBorder
                            }

                            contentItem: ColumnLayout {
                                spacing: 10

                                Label {
                                    Layout.fillWidth: true
                                    text: qsTr("Service Status")
                                    color: mutedText
                                    font.family: "DM Mono"
                                    font.pixelSize: 9
                                    font.letterSpacing: 1.4
                                    font.capitalization: Font.AllUppercase
                                }

                                StatusRow {
                                    labelText: qsTr("Fridge Sensor")
                                    ok: appController ? appController.fridgeServiceConnected : false
                                }

                                StatusRow {
                                    labelText: qsTr("Face Tracking")
                                    ok: appController ? appController.faceServiceConnected : false
                                }

                                StatusRow {
                                    labelText: qsTr("Alarm Bridge")
                                    ok: !overLimit
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Loader {
        anchors.fill: parent
        active: appController && appController.challengeVisible
        asynchronous: true
        sourceComponent: Component {
            AlarmOverlay {}
        }
    }
}
