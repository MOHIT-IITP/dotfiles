import QtQuick
import "../services"

// Compact calendar card widget matching user reference image:
// - Clean rounded dark card without dividers
// - Left pane: coral uppercase weekday, prominent day number, and bottom events note
// - Right pane: coral uppercase month, M T W T F S S row (weekdays bright, weekends muted),
//   and compact grid with accent today and white-circle selected day.
Item {
  id: root

  implicitWidth: 370
  implicitHeight: 170

  property bool calHover: false

  HoverHandler {
    id: viewHover
    onHoveredChanged: root.calHover = hovered
  }

  // Selected date state
  property int selectedDay: (CalendarState.viewYear === CalendarState.todayYear && CalendarState.viewMonth === CalendarState.todayMonth)
                            ? CalendarState.todayDay
                            : 1

  readonly property var weekdayNames: [
    "SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"
  ]

  readonly property string selectedWeekdayStr: {
    var d = new Date(CalendarState.viewYear, CalendarState.viewMonth, root.selectedDay);
    return weekdayNames[d.getDay()] || "";
  }

  readonly property string currentMonthStr: {
    return CalendarState.monthNames[CalendarState.viewMonth] || "";
  }

  // Accent color for weekday title, month header, and today's indicator
  readonly property color calAccent: "#ff3b5c"

  // Rounded card container (borderless: the pill behind already draws the frame)
  // Fill matches the pill background so there is a single even surface.
  Rectangle {
    anchors.fill: parent
    radius: 22
    color: SettingsState.bgCard
    border.width: 0

    Row {
      anchors.fill: parent
      anchors.margins: 14
      spacing: 16

      // ================= LEFT PANE: SELECTED DAY & AGENDA =================
      Item {
        width: 105
        height: parent.height

        Column {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.top: parent.top
          spacing: 0

          // Weekday label (e.g. "THURSDAY")
          Text {
            text: root.selectedWeekdayStr
            color: root.calAccent
            font.pixelSize: SettingsState.px(10)
            font.bold: true
            font.family: SettingsState.fontFamily
            font.letterSpacing: 1.0
          }

          // Large day number (e.g. "18")
          Text {
            text: "" + root.selectedDay
            color: SettingsState.isDark ? "#ffffff" : "#1a1a1a"
            font.pixelSize: SettingsState.px(42)
            font.bold: true
            font.family: SettingsState.fontFamily
            lineHeight: 0.95
          }
        }

        // Bottom agenda / events note
        Column {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.bottom: parent.bottom
          spacing: 2

          Text {
            text: "No events"
            color: SettingsState.isDark ? "#9a9a9e" : "#55555a"
            font.pixelSize: SettingsState.px(11)
            font.bold: true
            font.family: SettingsState.fontFamily
          }

          Text {
            text: "This day is clear"
            color: SettingsState.isDark ? "#55555c" : "#88888e"
            font.pixelSize: SettingsState.px(10)
            font.family: SettingsState.fontFamily
          }
        }
      }

      // ================= RIGHT PANE: MONTH & CALENDAR GRID =================
      Item {
        width: parent.width - 105 - 16
        height: parent.height

        Column {
          anchors.fill: parent
          spacing: 4

          // Month header (e.g. "JUNE") + subtle navigation chevrons
          Item {
            width: parent.width
            height: 16

            Text {
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
              text: root.currentMonthStr
              color: root.calAccent
              font.pixelSize: SettingsState.px(10)
              font.bold: true
              font.family: SettingsState.fontFamily
              font.letterSpacing: 1.2
            }

            Row {
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              spacing: 6

              Text {
                text: "‹"
                color: prevMonthMouse.containsMouse ? (SettingsState.isDark ? "#ffffff" : "#000000") : "#606066"
                font.pixelSize: SettingsState.px(15)
                font.family: SettingsState.fontFamily
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                  id: prevMonthMouse
                  anchors.fill: parent
                  anchors.margins: -4
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: CalendarState.prevMonth()
                }
              }

              Text {
                text: "›"
                color: nextMonthMouse.containsMouse ? (SettingsState.isDark ? "#ffffff" : "#000000") : "#606066"
                font.pixelSize: SettingsState.px(15)
                font.family: SettingsState.fontFamily
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                  id: nextMonthMouse
                  anchors.fill: parent
                  anchors.margins: -4
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: CalendarState.nextMonth()
                }
              }
            }
          }

          // Weekdays header row: M T W T F S S
          Row {
            width: parent.width
            height: 14

            Repeater {
              model: [
                { name: "M", isWeekend: false },
                { name: "T", isWeekend: false },
                { name: "W", isWeekend: false },
                { name: "T", isWeekend: false },
                { name: "F", isWeekend: false },
                { name: "S", isWeekend: true },
                { name: "S", isWeekend: true }
              ]

              delegate: Item {
                width: parent.width / 7
                height: parent.height

                Text {
                  anchors.centerIn: parent
                  text: modelData.name
                  color: modelData.isWeekend ? (SettingsState.isDark ? "#55555c" : "#98989e") : (SettingsState.isDark ? "#ffffff" : "#1a1a1a")
                  font.pixelSize: SettingsState.px(11)
                  font.bold: true
                  font.family: SettingsState.fontFamily
                }
              }
            }
          }

          // Days grid: 7 columns x 6 rows (sized to fit exactly: header 16
          // + weekdays 14 + both column gaps of 4)
          Grid {
            id: calGrid
            width: parent.width
            height: parent.height - 16 - 14 - 8
            columns: 7
            rows: CalendarState.calendarRows
            rowSpacing: 1
            columnSpacing: 0

            Repeater {
              model: CalendarState.visibleCalendarGrid

              delegate: Item {
                property real cellH: (calGrid.height - (CalendarState.calendarRows - 1)) / CalendarState.calendarRows
                property real pillW: Math.min(24, cellH * 1.45)
                property real pillH: Math.min(18, cellH)
                width: calGrid.width / 7
                height: cellH

                property bool inMonth: modelData.isCurrentMonth
                property bool isToday: modelData.isToday
                property bool isSelected: inMonth && (modelData.day === root.selectedDay)
                property bool isWeekend: (index % 7) >= 5

                // Solid white pill background for selected day
                Rectangle {
                  anchors.centerIn: parent
                  width: pillW
                  height: pillH
                  radius: pillH / 2
                  color: parent.isSelected ? "#ffffff" : "transparent"
                  visible: parent.inMonth && parent.isSelected
                }

                // Subtle hover pill for unselected days
                Rectangle {
                  anchors.centerIn: parent
                  width: pillW
                  height: pillH
                  radius: pillH / 2
                  color: SettingsState.isDark ? "#1e1e24" : "#e6e6ec"
                  visible: parent.inMonth && !parent.isSelected && cellMouse.containsMouse
                }

                Text {
                  anchors.centerIn: parent
                  visible: parent.inMonth
                  text: "" + modelData.day
                  color: {
                    if (parent.isSelected) return "#000000";
                    if (parent.isToday) return root.calAccent;
                    if (parent.isWeekend) return SettingsState.isDark ? "#55555c" : "#98989e";
                    return SettingsState.isDark ? "#ffffff" : "#1a1a1a";
                  }
                  font.pixelSize: SettingsState.px(12)
                  font.bold: parent.isSelected || parent.isToday
                  font.family: SettingsState.fontFamily
                }

                MouseArea {
                  id: cellMouse
                  anchors.fill: parent
                  enabled: parent.inMonth
                  hoverEnabled: true
                  cursorShape: parent.inMonth ? Qt.PointingHandCursor : Qt.ArrowCursor
                  onClicked: {
                    if (parent.inMonth) {
                      root.selectedDay = modelData.day;
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
