import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "lohith.wallpapers"
  ipcTarget: "lohith.wallpapers"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  readonly property var barIdentity: hostWidget || root

  property var allWallpapers: []
  property var filteredWallpapers: []
  property string searchFilter: ""
  property string activeMode: "normal" // "normal" or "sexy"

  readonly property int normalCount: {
    var c = 0
    for (var i = 0; i < allWallpapers.length; i++) {
      if (!allWallpapers[i].is_sexy) c++
    }
    return c
  }

  readonly property int sexyCount: {
    var c = 0
    for (var i = 0; i < allWallpapers.length; i++) {
      if (allWallpapers[i].is_sexy) c++
    }
    return c
  }

  function open() {
    refreshWallpapers()
    root.controller.show()
  }

  function close() {
    root.controller.hide()
  }

  function toggle() {
    if (root.opened) root.close()
    else root.open()
  }

  function refreshWallpapers() {
    if (!listWallpapersProc.running) {
      listWallpapersProc.running = true
    }
  }

  function updateFiltered() {
    var query = searchFilter.trim().toLowerCase()
    var res = []

    for (var i = 0; i < allWallpapers.length; i++) {
      var item = allWallpapers[i]
      var isSexy = item.is_sexy === true

      // Filter by the active mode switch (Normal vs Sexy)
      if (root.activeMode === "normal" && isSexy) continue
      if (root.activeMode === "sexy" && !isSexy) continue

      // Search query filter
      if (query) {
        var nameMatch = item.name.toLowerCase().indexOf(query) !== -1
        var fileMatch = item.filename.toLowerCase().indexOf(query) !== -1
        var folderMatch = item.folder.toLowerCase().indexOf(query) !== -1
        var catMatch = (item.category || "").toLowerCase().indexOf(query) !== -1
        if (!nameMatch && !fileMatch && !folderMatch && !catMatch) {
          continue
        }
      }

      res.push(item)
    }

    filteredWallpapers = res
  }

  function applyWallpaper(path) {
    if (!path) return
    var targetPath = String(path)
    Quickshell.execDetached([(Quickshell.env("HOME") || "") + "/.local/bin/omarchy-apply-wallpaper-palette", targetPath])
    root.close()
  }

  Component.onCompleted: refreshWallpapers()

  Process {
    id: listWallpapersProc
    command: [(Quickshell.env("HOME") || "") + "/.local/bin/omarchy-list-wallpapers"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var items = JSON.parse(text)
          root.allWallpapers = items || []
          root.updateFiltered()
        } catch (e) {
          console.error("Wallpapers parse error:", e)
        }
      }
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    centerOnBar: false
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(520))
    contentHeight: panel.fittedContentHeight(Style.space(610))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()

      Column {
        id: mainColumn
        anchors.fill: parent
        spacing: Style.space(8)

        // Header Row
        Row {
          width: parent.width
          height: Style.space(32)
          spacing: Style.space(8)

          Text {
            text: "󰸉"
            font.family: Style.font.family
            font.pixelSize: Style.font.iconLarge
            color: root.activeMode === "sexy" ? "#EF4444" : Color.accent
            anchors.verticalCenter: parent.verticalCenter
          }

          Text {
            text: "Wallpapers"
            font.family: Style.font.family
            font.pixelSize: Style.font.heading
            font.weight: Font.DemiBold
            color: Color.foreground
            anchors.verticalCenter: parent.verticalCenter
          }

          Item {
            width: Math.max(10, parent.width - 190)
            height: 1
            anchors.verticalCenter: parent.verticalCenter
          }

          // MINIMAL TOGGLE SWITCH (Zero description - switches between Normal and Sexy)
          Rectangle {
            id: modeToggle
            width: 48
            height: 26
            radius: 13
            anchors.verticalCenter: parent.verticalCenter
            color: root.activeMode === "sexy" ? "#EF4444" : "#242432"
            border.color: root.activeMode === "sexy" ? "#FF7070" : "#38384C"
            border.width: 1

            Behavior on color { ColorAnimation { duration: 180 } }
            Behavior on border.color { ColorAnimation { duration: 180 } }

            // Sliding Thumb
            Rectangle {
              id: toggleThumb
              width: 20
              height: 20
              radius: 10
              y: 2
              x: root.activeMode === "sexy" ? modeToggle.width - width - 3 : 3
              color: "#FFFFFF"

              Behavior on x {
                NumberAnimation { duration: 180; easing.type: Easing.InOutQuad }
              }
            }

            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                root.activeMode = (root.activeMode === "normal") ? "sexy" : "normal"
                root.updateFiltered()
              }
            }
          }
        }

        // Search Filter Input
        TextField {
          id: searchInput
          width: parent.width
          placeholderText: root.activeMode === "sexy" ? "Search sexy wallpapers…" : "Search normal wallpapers…"
          onTextChanged: {
            root.searchFilter = text
            root.updateFiltered()
          }
        }

        // Wallpapers Grid Area
        Rectangle {
          width: parent.width
          height: Style.space(475)
          color: "transparent"
          clip: true

          GridView {
            id: wallpaperGrid
            anchors.fill: parent
            cellWidth: Math.floor(wallpaperGrid.width / 2)
            cellHeight: Math.floor(cellWidth * 0.60)
            boundsBehavior: Flickable.StopAtBounds
            model: root.filteredWallpapers
            reuseItems: true
            cacheBuffer: 1200
            clip: true

            delegate: Rectangle {
              id: cardRoot
              required property var modelData
              required property int index

              width: wallpaperGrid.cellWidth - Style.space(6)
              height: wallpaperGrid.cellHeight - Style.space(6)
              radius: 6
              color: "#111114"
              border.color: cardMouse.containsMouse ? (modelData.is_sexy ? "#EF4444" : Color.accent) : (modelData.is_sexy ? "#3A171D" : "#222228")
              border.width: cardMouse.containsMouse ? 2 : 1
              clip: true

              Behavior on border.color { ColorAnimation { duration: 150 } }

              // Thumbnail Image (Optimized instantaneous rendering with pre-cached thumbnails)
              Image {
                id: thumbnail
                anchors.fill: parent
                anchors.margins: cardRoot.border.width
                source: "file://" + encodeURI(modelData.thumbnail || modelData.path)
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize: Qt.size(240, 135)
                cache: true
              }

              // Category Badge (Top-Right)
              Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 6
                radius: 3
                color: modelData.is_sexy ? "#D92E1116" : "#CC111114"
                border.color: modelData.is_sexy ? "#5C2028" : "transparent"
                border.width: modelData.is_sexy ? 1 : 0
                width: folderText.implicitWidth + 8
                height: folderText.implicitHeight + 4

                Text {
                  id: folderText
                  anchors.centerIn: parent
                  text: modelData.category ? modelData.category.replace("_", " ") : modelData.folder
                  font.family: Style.font.family
                  font.pixelSize: 9
                  color: modelData.is_sexy ? "#FFBBBB" : Color.muted
                  elide: Text.ElideRight
                }
              }

              // Mode Pill (Top-Left)
              Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 6
                radius: 3
                color: modelData.is_sexy ? "#E68B0000" : "#CC0F3822"
                width: modePillText.implicitWidth + 8
                height: modePillText.implicitHeight + 4

                Text {
                  id: modePillText
                  anchors.centerIn: parent
                  text: modelData.is_sexy ? "SEXY" : "NORMAL"
                  font.family: Style.font.family
                  font.pixelSize: 8
                  font.weight: Font.Bold
                  color: modelData.is_sexy ? "#FFAAAA" : "#6EE7B7"
                }
              }

              // Bottom Label Overlay
              Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: labelColumn.implicitHeight + 8
                color: cardMouse.containsMouse ? (modelData.is_sexy ? "#E6280E14" : "#E6111114") : "#CC111114"

                Column {
                  id: labelColumn
                  anchors.left: parent.left
                  anchors.right: parent.right
                  anchors.verticalCenter: parent.verticalCenter
                  anchors.leftMargin: 8
                  anchors.rightMargin: 8

                  Text {
                    width: parent.width
                    text: modelData.name
                    font.family: Style.font.family
                    font.pixelSize: Style.font.body
                    font.weight: Font.DemiBold
                    color: cardMouse.containsMouse ? (modelData.is_sexy ? "#FFAAAA" : Color.accent) : Color.foreground
                    elide: Text.ElideRight
                  }
                }
              }

              MouseArea {
                id: cardMouse
                anchors.fill: parent
                z: 10
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.applyWallpaper(modelData.path)
              }
            }
          }

          // Empty state text
          Text {
            anchors.centerIn: parent
            visible: root.filteredWallpapers.length === 0
            text: root.allWallpapers.length === 0 ? "Loading wallpapers…" : "No matching wallpapers found"
            font.family: Style.font.family
            font.pixelSize: Style.font.body
            color: Color.muted
          }
        }

        // Quick Controls Footer
        Row {
          width: parent.width
          spacing: Style.space(8)

          Button {
            width: Math.floor((parent.width - Style.space(8)) / 2)
            text: "Cycle BG"
            iconText: "󰁔"
            bordered: true
            onClicked: {
              if (root.bar) root.bar.run("omarchy theme bg next")
              root.close()
            }
          }

          Button {
            width: Math.floor((parent.width - Style.space(8)) / 2)
            text: "Refresh List"
            iconText: "󰑐"
            bordered: true
            onClicked: root.refreshWallpapers()
          }
        }
      }
    }
  }
}
