import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

StyledPopup {
    id: root

    // Helper function to format KB to GB
    function formatKB(kb) {
        return (kb / (1024 * 1024)).toFixed(1) + " GB";
    }

    Row {
        anchors.centerIn: parent
        spacing: 12

        Column {
            anchors.top: parent.top
            spacing: 8

            StyledPopupHeaderRow {
                icon: "memory"
                label: "RAM"
            }
            Column {
                spacing: 4
                StyledPopupValueRow {
                    icon: "clock_loader_60"
                    label: Translation.tr("Used:")
                    value: root.formatKB(ResourceUsage.memoryUsed)
                }
                StyledPopupValueRow {
                    icon: "check_circle"
                    label: Translation.tr("Free:")
                    value: root.formatKB(ResourceUsage.memoryFree)
                }
                StyledPopupValueRow {
                    icon: "empty_dashboard"
                    label: Translation.tr("Total:")
                    value: root.formatKB(ResourceUsage.memoryTotal)
                }
            }
        }

        Column {
            visible: ResourceUsage.swapTotal > 0
            anchors.top: parent.top
            spacing: 8

            StyledPopupHeaderRow {
                icon: "swap_horiz"
                label: "Swap"
            }
            Column {
                spacing: 4
                StyledPopupValueRow {
                    icon: "clock_loader_60"
                    label: Translation.tr("Used:")
                    value: root.formatKB(ResourceUsage.swapUsed)
                }
                StyledPopupValueRow {
                    icon: "check_circle"
                    label: Translation.tr("Free:")
                    value: root.formatKB(ResourceUsage.swapFree)
                }
                StyledPopupValueRow {
                    icon: "empty_dashboard"
                    label: Translation.tr("Total:")
                    value: root.formatKB(ResourceUsage.swapTotal)
                }
            }
        }

        Column {
            anchors.top: parent.top
            spacing: 8

            StyledPopupHeaderRow {
                icon: "planner_review"
                label: "CPU"
            }
            Column {
                spacing: 4
                StyledPopupValueRow {
                    icon: "bolt"
                    label: Translation.tr("Load:")
                    value: `${Math.round(ResourceUsage.cpuUsage * 100)}%`
                }
                StyledPopupValueRow {
                    icon: "thermometer"
                    label: "Temperature"
                    value: ResourceUsage.cpuTemperature !== null
                        ? `${Math.round(ResourceUsage.cpuTemperature)} °C` : "—"
                }
            }
        }
        Column {
            visible: ResourceUsage.gpu !== null
            anchors.top: parent.top
            spacing: 8
            StyledPopupHeaderRow { icon: "developer_board"; label: "GPU" }
            StyledPopupValueRow {
                icon: "bolt"; label: "Load"
                value: `${Math.round((ResourceUsage.gpu?.usage ?? 0) * 100)}%`
            }
            StyledPopupValueRow {
                icon: "memory"; label: "VRAM"
                value: `${((ResourceUsage.gpu?.memoryUsed ?? 0) / 1024).toFixed(1)} / ${((ResourceUsage.gpu?.memoryTotal ?? 0) / 1024).toFixed(1)} GiB`
            }
            StyledPopupValueRow {
                icon: "thermometer"; label: "Temperature"
                value: `${ResourceUsage.gpu?.temperature ?? "--"} °C`
            }
        }
        Column {
            visible: ResourceUsage.disk !== null
            anchors.top: parent.top
            spacing: 8
            StyledPopupHeaderRow { icon: "hard_drive"; label: "Disk /" }
            StyledPopupValueRow {
                icon: "clock_loader_60"; label: "Used"
                value: `${((ResourceUsage.disk?.used ?? 0) / 1073741824).toFixed(1)} GiB`
            }
            StyledPopupValueRow {
                icon: "check_circle"; label: "Free"
                value: `${((ResourceUsage.disk?.free ?? 0) / 1073741824).toFixed(1)} GiB`
            }
            StyledPopupValueRow {
                icon: "empty_dashboard"; label: "Total"
                value: `${((ResourceUsage.disk?.total ?? 0) / 1073741824).toFixed(1)} GiB`
            }
        }

    }
}
