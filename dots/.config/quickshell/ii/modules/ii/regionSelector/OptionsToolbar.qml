pragma ComponentBehavior: Bound
import qs
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

// Options toolbar
Toolbar {
    id: root

    // Use a synchronizer on these
    property var action
    property var selectionMode
    // Signals
    signal dismiss()

    signal screenRequested()
    RowLayout {
        spacing: 4
        Repeater {
            model: [
                {icon: "activity_zone", label: "Region", mode: RegionSelection.SelectionMode.RectCorners},
                {icon: "select_window", label: "Window", mode: RegionSelection.SelectionMode.Window},
                {icon: "screenshot_monitor", label: "Current screen", mode: RegionSelection.SelectionMode.Screen},
                {icon: "gesture", label: "Circle", mode: RegionSelection.SelectionMode.Circle}
            ]
            delegate: ToolbarTabButton {
                required property var modelData
                text: modelData.label
                materialSymbol: modelData.icon
                current: root.selectionMode === modelData.mode
                onClicked: {
                    root.selectionMode = modelData.mode;
                    if (modelData.mode === RegionSelection.SelectionMode.Screen)
                        root.screenRequested();
                }
            }
        }
    }
}
