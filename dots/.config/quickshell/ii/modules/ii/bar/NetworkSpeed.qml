pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.services
import qs.modules.common
import qs.modules.common.widgets

RippleButton {
    id: root
    implicitWidth: 34
    implicitHeight: Appearance.sizes.baseBarHeight - 8
    buttonRadius: Appearance.rounding.full
    toggled: popupLoader.active
    colBackgroundToggled: Appearance.colors.colSecondaryContainer
    colBackgroundToggledHover: Appearance.colors.colSecondaryContainerHover
    colRippleToggled: Appearance.colors.colSecondaryContainerActive
    Accessible.name: "Network speed"
    onClicked: popupLoader.active = !popupLoader.active

    contentItem: MaterialSymbol {
        text: "speed"
        iconSize: Appearance.font.pixelSize.larger
        fill: root.toggled ? 1 : 0
        horizontalAlignment: Text.AlignHCenter
        color: root.toggled ? Appearance.m3colors.m3onSecondaryContainer : Appearance.colors.colOnLayer0
    }

    StyledPopup {
        hoverTarget: root
        active: root.hovered && !root.down && !popupLoader.active

        StyledText {
            anchors.centerIn: parent
            text: "Network speed\n↓ " + (NetworkTraffic.available ? NetworkTraffic.formatRate(NetworkTraffic.download) : "—")
                + "   ↑ " + (NetworkTraffic.available ? NetworkTraffic.formatRate(NetworkTraffic.upload) : "—")
                + "\nClick for details and speed test"
            font.pixelSize: Appearance.font.pixelSize.smaller
            color: Appearance.m3colors.m3onSurfaceVariant
        }
    }

    Loader {
        id: popupLoader
        active: false
        sourceComponent: PopupWindow {
            id: popup
            visible: true
            color: "transparent"
            implicitWidth: card.implicitWidth + Appearance.sizes.elevationMargin * 2
            implicitHeight: card.implicitHeight + Appearance.sizes.elevationMargin * 2
            anchor {
                item: root
                edges: Config.options.bar.bottom ? Edges.Top : Edges.Bottom
                gravity: Config.options.bar.bottom ? Edges.Top : Edges.Bottom
                adjustment: PopupAdjustment.SlideX | PopupAdjustment.SlideY
            }

            HyprlandFocusGrab {
                active: popup.visible
                windows: [popup]
                onCleared: popupLoader.active = false
            }

            StyledRectangularShadow {
                target: card
            }

            NetworkSpeedCard {
                id: card
                anchors.centerIn: parent
                focus: true
                onCloseRequested: popupLoader.active = false
                onSpeedTestRequested: {
                    if (Qt.openUrlExternally("https://speed.cloudflare.com/"))
                        popupLoader.active = false;
                    else
                        launchError = "Could not open browser. Please try again";
                }
                Keys.onEscapePressed: popupLoader.active = false
            }
        }
    }
}
