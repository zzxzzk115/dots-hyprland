pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Rectangle {
    id: root
    property real downloadRate: NetworkTraffic.download
    property real uploadRate: NetworkTraffic.upload
    property bool available: NetworkTraffic.available
    property bool connected: available && NetworkTraffic.interfaces.length > 0
    property string connectionName: Network.networkName || "Connected"
    property string launchError: ""
    signal closeRequested()
    signal speedTestRequested()

    implicitWidth: 340
    implicitHeight: content.implicitHeight + 32
    radius: Appearance.rounding.normal
    color: Appearance.m3colors.m3surfaceContainer
    border.width: 1
    border.color: Appearance.colors.colLayer0Border

    component RateTile: Rectangle {
        id: tile
        required property string icon
        required property string label
        required property real rate
        readonly property var rateParts: NetworkTraffic.formatRate(rate).split(" ")

        Layout.fillWidth: true
        Layout.preferredWidth: 1
        implicitHeight: tileContent.implicitHeight + 24
        radius: Appearance.rounding.small
        color: Appearance.m3colors.m3surfaceContainerHigh

        ColumnLayout {
            id: tileContent
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 12
            }
            spacing: 6

            RowLayout {
                spacing: 6
                Rectangle {
                    implicitWidth: 28
                    implicitHeight: 28
                    radius: Appearance.rounding.full
                    color: Appearance.colors.colSecondaryContainer
                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: tile.icon
                        iconSize: Appearance.font.pixelSize.large
                        color: Appearance.m3colors.m3onSecondaryContainer
                    }
                }
                StyledText {
                    text: tile.label
                    color: Appearance.colors.colOnLayer1
                    font.pixelSize: Appearance.font.pixelSize.small
                }
            }
            StyledText {
                Layout.fillWidth: true
                text: root.available ? tile.rateParts[0] : "—"
                font.family: Appearance.font.family.numbers
                font.pixelSize: Appearance.font.pixelSize.huge
                font.weight: Font.DemiBold
                color: Appearance.m3colors.m3onSurface
            }
            StyledText {
                text: tile.rateParts[1]
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.m3colors.m3onSurfaceVariant
            }
        }
    }

    ColumnLayout {
        id: content
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 16
        }
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            StyledPopupHeaderRow {
                Layout.fillWidth: true
                icon: "speed"
                label: "Network speed"
            }
            RippleButton {
                implicitWidth: 28
                implicitHeight: 28
                buttonRadius: Appearance.rounding.full
                Accessible.name: "Close network speed card"
                onClicked: root.closeRequested()
                contentItem: MaterialSymbol {
                    text: "close"
                    iconSize: Appearance.font.pixelSize.large
                    horizontalAlignment: Text.AlignHCenter
                    color: Appearance.m3colors.m3onSurfaceVariant
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            Rectangle {
                implicitWidth: 6
                implicitHeight: 6
                radius: 3
                color: root.connected ? Appearance.colors.colPrimary : Appearance.m3colors.m3outline
            }
            StyledText {
                Layout.fillWidth: true
                text: !root.available ? "Loading network status…" : root.connected ? root.connectionName : "Disconnected"
                elide: Text.ElideRight
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.m3colors.m3onSurfaceVariant
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            RateTile {
                icon: "arrow_downward"
                label: "Download"
                rate: root.downloadRate
            }
            RateTile {
                icon: "arrow_upward"
                label: "Upload"
                rate: root.uploadRate
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Appearance.colors.colLayer0Border
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                StyledText {
                    text: "Speed test"
                    color: Appearance.m3colors.m3onSurface
                    font.pixelSize: Appearance.font.pixelSize.small
                }
                StyledText {
                    text: "Cloudflare · Opens in browser"
                    color: Appearance.m3colors.m3onSurfaceVariant
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }
            }
            RippleButton {
                implicitWidth: 84
                implicitHeight: 36
                colBackground: Appearance.colors.colSecondaryContainer
                colBackgroundHover: Appearance.colors.colSecondaryContainerHover
                colRipple: Appearance.colors.colSecondaryContainerActive
                Accessible.name: "Open speed test page"
                onClicked: root.speedTestRequested()
                contentItem: RowLayout {
                    spacing: 5
                    StyledText {
                        Layout.fillWidth: true
                        text: "Test speed"
                        horizontalAlignment: Text.AlignRight
                        color: Appearance.m3colors.m3onSecondaryContainer
                    }
                    MaterialSymbol {
                        text: "open_in_new"
                        iconSize: Appearance.font.pixelSize.normal
                        color: Appearance.m3colors.m3onSecondaryContainer
                    }
                }
            }
        }

        StyledText {
            Layout.fillWidth: true
            visible: root.launchError.length > 0
            text: root.launchError
            wrapMode: Text.Wrap
            color: Appearance.colors.colError
            font.pixelSize: Appearance.font.pixelSize.smaller
        }
    }
}
