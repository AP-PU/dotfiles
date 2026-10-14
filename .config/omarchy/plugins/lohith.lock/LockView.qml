import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Item {
  id: root

  property string backgroundPath: ""
  property int backgroundVersion: 0
  property bool fingerprintConfigured: false
  property bool authenticatingPassword: false
  property string failureMessage: ""
  property int failedAttempts: 0
  property bool inputEnabled: true
  property bool loadBackground: true
  property string passwordText: ""
  property bool syncingPasswordText: false

  property string randomWallpaper: ""
  property var currentTime: new Date()

  Timer {
    id: clockTimer
    interval: 1000
    running: true
    repeat: true
    onTriggered: root.currentTime = new Date()
  }

  // Pick a random normal wallpaper every time the lock screen initializes
  Process {
    id: randomBgProc
    command: ["python3", "-c", "import glob, os, random\nwps = glob.glob(os.path.expanduser('~/Pictures/Wallpapers/general/*/*.*'))\nvalid = [w for w in wps if w.lower().endswith(('.png', '.jpg', '.jpeg', '.webp'))]\nif valid:\n    print(random.choice(valid))\n"]
    running: true
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var p = String(text || "").trim()
        if (p.length > 0) root.randomWallpaper = p
      }
    }
  }

  readonly property string placeholderText: "Enter Password"
  readonly property int fieldWidth: 380
  readonly property int fieldHeight: 52
  readonly property int fieldRadius: 26
  readonly property bool showPasswordCursor: inputEnabled && !authenticatingPassword && failureMessage.length === 0
  readonly property bool errorState: failureMessage.length > 0

  signal submitPassword(string password)
  signal passwordTextEdited(string password)
  signal clearFailureRequested()
  signal wakeRequested()

  function fileUrl(path) {
    if (!path) return ""
    var encoded = String(path).split("/").map(encodeURIComponent).join("/")
    return "file://" + encoded + "?v=" + backgroundVersion
  }

  function forcePasswordFocus() {
    passwordInput.forceActiveFocus()
  }

  function clearPassword() {
    passwordTextEdited("")
  }

  function syncPasswordText() {
    if (passwordInput.text === passwordText) return
    syncingPasswordText = true
    passwordInput.text = passwordText
    syncingPasswordText = false
  }

  onPasswordTextChanged: syncPasswordText()
  onInputEnabledChanged: {
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }
  Component.onCompleted: {
    syncPasswordText()
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }

  // Full Screen Root
  Rectangle {
    anchors.fill: parent
    color: "#080b12"

    // Background Image (Random normal wallpaper, fallback to backgroundPath)
    Image {
      id: wallpaper
      anchors.fill: parent
      source: root.loadBackground ? (root.randomWallpaper ? ("file://" + encodeURI(root.randomWallpaper)) : root.fileUrl(root.backgroundPath ? root.backgroundPath : ((Quickshell.env("HOME") || "") + "/.config/omarchy/backgrounds/harbordark/HBG3.png"))) : ""
      fillMode: Image.PreserveAspectCrop
      asynchronous: true
      cache: false
      sourceSize.width: width
      sourceSize.height: height
    }

    // Cinematic Soft Vignette Scrim
    Rectangle {
      anchors.fill: parent
      gradient: Gradient {
        GradientStop { position: 0.0; color: "#60050810" }
        GradientStop { position: 0.35; color: "#18050810" }
        GradientStop { position: 0.65; color: "#18050810" }
        GradientStop { position: 1.0; color: "#65050810" }
      }
    }

    // Click background anywhere to focus password input
    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      onClicked: { root.wakeRequested(); root.forcePasswordFocus() }
      onPositionChanged: root.wakeRequested()
    }

    // ====================================================
    // TOP CLOCK & DATE (Luxury Typography in Outfit)
    // ====================================================
    Item {
      id: clockSection
      width: parent.width
      anchors.top: parent.top
      anchors.topMargin: Math.round(parent.height * 0.12)

      Column {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 4

        // Display Time in Outfit Bold (e.g., "10:27 AM")
        Text {
          id: timeDisplay
          anchors.horizontalCenter: parent.horizontalCenter
          text: Qt.formatTime(root.currentTime, "h:mm AP").toUpperCase()
          color: "#FFFFFF"
          font.family: "Outfit, sans-serif"
          font.weight: Font.Bold
          font.pixelSize: 114
          style: Text.Raised
          styleColor: "#80000000"
        }

        // Full Date in Outfit Medium with Letter-Spacing
        Text {
          id: dateDisplay
          anchors.horizontalCenter: parent.horizontalCenter
          text: Qt.formatDate(root.currentTime, "dddd  ·  MMMM d, yyyy").toUpperCase()
          color: "#CAD5E2"
          font.family: "Outfit, sans-serif"
          font.weight: Font.Medium
          font.pixelSize: 15
          font.letterSpacing: 4
          style: Text.Raised
          styleColor: "#66000000"
        }
      }
    }

    // ====================================================
    // CENTER CRYSTAL FROSTED GLASS PASSWORD PILL
    // ====================================================
    Item {
      id: centerArea
      width: root.fieldWidth
      height: 120
      anchors.centerIn: parent

      // Crystalline Pill Box
      Rectangle {
        id: pillInputBox
        anchors.centerIn: parent
        width: root.fieldWidth
        height: root.fieldHeight
        radius: root.fieldRadius

        color: root.errorState ? "#55EF4444" : (passwordInput.activeFocus ? "#4D121724" : "#350B0E16")
        border.width: 1.5
        border.color: root.errorState ? "#EF4444" : (passwordInput.text.length > 0 || passwordInput.activeFocus ? "#FFFFFF" : "#55FFFFFF")
        clip: true

        Behavior on border.color { ColorAnimation { duration: 160 } }
        Behavior on color { ColorAnimation { duration: 160 } }

        // Left Crystal Diamond Accent
        Text {
          anchors.left: parent.left
          anchors.leftMargin: 16
          anchors.verticalCenter: parent.verticalCenter
          text: "◈"
          color: passwordInput.activeFocus ? "#FFFFFF" : "#55FFFFFF"
          font.pixelSize: 11
        }

        // Right Crystal Diamond Accent
        Text {
          anchors.right: parent.right
          anchors.rightMargin: 16
          anchors.verticalCenter: parent.verticalCenter
          text: "◈"
          color: passwordInput.activeFocus ? "#FFFFFF" : "#55FFFFFF"
          font.pixelSize: 11
        }

        // Subtle shake animation on error
        SequentialAnimation {
          id: shakeAnim
          running: root.errorState
          loops: 2
          PropertyAnimation { target: pillInputBox; property: "x"; to: (centerArea.width - pillInputBox.width) / 2 - 8; duration: 40 }
          PropertyAnimation { target: pillInputBox; property: "x"; to: (centerArea.width - pillInputBox.width) / 2 + 8; duration: 40 }
          PropertyAnimation { target: pillInputBox; property: "x"; to: (centerArea.width - pillInputBox.width) / 2; duration: 40 }
        }

        // Password Text Input (Crystal ◆ bullets)
        TextInput {
          id: passwordInput
          anchors.fill: parent
          anchors.leftMargin: 36
          anchors.rightMargin: 36
          verticalAlignment: TextInput.AlignVCenter
          horizontalAlignment: TextInput.AlignHCenter
          activeFocusOnPress: true
          clip: true
          enabled: root.inputEnabled && !root.authenticatingPassword
          readOnly: root.authenticatingPassword
          echoMode: TextInput.Password
          passwordCharacter: "◆"
          passwordMaskDelay: 0
          color: "#E2EEFF"
          selectionColor: "#50FFFFFF"
          selectedTextColor: "#FFFFFF"
          font.family: "Noto Sans, Liberation Sans, sans-serif"
          font.pixelSize: 20
          font.letterSpacing: 6
          cursorVisible: activeFocus && root.showPasswordCursor && text.length > 0
          cursorDelegate: Rectangle {
            width: 2
            color: "#FFFFFF"
            visible: passwordInput.cursorVisible
          }

          onTextChanged: {
            if (!root.syncingPasswordText) root.passwordTextEdited(text)
            if (text.length > 0) root.wakeRequested()
            if (text.length > 0 && root.failureMessage.length > 0) root.clearFailureRequested()
          }

          onAccepted: {
            var submitted = root.passwordText
            root.passwordTextEdited("")
            if (submitted.length > 0) root.submitPassword(submitted)
          }

          Keys.onPressed: function(event) {
            root.wakeRequested()
            if (event.key === Qt.Key_Escape || (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_U)) {
              root.passwordTextEdited("")
              event.accepted = true
            }
          }
        }

        // Placeholder Text ("Enter Password" in Outfit)
        Text {
          textFormat: Text.PlainText
          anchors.fill: parent
          anchors.leftMargin: 20
          anchors.rightMargin: 20
          text: root.authenticatingPassword ? "Authenticating…" : (root.failureMessage.length > 0 ? root.failureMessage : root.placeholderText)
          visible: passwordInput.text.length === 0
          color: root.authenticatingPassword ? "#C0AF7F" : (root.failureMessage.length > 0 ? "#FF6B6B" : "#B8C5D8")
          font.family: "Outfit, sans-serif"
          font.pixelSize: 15
          font.weight: Font.Normal
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          elide: Text.ElideRight
        }
      }

      // ====================================================
      // OMARCHY LOGO STYLISH FILLER (Centered beneath pill)
      // ====================================================
      Item {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: pillInputBox.bottom
        anchors.topMargin: 22
        width: 140
        height: 32

        Image {
          id: omarchyWordmark
          anchors.centerIn: parent
          width: 135
          height: 30
          source: "file:///usr/share/omarchy/logo-styled.svg"
          fillMode: Image.PreserveAspectFit
          smooth: true
          opacity: 0.85
        }
      }
    }
  }
}
