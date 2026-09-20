import Quickshell
import QtQuick
import "../services"

// Dual-pane Weather & Calendar view embedded directly within ClockPill.
Item {
  id: root

  implicitWidth: 520
  implicitHeight: 265

  signal swipeLeft
  signal swipeRight

  Row {
    anchors.fill: parent
    anchors.margins: 14
    spacing: 14

    // ==========================================
    // LEFT COLUMN: WEATHER WIDGET
    // ==========================================
    Item {
      width: 195
      height: parent.height

      Column {
        anchors.fill: parent
        spacing: 9

        // Top Row: Current Weather Icon + Large Temperature
        Item {
          width: parent.width
          height: 56

          Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            // Weather Cloud with Lightning Icon
            Item {
              width: 42
              height: 42
              anchors.verticalCenter: parent.verticalCenter

              Text {
                anchors.centerIn: parent
                text: {
                  var k = CalendarState.weatherKind;
                  if (k === "thunder") return "⛈";
                  if (k === "rain") return "🌧";
                  if (k === "snow") return "❄";
                  if (k === "cloud") return "☁";
                  return "☀";
                }
                color: "#e89988"
                font.pixelSize: 32
              }
            }

            // Temperature + Condition
            Column {
              anchors.verticalCenter: parent.verticalCenter
              spacing: 1

              Text {
                text: CalendarState.temp + "°"
                color: SettingsState.textMain
                font.pixelSize: 30
                font.bold: true
                font.family: SettingsState.fontFamily
              }

              Text {
                text: CalendarState.condition
                color: SettingsState.textSecondary
                font.pixelSize: 11
                font.family: SettingsState.fontFamily
                elide: Text.ElideRight
                width: 115
              }
            }
          }
        }

        // City Location & Humidity Badges
        Item {
          width: parent.width
          height: 16

          Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: CalendarState.city
            color: SettingsState.textSecondary
            font.pixelSize: 11
            font.bold: true
            font.family: SettingsState.fontFamily
            font.letterSpacing: 1.1
            elide: Text.ElideRight
            width: 120
          }

          Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: "💧"
              font.pixelSize: 9
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: CalendarState.humidity + "%"
              color: SettingsState.textSecondary
              font.pixelSize: 11
              font.family: SettingsState.fontFamily
            }
          }
        }

        // Horizontal Divider Line
        Rectangle {
          width: parent.width
          height: 1
          color: SettingsState.borderBase
        }

        // 4-Day Forecast Row
        Row {
          width: parent.width
          height: 105
          spacing: 3

          Repeater {
            model: CalendarState.forecast

            delegate: Item {
              width: (parent.width - 9) / 4
              height: parent.height

              Column {
                anchors.centerIn: parent
                spacing: 5

                // Day Label (e.g. TUE, WED)
                Text {
                  anchors.horizontalCenter: parent.horizontalCenter
                  text: modelData.day
                  color: SettingsState.textMuted
                  font.pixelSize: 10
                  font.bold: true
                  font.family: SettingsState.fontFamily
                }

                // Weather Icon
                Text {
                  anchors.horizontalCenter: parent.horizontalCenter
                  text: {
                    var k = modelData.kind;
                    if (k === "thunder") return "⛈";
                    if (k === "rain") return "🌧";
                    if (k === "snow") return "❄";
                    if (k === "cloud") return "☁";
                    return "☀";
                  }
                  color: "#d4a49c"
                  font.pixelSize: 15
                }

                // Temp
                Text {
                  anchors.horizontalCenter: parent.horizontalCenter
                  text: modelData.temp + "°"
                  color: SettingsState.textMain
                  font.pixelSize: 11
                  font.bold: true
                  font.family: SettingsState.fontFamily
                }

                // Humidity with Droplet
                Row {
                  anchors.horizontalCenter: parent.horizontalCenter
                  spacing: 2

                  Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "💧"
                    font.pixelSize: 8
                  }

                  Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.humidity + "%"
                    color: SettingsState.textMuted
                    font.pixelSize: 9
                    font.family: SettingsState.fontFamily
                  }
                }
              }
            }
          }
        }
      }
    }

    // ==========================================
    // VERTICAL DIVIDER SEPARATOR
    // ==========================================
    Rectangle {
      width: 1
      height: parent.height
      color: SettingsState.borderBase
    }

    // ==========================================
    // RIGHT COLUMN: CALENDAR WIDGET
    // ==========================================
    Item {
      width: 270
      height: parent.height

      Column {
        anchors.fill: parent
        spacing: 6

        // Header: Kanji 曆 + Month Year + Nav Chevrons
        Item {
          width: parent.width
          height: 24

          Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 7

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: "曆"
              color: SettingsState.textMain
              font.pixelSize: 14
              font.bold: true
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: CalendarState.currentMonthYearString
              color: SettingsState.textMain
              font.pixelSize: 11
              font.bold: true
              font.letterSpacing: 1.1
              font.family: SettingsState.fontFamily
            }
          }

          // Chevrons < >
          Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3

            // Previous Month Button
            Rectangle {
              width: 20
              height: 20
              radius: 10
              color: prevMouse.containsMouse ? SettingsState.bgCardHover : "transparent"

              Text {
                anchors.centerIn: parent
                text: "‹"
                color: prevMouse.containsMouse ? SettingsState.textActive : SettingsState.textSecondary
                font.pixelSize: 15
                font.bold: true
              }

              MouseArea {
                id: prevMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: CalendarState.prevMonth()
              }
            }

            // Next Month Button
            Rectangle {
              width: 20
              height: 20
              radius: 10
              color: nextMouse.containsMouse ? SettingsState.bgCardHover : "transparent"

              Text {
                anchors.centerIn: parent
                text: "›"
                color: nextMouse.containsMouse ? SettingsState.textActive : SettingsState.textSecondary
                font.pixelSize: 15
                font.bold: true
              }

              MouseArea {
                id: nextMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: CalendarState.nextMonth()
              }
            }
          }
        }

        // Weekday Headers (M T W T F S S)
        Row {
          width: parent.width
          height: 15

          Repeater {
            model: ["M", "T", "W", "T", "F", "S", "S"]

            delegate: Item {
              width: parent.width / 7
              height: parent.height

              Text {
                anchors.centerIn: parent
                text: modelData
                color: SettingsState.textMuted
                font.pixelSize: 10
                font.bold: true
                font.family: SettingsState.fontFamily
              }
            }
          }
        }

        // Calendar 6x7 Grid
        Grid {
          width: parent.width
          height: 172
          columns: 7
          rows: 6
          rowSpacing: 1
          columnSpacing: 0

          Repeater {
            model: CalendarState.calendarGrid

            delegate: Item {
              width: 270 / 7
              height: 27

              // Circular Accent Ring for Today
              Rectangle {
                anchors.centerIn: parent
                width: 24
                height: 24
                radius: 12
                visible: modelData.isToday
                color: "transparent"
                border.color: "#e86a65"
                border.width: 1.5

                // Soft inner glow/accent circle
                Rectangle {
                  anchors.centerIn: parent
                  width: 18
                  height: 18
                  radius: 9
                  color: "#281b1b"
                  opacity: 0.6
                }
              }

              // Hover Highlight
              Rectangle {
                anchors.centerIn: parent
                width: 22
                height: 22
                radius: 11
                visible: dayMouse.containsMouse && !modelData.isToday
                color: SettingsState.bgCardHover
              }

              Text {
                anchors.centerIn: parent
                text: "" + modelData.day
                color: modelData.isToday
                  ? "#ffffff"
                  : (modelData.isCurrentMonth
                      ? (dayMouse.containsMouse ? SettingsState.textActive : SettingsState.textMain)
                      : SettingsState.textMuted)
                opacity: modelData.isCurrentMonth ? 1.0 : 0.35
                font.pixelSize: 11
                font.bold: modelData.isToday || (modelData.isCurrentMonth && dayMouse.containsMouse)
                font.family: SettingsState.fontFamily
              }

              MouseArea {
                id: dayMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  if (!modelData.isCurrentMonth) {
                    if (modelData.day > 15) {
                      CalendarState.prevMonth();
                    } else {
                      CalendarState.nextMonth();
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
