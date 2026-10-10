pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Manages Calendar & Weather state, month navigation, and live weather updates.
Singleton {
  id: root

  property bool open: false

  function toggle(): void {
    open = !open;
    if (open) {
      refreshWeather();
    }
  }

  function close(): void {
    open = false;
  }

  // --- Calendar Navigation State ---
  property var viewDate: new Date()
  property int viewYear: viewDate.getFullYear()
  property int viewMonth: viewDate.getMonth() // 0-indexed: 0 = Jan, 7 = Aug

  readonly property var todayDate: new Date()
  readonly property int todayDay: todayDate.getDate()
  readonly property int todayMonth: todayDate.getMonth()
  readonly property int todayYear: todayDate.getFullYear()

  readonly property var monthNames: [
    "JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE",
    "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"
  ]

  readonly property string currentMonthYearString: {
    return (monthNames[viewMonth] || "") + " " + viewYear;
  }

  function prevMonth(): void {
    var m = viewMonth - 1;
    var y = viewYear;
    if (m < 0) {
      m = 11;
      y -= 1;
    }
    viewMonth = m;
    viewYear = y;
  }

  function nextMonth(): void {
    var m = viewMonth + 1;
    var y = viewYear;
    if (m > 11) {
      m = 0;
      y += 1;
    }
    viewMonth = m;
    viewYear = y;
  }

  function resetToToday(): void {
    var d = new Date();
    viewDate = d;
    viewYear = d.getFullYear();
    viewMonth = d.getMonth();
  }

  function isSundayDay(y, m, d): bool {
    return new Date(y, m, d).getDay() === 0;
  }

  // Generate 42 cells (6 rows x 7 cols starting from Monday)
  readonly property var calendarGrid: {
    var cells = [];
    var firstDayOfMonth = new Date(viewYear, viewMonth, 1);
    // Day of week: 0=Sun, 1=Mon, ..., 6=Sat -> Monday-based: 0=Mon, ..., 6=Sun
    var startDay = (firstDayOfMonth.getDay() + 6) % 7;

    var daysInPrevMonth = new Date(viewYear, viewMonth, 0).getDate();
    var daysInCurrentMonth = new Date(viewYear, viewMonth + 1, 0).getDate();

    // 1. Previous month trailing days
    for (var p = startDay - 1; p >= 0; --p) {
      var pm = viewMonth === 0 ? 11 : viewMonth - 1;
      var py = viewMonth === 0 ? viewYear - 1 : viewYear;
      var pd = daysInPrevMonth - p;
      cells.push({
        day: pd,
        isCurrentMonth: false,
        isToday: false,
        isSunday: isSundayDay(py, pm, pd),
        month: pm,
        year: py
      });
    }

    // 2. Current month days
    for (var d = 1; d <= daysInCurrentMonth; ++d) {
      var isT = (d === todayDay && viewMonth === todayMonth && viewYear === todayYear);
      cells.push({
        day: d,
        isCurrentMonth: true,
        isToday: isT,
        isSunday: isSundayDay(viewYear, viewMonth, d),
        month: viewMonth,
        year: viewYear
      });
    }

    // 3. Next month leading days to complete 42 cells (6 weeks)
    var remaining = 42 - cells.length;
    for (var n = 1; n <= remaining; ++n) {
      var nm = viewMonth === 11 ? 0 : viewMonth + 1;
      var ny = viewMonth === 11 ? viewYear + 1 : viewYear;
      cells.push({
        day: n,
        isCurrentMonth: false,
        isToday: false,
        isSunday: isSundayDay(ny, nm, n),
        month: nm,
        year: ny
      });
    }

    return cells;
  }

  // --- Weather State ---
  property string temp: "30"
  property string condition: "Thunder"
  property string weatherKind: "thunder" // "sun" | "cloud" | "rain" | "thunder" | "snow"
  property string city: "NEW DELHI"
  property int humidity: 80
  property bool weatherLoading: false

  property var forecast: [
    { day: "TUE", kind: "thunder", temp: "30", humidity: 98 },
    { day: "WED", kind: "rain", temp: "31", humidity: 87 },
    { day: "THU", kind: "thunder", temp: "30", humidity: 91 },
    { day: "FRI", kind: "rain", temp: "31", humidity: 89 }
  ]

  function mapWeatherCode(desc, code): string {
    var text = ((desc || "") + " " + (code || "")).toLowerCase();
    if (text.indexOf("thunder") !== -1 || text.indexOf("storm") !== -1 || text.indexOf("lightning") !== -1) {
      return "thunder";
    }
    if (text.indexOf("rain") !== -1 || text.indexOf("shower") !== -1 || text.indexOf("drizzle") !== -1) {
      return "rain";
    }
    if (text.indexOf("snow") !== -1 || text.indexOf("ice") !== -1 || text.indexOf("blizzard") !== -1 || text.indexOf("sleet") !== -1) {
      return "snow";
    }
    if (text.indexOf("cloud") !== -1 || text.indexOf("overcast") !== -1 || text.indexOf("fog") !== -1 || text.indexOf("mist") !== -1) {
      return "cloud";
    }
    return "sun";
  }

  function getDayName(dateStr, offset): string {
    var days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
    if (dateStr) {
      var parts = dateStr.split("-");
      if (parts.length === 3) {
        var d = new Date(parseInt(parts[0]), parseInt(parts[1]) - 1, parseInt(parts[2]));
        return days[d.getDay()] || "DAY";
      }
    }
    var target = new Date();
    target.setDate(target.getDate() + (offset || 0));
    return days[target.getDay()] || "DAY";
  }

  function parseWeatherJson(raw): void {
    try {
      var data = JSON.parse(raw);
      if (!data) return;

      // Current condition
      if (data.current_condition && data.current_condition.length > 0) {
        var cur = data.current_condition[0];
        root.temp = cur.temp_C ? "" + cur.temp_C : root.temp;
        root.humidity = cur.humidity ? parseInt(cur.humidity) : root.humidity;
        if (cur.weatherDesc && cur.weatherDesc.length > 0 && cur.weatherDesc[0].value) {
          root.condition = cur.weatherDesc[0].value;
          root.weatherKind = mapWeatherCode(cur.weatherDesc[0].value, cur.weatherCode);
        }
      }

      // City location
      if (data.nearest_area && data.nearest_area.length > 0) {
        var area = data.nearest_area[0];
        if (area.areaName && area.areaName.length > 0 && area.areaName[0].value) {
          root.city = area.areaName[0].value.toUpperCase();
        }
      }

      // Forecast days
      if (data.weather && data.weather.length > 1) {
        var newForecast = [];
        for (var i = 1; i < Math.min(5, data.weather.length); ++i) {
          var w = data.weather[i];
          var dName = getDayName(w.date, i);
          var avgT = w.avgtempC || w.maxtempC || "30";
          var hum = 80;
          var wDesc = "";
          if (w.hourly && w.hourly.length > 0) {
            var mid = w.hourly[Math.floor(w.hourly.length / 2)] || w.hourly[0];
            hum = mid.humidity ? parseInt(mid.humidity) : 80;
            if (mid.weatherDesc && mid.weatherDesc.length > 0) {
              wDesc = mid.weatherDesc[0].value;
            }
          }
          newForecast.push({
            day: dName,
            kind: mapWeatherCode(wDesc, ""),
            temp: "" + avgT,
            humidity: hum
          });
        }
        if (newForecast.length > 0) {
          root.forecast = newForecast;
        }
      }
    } catch (e) {
      // Fallback preserves initial sensible values
    }
  }

  property string _rawWeather: ""

  property var weatherProcess: Process {
    command: ["curl", "-s", "--max-time", "6", "wttr.in/?format=j1"]
    running: false

    stdout: SplitParser {
      onRead: data => {
        root._rawWeather += data;
      }
    }

    onExited: function (code, status) {
      root.weatherLoading = false;
      if (root._rawWeather && root._rawWeather.length > 20) {
        root.parseWeatherJson(root._rawWeather);
      }
      root._rawWeather = "";
    }
  }

  function refreshWeather(): void {
    if (weatherLoading) return;
    _rawWeather = "";
    weatherLoading = true;
    weatherProcess.running = true;
  }

  // Periodic weather refresh timer (every 20 minutes)
  Timer {
    interval: 1200000
    running: true
    repeat: true
    onTriggered: root.refreshWeather()
  }

  Component.onCompleted: {
    refreshWeather();
  }
}
