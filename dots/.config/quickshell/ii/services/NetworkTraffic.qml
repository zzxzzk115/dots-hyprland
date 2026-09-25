pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property real download: 0
    property real upload: 0
    property var interfaces: []
    property bool available: false

    function formatRate(bytes) {
        if (bytes >= 1024 * 1024 * 1024)
            return (bytes / (1024 * 1024 * 1024)).toFixed(1) + " GiB/s";
        if (bytes >= 1024 * 1024)
            return (bytes / (1024 * 1024)).toFixed(1) + " MiB/s";
        return (bytes / 1024).toFixed(bytes >= 102400 ? 0 : 1) + " KiB/s";
    }

    Process {
        id: sampler
        command: ["python3", "-u", Qt.resolvedUrl("../scripts/network_speed.py").toString().replace(/^file:\/\//, "")]
        running: true
        stdout: SplitParser {
            onRead: line => {
                try {
                    const sample = JSON.parse(line);
                    root.download = Math.max(0, Number(sample.download) || 0);
                    root.upload = Math.max(0, Number(sample.upload) || 0);
                    root.interfaces = sample.interfaces || [];
                    root.available = true;
                } catch (error) {
                    root.available = false;
                }
            }
        }
        onExited: {
            root.available = false;
            root.download = root.upload = 0;
        }
    }

    Timer {
        interval: 5000
        running: !sampler.running
        repeat: true
        onTriggered: sampler.running = true
    }

    IpcHandler {
        target: "networkTraffic"
        function status(): string {
            return JSON.stringify({available: root.available, interfaces: root.interfaces,
                                   download: root.download, upload: root.upload});
        }
    }
}
