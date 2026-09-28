pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

Singleton {
    id: root
    property var snapshot: ({})
    property string lastError: ""
    property bool receivedResponse: false
    property var pendingChange: null
    property int failedReads: 0
    property bool fresh: false
    property bool working: false
    readonly property bool busy: (working && worker.changing) || pendingChange !== null
    readonly property string trackKey: OmniLyrics.connected && OmniLyrics.snapshot.available
        ? [OmniLyrics.snapshot.sourceApp, OmniLyrics.snapshot.title, OmniLyrics.snapshot.artist, OmniLyrics.snapshot.album].join("\n") : ""
    readonly property string helper: decodeURIComponent(Qt.resolvedUrl("../scripts/player_favorites.py").toString().replace(/^file:\/\//, ""))

    function matches(player) {
        return snapshot.available === true && OmniLyrics.matchesPlayer(player)
            && OmniLyrics.normalize(snapshot.title) === OmniLyrics.normalize(player.trackTitle)
            && OmniLyrics.normalize(snapshot.artist) === OmniLyrics.normalize(player.trackArtist)
            && OmniLyrics.normalize(snapshot.sourceApp) === OmniLyrics.normalize(OmniLyrics.snapshot.sourceApp);
    }
    function isFavorite(player) { return matches(player) && snapshot.favorite === true; }
    function canToggle(player) { return matches(player) && fresh && !busy; }

    function refresh() {
        if (!trackKey || working || pendingChange !== null) return;
        receivedResponse = false;
        worker.changing = false;
        worker.requestKey = trackKey;
        worker.command = ["python3", helper, "status"];
        working = true;
        worker.running = true;
    }
    function toggle(player) {
        if (!canToggle(player)) return;
        lastError = "";
        const change = {expected: snapshot, key: trackKey, favorite: !snapshot.favorite};
        if (working) pendingChange = change;
        else startChange(change);
    }
    function startChange(change) {
        if (change.key !== trackKey || !fresh || !snapshot.available
            || snapshot.previous?.trackId !== change.expected.previous?.trackId
            || snapshot.previous?.mediaKey !== change.expected.previous?.mediaKey) {
            lastError = "track_changed";
            return;
        }
        receivedResponse = false;
        worker.changing = true;
        worker.requestKey = trackKey;
        worker.command = ["python3", helper, "set", JSON.stringify(change.expected), change.favorite ? "1" : "0"];
        working = true;
        worker.running = true;
    }
    function label(player) {
        if (busy) return "Updating favorite…";
        if (lastError === "track_changed") return "Track changed; refreshing…";
        if (!fresh) return "Check player connection and favorites access in OmniLyrics settings";
        if (lastError) return "Could not confirm favorite status. Please try again";
        return isFavorite(player) ? "Remove from favorites" : "Add to favorites";
    }
    function unavailable(error) {
        fresh = false;
        lastError = error || "unavailable";
        // Keep one transient failure from making the button jump in and out.
        // It remains disabled until a successful read, and never survives a track change.
        failedReads++;
        if (failedReads >= 2 || error === "track_changed" || worker.changing) snapshot = ({});
    }
    onTrackKeyChanged: {
        pendingChange = null;
        snapshot = ({});
        fresh = false;
        failedReads = 0;
        lastError = "";
        refresh();
    }
    Component.onCompleted: refresh()

    Process {
        id: worker
        property bool changing: false
        property string requestKey: ""
        environment: ({ "LD_LIBRARY_PATH": null })
        stdout: SplitParser {
            onRead: line => {
                try {
                    const value = JSON.parse(line);
                    if (typeof value.available !== "boolean") return;
                    root.receivedResponse = true;
                    if (worker.requestKey !== root.trackKey) return;
                    if (value.available) {
                        root.snapshot = value;
                        root.fresh = true;
                        root.failedReads = 0;
                        root.lastError = "";
                    } else root.unavailable(value.error);
                } catch (error) {}
            }
        }
        onExited: {
            root.working = false;
            if (requestKey !== root.trackKey) { Qt.callLater(root.refresh); return; }
            if (!root.receivedResponse) root.unavailable("unavailable");
            if (root.pendingChange !== null) Qt.callLater(() => {
                const change = root.pendingChange;
                if (change === null) return;
                root.startChange(change);
                root.pendingChange = null;
            });
        }
    }
    Timer {
        interval: 5000
        running: root.trackKey !== ""
        repeat: true
        onTriggered: root.refresh()
    }
    IpcHandler {
        target: "playerFavorites"
        function status(): string {
            return JSON.stringify({busy: root.busy, fresh: root.fresh, error: root.lastError, snapshot: root.snapshot});
        }
    }
}
