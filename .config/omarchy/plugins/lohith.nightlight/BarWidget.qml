import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "lohith.nightlight"

  readonly property var nightlightService: bar?.shell?.firstPartyServiceFor("omarchy.nightlight")
  readonly property bool active: nightlightService ? nightlightService.enabled : false

  implicitWidth: Style.bar.statusSlot
  implicitHeight: root.barSize

  BarIconButton {
    anchors.centerIn: parent
    active: root.active
    useActiveColor: true
    activeColor: "#E75A50"
    text: root.active ? "󰛨" : "󰔎"
    tooltipText: root.active ? "Night Light: ON (4000K) — Click to Disable" : "Night Light: OFF (6500K) — Click to Enable"
    onPressed: function() {
      if (root.nightlightService) {
        root.nightlightService.toggle()
      } else {
        Quickshell.execDetached(["omarchy-shell", "nightlight", "toggle"])
      }
    }
  }
}
