pragma ComponentBehavior: Bound
import qs
import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Scope {
    id: root

    function dismiss() {
        screenshotRequest.stop();
        GlobalStates.regionSelectorOpen = false
    }

    property string autoScreenName: ""
    property var action: RegionSelection.SnipAction.Copy
    property var selectionMode: RegionSelection.SelectionMode.RectCorners
    
    Variants {
        model: Quickshell.screens
        delegate: Loader {
            id: regionSelectorLoader
            required property var modelData
            active: GlobalStates.regionSelectorOpen && (root.autoScreenName === "" || modelData.name === root.autoScreenName)

            sourceComponent: RegionSelection {
                screen: regionSelectorLoader.modelData
                autoCaptureScreen: root.autoScreenName !== ""
                onDismiss: root.dismiss()
                action: root.action
                selectionMode: root.selectionMode
            }
        }
    }

    // Hide any existing overlay before freezing pixels for a new request.
    property var pendingMode: RegionSelection.SelectionMode.RectCorners
    property string pendingScreen: ""
    Timer {
        id: screenshotRequest
        interval: 120
        onTriggered: {
            root.action = RegionSelection.SnipAction.Copy;
            root.selectionMode = root.pendingMode;
            root.autoScreenName = root.pendingScreen;
            GlobalStates.regionSelectorOpen = true;
        }
    }
    function requestScreenshot(mode, screenName) {
        GlobalStates.regionSelectorOpen = false;
        root.pendingMode = mode;
        root.pendingScreen = screenName;
        screenshotRequest.restart();
    }
    function screenshot() {
        root.requestScreenshot(RegionSelection.SelectionMode.RectCorners, "");
    }
    function screenshotWindow() {
        root.requestScreenshot(RegionSelection.SelectionMode.Window, "");
    }
    function screenshotScreen() {
        root.requestScreenshot(RegionSelection.SelectionMode.Screen, Hyprland.focusedMonitor?.name ?? "");
    }

    function search() {
        root.autoScreenName = "";
        root.action = RegionSelection.SnipAction.Search
        if (Config.options.search.imageSearch.useCircleSelection) {
            root.selectionMode = RegionSelection.SelectionMode.Circle
        } else {
            root.selectionMode = RegionSelection.SelectionMode.RectCorners
        }
        GlobalStates.regionSelectorOpen = true
    }

    function ocr() {
        root.autoScreenName = "";
        root.action = RegionSelection.SnipAction.CharRecognition
        root.selectionMode = RegionSelection.SelectionMode.RectCorners
        GlobalStates.regionSelectorOpen = true
    }

    function record() {
        root.autoScreenName = "";
        root.action = RegionSelection.SnipAction.Record
        root.selectionMode = RegionSelection.SelectionMode.RectCorners
        // If already open then re-trigger to stop recording
        if (GlobalStates.regionSelectorOpen) GlobalStates.regionSelectorOpen = false
        GlobalStates.regionSelectorOpen = true
    }

    function recordWithSound() {
        root.autoScreenName = "";
        root.action = RegionSelection.SnipAction.RecordWithSound
        root.selectionMode = RegionSelection.SelectionMode.RectCorners
        // If already open then re-trigger to stop recording
        if (GlobalStates.regionSelectorOpen) GlobalStates.regionSelectorOpen = false
        GlobalStates.regionSelectorOpen = true
    }

    IpcHandler {
        target: "region"

        function screenshot() {
            root.screenshot()
        }
        function windowScreenshot() { root.screenshotWindow(); }
        function screenScreenshot() { root.screenshotScreen(); }
        function close() { root.dismiss(); }
        function search() {
            root.search()
        }
        function ocr() {
            root.ocr()
        }
        function record() {
            root.record()
        }
        function recordWithSound() {
            root.recordWithSound()
        }
    }

    GlobalShortcut {
        name: "windowScreenshot"
        description: "Select a window to screenshot"
        onPressed: root.screenshotWindow()
    }
    GlobalShortcut {
        name: "screenScreenshot"
        description: "Screenshot the focused screen"
        onPressed: root.screenshotScreen()
    }
    GlobalShortcut {
        name: "regionScreenshot"
        description: "Takes a screenshot of the selected region"
        onPressed: root.screenshot()
    }
    GlobalShortcut {
        name: "regionSearch"
        description: "Searches the selected region"
        onPressed: root.search()
    }
    GlobalShortcut {
        name: "regionOcr"
        description: "Recognizes text in the selected region"
        onPressed: root.ocr()
    }
    GlobalShortcut {
        name: "regionRecord"
        description: "Records the selected region"
        onPressed: root.record()
    }
    GlobalShortcut {
        name: "regionRecordWithSound"
        description: "Records the selected region with sound"
        onPressed: root.recordWithSound()
    }
}
