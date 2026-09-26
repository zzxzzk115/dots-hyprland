import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.modules.common
import qs.modules.common.widgets
Item {
 id: root
 readonly property string userHome: Quickshell.env("HOME")
 property var snapshot: ({text:"—",detail:"Waiting for usage data",class:"stale"})
 implicitWidth: 48; implicitHeight: 28
 Process {id:reader;command:[root.userHome + "/.local/bin/codex-usage","--status"];running:true
  stdout: StdioCollector {onStreamFinished: {try {root.snapshot=JSON.parse(text);} catch(e) {}}}
 }
 Timer {interval:30000;repeat:true;running:true;onTriggered:if (!reader.running) reader.running=true}
 StyledText {anchors.centerIn:parent;text:root.snapshot.text
  color:root.snapshot.class === "stale" ? "#888888" : root.snapshot.class === "critical" ? "#ef5350" : root.snapshot.class === "warning" ? "#ffca28" : Appearance.colors.colOnLayer0
 }
 MouseArea {id:mouse;anchors.fill:parent;hoverEnabled:true
  onClicked:Quickshell.execDetached(["env","-u","LD_LIBRARY_PATH","-u","QT_PLUGIN_PATH","-u","QML_IMPORT_PATH","XDG_CONFIG_HOME=" + root.userHome + "/.config","XDG_STATE_HOME=" + root.userHome + "/.local/state","XDG_CACHE_HOME=" + root.userHome + "/.cache",root.userHome + "/.local/bin/codex-usage","--details"])
 }
 StyledPopup {
  hoverTarget: mouse
  active: mouse.containsMouse && !mouse.pressed
  StyledText {
   anchors.centerIn: parent
   text: root.snapshot.detail
   font.pixelSize: Appearance.font.pixelSize.smaller
   color: Appearance.m3colors.m3onSurfaceVariant
  }
 }
}
