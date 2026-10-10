pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root
    readonly property string userHome: Quickshell.env("HOME")
    property var snapshot: ({text: "—", detail: "Waiting for usage data", class: "stale", windows: []})
    implicitWidth: 48
    implicitHeight: 28
    function reload() { if (!reader.running) reader.running = true }
    function runAction(name) {
        if (actionProc.running) return;
        actionProc.command = ["env", "-u", "LD_LIBRARY_PATH", "-u", "QT_PLUGIN_PATH", "-u", "QML_IMPORT_PATH",
            "XDG_CONFIG_HOME=" + userHome + "/.config", "XDG_STATE_HOME=" + userHome + "/.local/state",
            "XDG_CACHE_HOME=" + userHome + "/.cache", userHome + "/.local/bin/codex-usage", "--action", name];
        actionProc.running = true;
    }
    Process {
        id: reader
        command: [root.userHome + "/.local/bin/codex-usage", "--status"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: { try { root.snapshot = JSON.parse(text) } catch (e) {} }
        }
    }
    Process { id: actionProc; onExited: root.reload() }
    Timer { interval: popupLoader.active ? 2000 : 30000; repeat: true; running: true; onTriggered: root.reload() }
    StyledText {
        anchors.centerIn: parent
        text: root.snapshot.text
        color: root.snapshot.class === "stale" ? "#888888" : root.snapshot.class === "critical" ? "#ef5350" : root.snapshot.class === "warning" ? "#ffca28" : Appearance.colors.colOnLayer0
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: { popupLoader.active = !popupLoader.active; root.reload() }
        Accessible.name: "Codex quick actions"
    }
    StyledPopup {
        hoverTarget: mouse
        active: mouse.containsMouse && !mouse.pressed && !popupLoader.active
        StyledText {
            anchors.centerIn: parent
            text: root.snapshot.detail + "\n\nClick for quick actions"
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
            implicitWidth: 400
            implicitHeight: content.implicitHeight + 32
            anchor {
                item: root
                edges: Config.options.bar.bottom ? Edges.Top : Edges.Bottom
                gravity: Config.options.bar.bottom ? Edges.Top : Edges.Bottom
                adjustment: PopupAdjustment.SlideX | PopupAdjustment.SlideY
            }
            HyprlandFocusGrab { active: popup.visible; windows: [popup]; onCleared: popupLoader.active = false }
            Rectangle {
                anchors.fill: parent
                radius: Appearance.rounding.normal
                color: Appearance.m3colors.m3surfaceContainer
                border.width: 1
                border.color: Appearance.colors.colLayer0Border
                focus: true
                Keys.onEscapePressed: popupLoader.active = false
                ColumnLayout {
                    id: content
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
                    spacing: 10
                    StyledText { text: "Codex"; font.pixelSize: 18; font.bold: true }
                    StyledText {
                        Layout.fillWidth: true
                        visible: root.snapshot.stale === true
                        text: "Usage data is unavailable or stale. Refresh to check."
                        wrapMode: Text.Wrap
                        font.pixelSize: 12
                    }
                    Repeater {
                        model: root.snapshot.windows ?? []
                        ColumnLayout {
                            required property var modelData
                            Layout.fillWidth: true
                            spacing: 2
                            StyledText { text: modelData.name + " · " + Math.round(modelData.remaining) + "% remaining"; font.pixelSize: 13 }
                            StyledText {
                                text: "Resets in " + modelData.countdown + " · " + modelData.resetTime
                                font.pixelSize: 11
                                color: Appearance.colors.colSubtext
                            }
                        }
                    }
                    StyledText {
                        Layout.fillWidth: true
                        text: (root.snapshot.news?.message ?? "Loading reset news") + "\nLast reset: " + (root.snapshot.news?.lastReset ?? "Unknown")
                        textFormat: Text.PlainText
                        wrapMode: Text.Wrap
                        font.pixelSize: 12
                    }
                    StyledText {
                        Layout.fillWidth: true
                        visible: (root.snapshot.news?.summary ?? "") !== ""
                        text: root.snapshot.news?.summary ?? ""
                        textFormat: Text.PlainText
                        wrapMode: Text.Wrap
                        maximumLineCount: 4
                        elide: Text.ElideRight
                        font.pixelSize: 11
                    }
                    StyledText {
                        text: 'Data: <a href="https://codex-reset.com/zh/">codex-reset.com</a> · independent tracker'
                        textFormat: Text.RichText
                        font.pixelSize: 11
                        onLinkActivated: root.runAction("reset-site")
                    }
                    Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Appearance.colors.colLayer0Border }
                    Repeater {
                        model: [
                            {label: "Open Codex", action: "open"},
                            {label: "Refresh usage and news", action: "refresh"},
                            {label: "Open usage page", action: "usage"},
                            {label: "Codex Reset · website", action: "reset-site"},
                            {label: "Reset announcement · X source", action: "reset-source"},
                            {label: root.snapshot.remindersEnabled ? "Reset reminders: On" : "Reset reminders: Off", action: "toggle-reminders"},
                            {label: root.snapshot.snoozed ? "Resume reminders" : "Snooze reminders for 24 hours", action: root.snapshot.snoozed ? "resume" : "snooze"}
                        ]
                        RippleButton {
                            id: actionButton
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 34
                            buttonRadius: 8
                            enabled: !actionProc.running && (modelData.action !== "reset-source" || !!root.snapshot.news?.url)
                            onClicked: root.runAction(modelData.action)
                            contentItem: StyledText { text: actionButton.modelData.label; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter }
                        }
                    }
                    StyledText {
                        Layout.fillWidth: true
                        text: "Alerts: new announced reset windows with ≥10% usage remaining. Historical predictions and banked resets do not trigger alerts."
                        wrapMode: Text.Wrap
                        font.pixelSize: 11
                        color: Appearance.colors.colSubtext
                    }
                }
            }
        }
    }
}
