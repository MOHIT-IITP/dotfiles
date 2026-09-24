import Quickshell
import QtQuick
import "../services"

// Dual-pane Weather & Calendar popup matching reference UI.
// Left: Current weather + 4-day forecast.
// Right: Interactive monthly calendar with Kanji header & today ring.
Rectangle {
  id: root

  readonly property bool open: CalendarState.open

  implicitWidth: 540
  implicitHeight: open ? 275 : 0
  radius: 20
  clip: true

  color: SettingsState.bgSurface
  border.color: SettingsState.borderBase
  border.width: 1

  opacity: open ? 1 : 0
  visible: open || opacity > 0

  Behavior on implicitHeight {
    NumberAnimation {
      duration: 260
      easing.type: Easing.OutCubic
    }
  }

  Behavior on opacity {
    NumberAnimation {
      duration: 180
    }
  }

  // Weather Icon symbol helper (delegates to the shared Nerd mapping)
  function getWeatherIcon(kind): string {
    return SettingsState.nerdWeatherIcon(kind);
  }

  property real _modalPressX: 0

  MouseArea {
    anchors.fill: parent
    z: -1
    onPressed: function(ev) {
      root._modalPressX = ev.x;
    }
    onPositionChanged: function(ev) {
      if (ev.x - root._modalPressX < -25) {
        CalendarState.close();
      }
    }
    onWheel: wheel => {
      if (wheel.angleDelta.x < 0 || wheel.pixelDelta.x < 0) {
        CalendarState.close();
      }
    }
  }

  Row {
    anchors.fill: parent
    anchors.margins: 16
    spacing: 16

    // ==========================================
    // LEFT COLUMN: WEATHER WIDGET
    // ==========================================
    Item {
      width: 200
      height: parent.height

      Column {
        anchors.fill: parent
        spacing: 10

        // Top Row: Current Weather Icon + Large Temperature
        Item {
          width: parent.width
          height: 60

          Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 14

            // Custom Weather Cloud with Lightning Icon
            Item {
              width: 44
              height: 44
              anchors.verticalCenter: parent.verticalCenter

              // Weather Cloud Glyph / Symbol
              Text {
                anchors.centerIn: parent
                text: SettingsState.nerdWeatherIcon(CalendarState.weatherKind)
                color: "#e89988"
                font.family: SettingsState.nerdIconFont
                font.pixelSize: 30
              }
            }

            // Temperature + Condition
            Column {
              anchors.verticalCenter: parent.verticalCenter
              spacing: 1

              Text {
                text: CalendarState.temp + "°"
                color: SettingsState.textMain
                font.pixelSize: 32
                font.bold: true
                font.family: SettingsState.fontFamily
              }

              Text {
                text: CalendarState.condition
                color: SettingsState.textSecondary
                font.pixelSize: 12
                font.family: SettingsState.fontFamily
                elide: Text.ElideRight
                width: 120
              }
            }
          }
        }

        // City Location & Humidity Badges
        Item {
          width: parent.width
          height: 18

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
            width: 125
          }

          Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: "\uf043"
              color: SettingsState.textSecondary
              font.family: SettingsState.nerdIconFont
              font.pixelSize: 10
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
          height: 110
          spacing: 4

          Repeater {
            model: CalendarState.forecast

            delegate: Item {
              width: (parent.width - 12) / 4
              height: parent.height

              Column {
                anchors.centerIn: parent
                spacing: 6

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
                  text: SettingsState.nerdWeatherIcon(modelData.kind)
                  color: "#d4a49c"
                  font.family: SettingsState.nerdIconFont
                  font.pixelSize: 16
                }

                // Temp
                Text {
                  anchors.horizontalCenter: parent.horizontalCenter
                  text: modelData.temp + "°"
                  color: SettingsState.textMain
                  font.pixelSize: 12
                  font.bold: true
                  font.family: SettingsState.fontFamily
                }

                // Humidity with Droplet
                Row {
                  anchors.horizontalCenter: parent.horizontalCenter
                  spacing: 2

                  Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "\uf043"
                    color: SettingsState.textMuted
                    font.family: SettingsState.nerdIconFont
                    font.pixelSize: 9
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
      width: 275
      height: parent.height

      Column {
        anchors.fill: parent
        spacing: 8

        // Header: Calendar icon + Month Year + Nav Chevrons
        Item {
          width: parent.width
          height: 26

          Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: "\uf073"
              color: SettingsState.textMain
              font.family: SettingsState.nerdIconFont
              font.pixelSize: 16
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: CalendarState.currentMonthYearString
              color: SettingsState.textMain
              font.pixelSize: 12
              font.bold: true
              font.letterSpacing: 1.2
              font.family: SettingsState.fontFamily
            }
          }

          // Chevrons < >
          Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            // Previous Month Button
            Rectangle {
              width: 22
              height: 22
              radius: 11
              z: 5
              color: prevMouse.containsMouse ? SettingsState.bgCardHover : "transparent"

              Text {
                anchors.centerIn: parent
                text: "\uf053"
                color: prevMouse.containsMouse ? SettingsState.textActive : SettingsState.textSecondary
                font.family: SettingsState.nerdIconFont
                font.pixelSize: 15
              }

              MouseArea {
                id: prevMouse
                anchors.fill: parent
                anchors.margins: -6
                z: 5
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: CalendarState.prevMonth()
              }
            }

            // Next Month Button
            Rectangle {
              width: 22
              height: 22
              radius: 11
              z: 5
              color: nextMouse.containsMouse ? SettingsState.bgCardHover : "transparent"

              Text {
                anchors.centerIn: parent
                text: "\uf054"
                color: nextMouse.containsMouse ? SettingsState.textActive : SettingsState.textSecondary
                font.family: SettingsState.nerdIconFont
                font.pixelSize: 15
              }

              MouseArea {
                id: nextMouse
                anchors.fill: parent
                anchors.margins: -6
                z: 5
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: CalendarState.nextMonth()
              }
            }
          }
        }

        // Weekday Headers (M T W T F S S, Sunday red)
        Row {
          width: parent.width
          height: 16

          Repeater {
            model: ["M", "T", "W", "T", "F", "S", "S"]

            delegate: Item {
              width: parent.width / 7
              height: parent.height

              Text {
                anchors.centerIn: parent
                text: modelData
                color: index === 6 ? "#e86a65" : SettingsState.textMuted
                font.pixelSize: 11
                font.bold: true
                font.family: SettingsState.fontFamily
              }
            }
          }
        }

        // Calendar 6x7 Grid
        Grid {
          width: parent.width
          height: 180
          columns: 7
          rows: 6
          rowSpacing: 2
          columnSpacing: 0

          Repeater {
            model: CalendarState.calendarGrid

            delegate: Item {
              width: 275 / 7
              height: 28
              property bool isSunday: modelData.isSunday !== undefined ? modelData.isSunday : (new Date(modelData.year, modelData.month, modelData.day).getDay() === 0)

              // Circular Accent Ring for Today
              Rectangle {
                anchors.centerIn: parent
                width: 26
                height: 26
                radius: 13
                visible: modelData.isToday
                color: "transparent"
                border.color: "#e86a65"
                border.width: 1.5

                // Soft inner glow/accent circle
                Rectangle {
                  anchors.centerIn: parent
                  width: 20
                  height: 20
                  radius: 10
                  color: "#281b1b"
                  opacity: 0.6
                }
              }

              // Hover Highlight
              Rectangle {
                anchors.centerIn: parent
                width: 24
                height: 24
                radius: 12
                visible: dayMouse.containsMouse && !modelData.isToday
                color: SettingsState.bgCardHover
              }

              Text {
                anchors.centerIn: parent
                text: "" + modelData.day
                color: modelData.isToday
                  ? "#ffffff"
                  : (isSunday && modelData.isCurrentMonth
                      ? "#e86a65"
                      : (modelData.isCurrentMonth
                          ? (dayMouse.containsMouse ? SettingsState.textActive : SettingsState.textMain)
                          : SettingsState.textMuted))
                opacity: modelData.isCurrentMonth ? 1.0 : 0.35
                font.pixelSize: 12
                font.bold: modelData.isToday || isSunday || (modelData.isCurrentMonth && dayMouse.containsMouse)
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
