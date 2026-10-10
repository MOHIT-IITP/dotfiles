import Quickshell
import Quickshell.Io
import QtQuick
import "../services"

// Embedded App + File Search launcher subview styled exactly as reference:
// - Mode tabs (Apps / Files) at the top; Files mode is a fast fd-based file search
// - Top search header with 探 glyph, underlined search input, and result counter
// - Clean vertical results list with 2-line title & subtitle layout and selected pill highlight
// - Bottom subtle hint footer
Item {
  id: root

  property string query: ""
  property int sel: 0
  readonly property bool isFiles: LauncherState.mode === "files"

  // ---- File search state (fd backend + folder browsing) ----
  property var fileResults: []
  property bool fileSearching: false
  property string browsePath: "/home/mohiitp"

  function normalizeDir(path) {
    if (!path) return "/home/mohiitp";
    var p = path.toString();
    if (p.length > 1 && p.charAt(p.length - 1) === "/") p = p.substring(0, p.length - 1);
    return p === "" ? "/" : p;
  }

  function isPhoto(path) {
    if (!path) return false;
    var p = path.toString().toLowerCase();
    return (p.endsWith(".jpg") || p.endsWith(".jpeg") || p.endsWith(".png")
      || p.endsWith(".webp") || p.endsWith(".gif") || p.endsWith(".bmp")
      || p.endsWith(".tif") || p.endsWith(".tiff") || p.endsWith(".svg")
      || p.endsWith(".heic") || p.endsWith(".heif") || p.endsWith(".avif"));
  }

  function fileName(path) {
    if (!path) return "";
    var p = path.toString();
    if (p.length > 1 && p.charAt(p.length - 1) === "/") p = p.substring(0, p.length - 1);
    var i = p.lastIndexOf("/");
    return i >= 0 ? p.substring(i + 1) : p;
  }

  function fileParent(path) {
    if (!path) return "";
    var p = path.toString();
    if (p.length > 1 && p.charAt(p.length - 1) === "/") p = p.substring(0, p.length - 1);
    var i = p.lastIndexOf("/");
    return i > 0 ? p.substring(0, i) : "/";
  }

  // Newline-terminated uri list for outbound drag (Chrome, Discord, ...).
  function fileDragUrls(path) {
    if (!path) return "";
    var p = path.toString();
    return "file://" + encodeURI(p) + "\r\n";
  }

  function runFileSearch() {
    fileResults = [];
    fileSearching = true;
    if (searchProc.running) searchProc.running = false;
    // Empty query lists current folder; typed query searches recursively inside it.
    searchProc.command = ["/home/mohiitp/.config/quickshell/scripts/search_files.sh", query, browsePath, "60"];
    searchProc.running = true;
  }

  function enterFolder(path) {
    browsePath = normalizeDir(path);
    query = "";
    if (search) search.text = "";
    sel = 0;
    runFileSearch();
    forceFocus();
  }

  function goUp() {
    if (browsePath === "/" || browsePath === "") return;
    enterFolder(fileParent(browsePath));
  }

  Timer {
    id: fileDebounce
    interval: 220
    repeat: false
    onTriggered: {
      if (root.isFiles && LauncherState.open) root.runFileSearch();
    }
  }

  Process {
    id: searchProc
    running: false
    stdout: SplitParser {
      onRead: data => {
        var line = (data || "").toString().trim();
        if (line === "") return;
        var tab = line.indexOf("\t");
        var type = "f";
        var p = line;
        if (tab !== -1) {
          type = line.substring(0, tab);
          p = line.substring(tab + 1);
        }
        if (p === "") return;
        root.fileResults = root.fileResults.concat([{ "path": p, "isDir": type === "d" }]);
      }
    }
    onExited: function(code, status) {
      root.fileSearching = false;
    }
  }

  implicitWidth: 380
  implicitHeight: 360

  function forceFocus() {
    search.focus = true;
    search.forceActiveFocus();
  }

  Connections {
    target: LauncherState
    function onOpenChanged() {
      if (LauncherState.open) {
        root.query = "";
        root.sel = 0;
        root.browsePath = "/home/mohiitp";
        search.text = "";
        if (root.isFiles) root.runFileSearch();
        forceFocus();
        focusRetryTimer.restart();
      }
    }
    function onModeChanged() {
      root.sel = 0;
      if (LauncherState.open) {
        if (root.isFiles) {
          root.browsePath = "/home/mohiitp";
          root.runFileSearch();
        }
        forceFocus();
      }
    }
  }

  Timer {
    id: focusRetryTimer
    interval: 30
    repeat: true
    property int count: 0
    onRunningChanged: {
      if (running) count = 0;
    }
    onTriggered: {
      count++;
      forceFocus();
      if (search.activeFocus || count > 6) {
        running = false;
      }
    }
  }

  readonly property var allApps: DesktopEntries.applications.values
  readonly property var filtered: {
    var q = query.trim().toLowerCase();
    var out = [];
    for (var i = 0; i < allApps.length; ++i) {
      var a = allApps[i];
      if (!a) continue;
      if (q === "") {
        out.push(a);
      } else {
        var hay = (a.name || "") + " " + (a.genericName || "") + " " + (a.id || "") + " " + (a.comment || "");
        if (a.keywords) {
          for (var k = 0; k < a.keywords.length; ++k)
            hay += " " + a.keywords[k];
        }
        if (hay.toLowerCase().indexOf(q) !== -1)
          out.push(a);
      }
      if (out.length >= 60)
        break;
    }
    return out;
  }

  function getSubtitle(entry) {
    if (!entry) return "";
    if (entry.genericName && entry.genericName.trim().length > 0)
      return entry.genericName.trim();
    if (entry.comment && entry.comment.trim().length > 0)
      return entry.comment.trim();
    if (entry.categories && entry.categories.length > 0) {
      var cat = Array.isArray(entry.categories) ? entry.categories[0] : entry.categories;
      if (cat && typeof cat === "string") return cat.replace(/;/g, " ").trim();
    }
    return "Application";
  }

  function launch(entry) {
    if (!entry) return;
    LauncherState.close();
    entry.execute();
  }

  function launchSelected() {
    if (root.isFiles) {
      launchFileSelected(false);
      return;
    }
    if (sel >= 0 && sel < filtered.length)
      launch(filtered[sel]);
  }

  function openFile(path) {
    if (!path) return;
    LauncherState.close();
    Quickshell.execDetached(["/home/mohiitp/.config/quickshell/scripts/open_file.sh", path.toString(), "open"]);
  }

  function revealFile(path) {
    if (!path) return;
    LauncherState.close();
    Quickshell.execDetached(["/home/mohiitp/.config/quickshell/scripts/open_file.sh", path.toString(), "reveal"]);
  }

  // Enter / click behavior: folders drill into the launcher, files open externally
  // (photos -> gthumb, everything else -> xdg-open via open_file.sh).
  function activateFile(item) {
    if (!item || !item.path) return;
    if (item.isDir) {
      enterFolder(item.path);
    } else {
      openFile(item.path);
    }
  }

  function launchFileSelected(reveal) {
    if (sel < 0 || sel >= fileResults.length) return;
    var item = fileResults[sel];
    if (!item || !item.path) return;
    if (reveal) revealFile(item.path);
    else activateFile(item);
  }

  Column {
    id: contentCol
    anchors.fill: parent
    anchors.leftMargin: 20
    anchors.rightMargin: 20
    anchors.topMargin: 16
    anchors.bottomMargin: 16
    spacing: 10

    // ========================================================
    // 0. MODE TABS (Apps / Files toggle)
    // ========================================================
    Row {
      width: parent.width
      spacing: 8

      Repeater {
        model: [{ "id": "apps", "label": "Apps" }, { "id": "files", "label": "Files" }]
        delegate: Rectangle {
          required property var modelData
          readonly property bool active: LauncherState.mode === modelData.id
          width: 72
          height: 28
          radius: 14
          color: active ? SettingsState.bgActivePill : (tabMouse.containsMouse ? SettingsState.bgCardHover : "transparent")
          border.color: active ? SettingsState.borderActive : SettingsState.borderBase
          border.width: 1

          Text {
            anchors.centerIn: parent
            text: modelData.label
            color: active ? SettingsState.textActive : SettingsState.textSecondary
            font.pixelSize: SettingsState.px(13)
            font.bold: active
            font.family: SettingsState.fontFamily
          }

          MouseArea {
            id: tabMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              LauncherState.mode = modelData.id;
            }
          }
        }
      }

      Item {
        width: parent.width - 140
        height: 1
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        visible: root.isFiles && root.fileSearching
        text: "\uea7c"
        color: SettingsState.textMuted
        font.pixelSize: SettingsState.px(12)
        font.family: SettingsState.nerdIconFont
      }
    }

    // ========================================================
    // 0b. BREADCRUMB (Files mode: current folder + back)
    // ========================================================
    Row {
      width: parent.width
      spacing: 10
      visible: root.isFiles
      height: root.isFiles ? implicitHeight : 0

      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 28
        height: 28
        radius: 14
        color: crumbMouse.containsMouse ? SettingsState.bgCardHover : "transparent"
        border.color: SettingsState.borderBase
        border.width: 1

        Text {
          anchors.centerIn: parent
          text: "\ueab5"
          color: SettingsState.textSecondary
          font.pixelSize: SettingsState.px(15)
          font.bold: true
          font.family: SettingsState.nerdIconFont
        }

        MouseArea {
          id: crumbMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.goUp()
        }
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - 38
        text: root.browsePath + (root.query !== "" ? "  ·  ⌕ " + root.query : "")
        color: SettingsState.textMuted
        font.pixelSize: SettingsState.px(13)
        font.family: SettingsState.fontFamily
        elide: Text.ElideLeft
        horizontalAlignment: Text.AlignRight
      }
    }

    // ========================================================
    // 1. TOP SEARCH HEADER (Glyph + Input + Underline + Counter)
    // ========================================================
    Item {
      width: parent.width
      height: 36

      Row {
        anchors.fill: parent
        spacing: 12

        // Search Kanji Glyph 探
        Text {
          id: kanjiGlyph
          anchors.verticalCenter: parent.verticalCenter
          text: "探"
          color: SettingsState.textMuted
          font.pixelSize: SettingsState.px(19)
          font.family: SettingsState.fontFamily
        }

        // Search Input Container with Underline
        Item {
          id: inputContainer
          width: parent.width - kanjiGlyph.width - counterText.width - 24
          height: parent.height

          // Placeholder
          Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            visible: search.text === ""
            text: root.isFiles ? "Search files…" : "Search apps"
            color: SettingsState.textMuted
            font.pixelSize: SettingsState.px(16)
            font.family: SettingsState.fontFamily
          }

          // Text Input
          TextInput {
            id: search
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            color: SettingsState.textMain
            font.pixelSize: SettingsState.px(16)
            font.family: SettingsState.fontFamily
            clip: true
            focus: true
            activeFocusOnTab: true
            selectByMouse: true
            cursorVisible: true

            onTextChanged: {
              query = text;
              sel = 0;
              if (root.isFiles) fileDebounce.restart();
            }

            Keys.onPressed: function (ev) {
              var listLen = root.isFiles ? root.fileResults.length : filtered.length;
              var listView = root.isFiles ? fileListView : appListView;
              if ((ev.modifiers & Qt.ControlModifier) && (ev.key === Qt.Key_1)) {
                LauncherState.mode = "apps";
                ev.accepted = true;
                return;
              } else if ((ev.modifiers & Qt.ControlModifier) && (ev.key === Qt.Key_2)) {
                LauncherState.mode = "files";
                ev.accepted = true;
                return;
              } else if ((ev.modifiers & Qt.ControlModifier) && (ev.key === Qt.Key_Tab)) {
                LauncherState.toggleMode();
                ev.accepted = true;
                return;
              }
              if (ev.key === Qt.Key_Down) {
                sel = Math.min(listLen - 1, sel + 1);
                if (listView) listView.positionViewAtIndex(sel, ListView.Contain);
                ev.accepted = true;
              } else if (ev.key === Qt.Key_Up) {
                sel = Math.max(0, sel - 1);
                if (listView) listView.positionViewAtIndex(sel, ListView.Contain);
                ev.accepted = true;
              } else if (ev.key === Qt.Key_Return || ev.key === Qt.Key_Enter) {
                if (root.isFiles && (ev.modifiers & Qt.ShiftModifier)) {
                  launchFileSelected(true);
                } else {
                  launchSelected();
                }
                ev.accepted = true;
              } else if (ev.key === Qt.Key_Backspace && root.isFiles && root.query === "") {
                root.goUp();
                ev.accepted = true;
              } else if (ev.key === Qt.Key_Escape) {
                LauncherState.close();
                ev.accepted = true;
              }
            }
          }

          // Subtle Underline beneath Search Input
          Rectangle {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: SettingsState.borderBase
          }
        }

        // Result counter (apps: "52 / 52", files: "12 files")
        Text {
          id: counterText
          anchors.verticalCenter: parent.verticalCenter
          text: root.isFiles ? (root.fileResults.length + " files") : (filtered.length + " / " + allApps.length)
          color: SettingsState.textMuted
          font.pixelSize: SettingsState.px(14)
          font.family: SettingsState.fontFamily
          horizontalAlignment: Text.AlignRight
        }
      }
    }

    // ========================================================
    // 2. APP RESULTS LIST (Icon + 2-Line App Info)
    // ========================================================
    ListView {
      id: appListView
      width: parent.width
      height: 220
      spacing: 4
      clip: true
      visible: !root.isFiles
      model: filtered
      currentIndex: sel

      delegate: Rectangle {
        required property var modelData
        required property int index
        readonly property bool isSelected: index === root.sel

        width: ListView.view.width
        height: 52
        radius: 14
        color: isSelected
          ? (SettingsState.isDark ? "#232629" : "#e6eaee")
          : (itemMouse.containsMouse ? (SettingsState.isDark ? "#191c1e" : "#f0f3f6") : "transparent")
        border.color: isSelected ? (SettingsState.isDark ? "#353a3e" : "#d2d8de") : "transparent"
        border.width: 1

        Behavior on color {
          ColorAnimation { duration: 70 }
        }

        Row {
          anchors.fill: parent
          anchors.leftMargin: 14
          anchors.rightMargin: 14
          spacing: 14

          // App Icon
          Item {
            anchors.verticalCenter: parent.verticalCenter
            width: 28
            height: 28

            Image {
              anchors.centerIn: parent
              width: 26
              height: 26
              visible: modelData && modelData.icon !== ""
              source: (modelData && modelData.icon !== "") ? Quickshell.iconPath(modelData.icon, "application-x-executable") : ""
              smooth: true
              asynchronous: true
            }

            Text {
              anchors.centerIn: parent
              visible: !modelData || modelData.icon === ""
              text: (modelData && modelData.name) ? modelData.name.substring(0, 1).toUpperCase() : "?"
              color: isSelected ? SettingsState.textActive : SettingsState.textSecondary
              font.pixelSize: SettingsState.px(16)
              font.bold: true
              font.family: SettingsState.fontFamily
            }
          }

          // 2-Line Text: App Name + Subtitle/Category
          Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 48
            spacing: 2

            Text {
              width: parent.width
              text: (modelData && modelData.name) ? modelData.name : ""
              color: isSelected ? SettingsState.textMain : SettingsState.textMain
              font.pixelSize: SettingsState.px(16)
              font.bold: false
              font.family: SettingsState.fontFamily
              elide: Text.ElideRight
            }

            Text {
              width: parent.width
              text: root.getSubtitle(modelData)
              color: isSelected ? SettingsState.textSecondary : SettingsState.textMuted
              font.pixelSize: SettingsState.px(13)
              font.family: SettingsState.fontFamily
              elide: Text.ElideRight
            }
          }
        }

        MouseArea {
          id: itemMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            root.sel = index;
            root.launch(modelData);
          }
        }
      }
    }

    // ========================================================
    // 2b. FILE RESULTS LIST (fd search: folder/file icon + path)
    // ========================================================
    ListView {
      id: fileListView
      width: parent.width
      height: 220
      spacing: 4
      clip: true
      visible: root.isFiles
      model: root.fileResults
      currentIndex: sel

      delegate: Rectangle {
        id: fileRow
        required property var modelData
        required property int index
        readonly property bool isSelected: index === root.sel

        width: ListView.view.width
        height: 52
        radius: 14
        color: isSelected
          ? (SettingsState.isDark ? "#232629" : "#e6eaee")
          : (fileMouse.containsMouse ? (SettingsState.isDark ? "#191c1e" : "#f0f3f6") : "transparent")
        border.color: isSelected ? (SettingsState.isDark ? "#353a3e" : "#d2d8de") : "transparent"
        border.width: 1

        Behavior on color {
          ColorAnimation { duration: 70 }
        }

        // ---- Outbound drag: drop the file onto Chrome / any app ----
        Drag.active: fileMouse.drag.active
        Drag.dragType: Drag.Automatic
        Drag.supportedActions: Qt.CopyAction | Qt.MoveAction | Qt.LinkAction
        Drag.mimeData: ({ "text/uri-list": root.fileDragUrls(modelData ? modelData.path : "") })
        Drag.hotSpot.x: width / 2
        Drag.hotSpot.y: height / 2

        // Invisible proxy so the row itself never moves while dragging out.
        Item {
          id: fileDragProxy
          width: 1
          height: 1
          x: -10
          y: -10
        }

        Row {
          anchors.fill: parent
          anchors.leftMargin: 14
          anchors.rightMargin: 14
          spacing: 14

          CCIcon {
            anchors.verticalCenter: parent.verticalCenter
            width: 24
            height: 24
            kind: (modelData && modelData.isDir) ? "folder" : "file"
            glyph: isSelected ? SettingsState.textActive : SettingsState.textSecondary
          }

          Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 48
            spacing: 2

            Text {
              width: parent.width
              text: root.fileName(modelData ? modelData.path : "")
              color: SettingsState.textMain
              font.pixelSize: SettingsState.px(16)
              font.family: SettingsState.fontFamily
              elide: Text.ElideRight
            }

            Text {
              width: parent.width
              text: root.fileParent(modelData ? modelData.path : "")
              color: isSelected ? SettingsState.textSecondary : SettingsState.textMuted
              font.pixelSize: SettingsState.px(13)
              font.family: SettingsState.fontFamily
              elide: Text.ElideLeft
            }
          }
        }

        MouseArea {
          id: fileMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
          acceptedButtons: Qt.LeftButton | Qt.RightButton
          preventStealing: true
          drag.target: fileDragProxy
          drag.axis: Drag.XAndYAxis

          property bool dragging: false

          onPressed: function(mouse) {
            dragging = false;
            root.sel = index;
            fileRow.grabToImage(function(result) {
              fileRow.Drag.imageSource = result.url;
            });
          }
          onPositionChanged: {
            if (fileMouse.drag.active) dragging = true;
          }
          onClicked: function(mouse) {
            if (dragging) {
              dragging = false;
              return;
            }
            root.sel = index;
            if (mouse.button === Qt.RightButton) root.revealFile(modelData.path);
            else root.activateFile(modelData);
          }
        }
      }
    }

    // ========================================================
    // 3. BOTTOM FOOTER HINT (apps mode only)
    // ========================================================
    Item {
      width: parent.width
      height: root.isFiles ? 0 : 22
      visible: !root.isFiles

      Text {
        anchors.centerIn: parent
        text: root.isFiles ? "⏎ Folder→Browse · File→Open (photo→gthumb) · ⌫ Up · Shift+⏎ in Thunar" : "↓  Drag an AppImage onto the pill  ·  Ctrl+2 Files"
        color: SettingsState.textMuted
        font.pixelSize: SettingsState.px(13)
        font.family: SettingsState.fontFamily
        opacity: 0.75
      }

      DropArea {
        anchors.fill: parent
        onDropped: function(drop) {
          if (drop.hasUrls && drop.urls.length > 0) {
            var url = drop.urls[0].toString();
            if (url.indexOf("file://") === 0) {
              var path = url.replace("file://", "");
              Quickshell.execDetached(["chmod", "+x", path]);
              Quickshell.execDetached([path]);
              LauncherState.close();
            }
          }
        }
      }
    }
  }
}
