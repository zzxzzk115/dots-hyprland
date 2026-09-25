import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as P5
PlasmoidItem {
 id: root
 Plasmoid.title: "Codex 额度"
 Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
 property var snapshot: ({text:"—",detail:"等待额度数据",class:"stale"})
 property string reader: "$HOME/.local/bin/codex-usage --status"
 toolTipMainText: "Codex 剩余额度"
 toolTipSubText: snapshot.detail
 preferredRepresentation: compactRepresentation
 P5.DataSource {
  id: dataSource; engine: "executable"; connectedSources: [root.reader]; interval: 30000
  onNewData: function(sourceName,data) { if (sourceName === root.reader) {try {root.snapshot=JSON.parse(data.stdout);} catch(e) {}} else disconnectSource(sourceName); }
 }
 compactRepresentation: Item {
  implicitWidth: 48; implicitHeight: 24
  Layout.minimumWidth: 48
  Text { anchors.centerIn: parent; text:root.snapshot.text; font:Kirigami.Theme.defaultFont
   color: root.snapshot.class === "stale" ? Kirigami.Theme.disabledTextColor : root.snapshot.class === "critical" ? Kirigami.Theme.negativeTextColor : root.snapshot.class === "warning" ? Kirigami.Theme.neutralTextColor : Kirigami.Theme.textColor
  }
  MouseArea {anchors.fill:parent; onClicked: {root.expanded=!root.expanded;dataSource.connectSource("$HOME/.local/bin/codex-usage --refresh");}}
 }
 fullRepresentation: ColumnLayout {
  implicitWidth: 360; implicitHeight: 260
  Controls.Label {Layout.fillWidth:true;Layout.margins:12;text:root.snapshot.detail;wrapMode:Text.Wrap; textFormat:Text.PlainText}
  RowLayout { Layout.margins:12
   Controls.Button {text:"刷新";onClicked:dataSource.connectSource("$HOME/.local/bin/codex-usage --refresh")}
   Controls.Button {text:"打开 ChatGPT";onClicked:dataSource.connectSource("$HOME/.local/bin/chatgpt")}
  }
 }
}
