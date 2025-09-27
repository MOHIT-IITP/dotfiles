#!/bin/bash
# Set your location
LOCATION="Patna,Bihar,India"

# Weather data from wttr.in with location specified
weather_info=$(curl -s "https://wttr.in/$LOCATION?format=j1")

# Check if we got valid data
if [ -z "$weather_info" ] || [ "$(echo "$weather_info" | jq -r '.current_condition')" == "null" ]; then
    echo "{\"text\":\"Weather N/A\", \"tooltip\":\"Weather data not available\"}"
    exit 1
fi

# Extract temperature and weather condition
temperature=$(echo "$weather_info" | jq -r '.current_condition[0].temp_C')
weather_code=$(echo "$weather_info" | jq -r '.current_condition[0].weatherCode')
weather_desc=$(echo "$weather_info" | jq -r '.current_condition[0].weatherDesc[0].value')
humidity=$(echo "$weather_info" | jq -r '.current_condition[0].humidity')

# Weather icon mapping based on weather code
get_icon() {
    case $1 in
        113) echo "󰖙" ;; # Clear/Sunny
        116) echo "󰖐" ;; # Partly Cloudy
        119|122) echo "" ;; # Cloudy
        143|248|260) echo "󰖑" ;; # Fog
        176|263|266|281|284|293|296|299|302|305|308|311|314|317|320|350|353|356|359|362|365|368|371|374|377|386|389|392|395) echo "󰖖" ;; # Rain/Showers
        200|227|230|323|326|329|332|335|338|368|371|374|377|392|395) echo "󰖔" ;; # Snow
        *)  echo "󰖙" ;; # Default
    esac
}
icon=$(get_icon "$weather_code")

# Debug information
echo "Location: $LOCATION, Temp: $temperature°C, Code: $weather_code, Desc: $weather_desc" > /tmp/weather_debug.log

# Output JSON for Waybar with more details in tooltip
echo "{\"text\":\"${icon} ${temperature}°C \", \"tooltip\":\"${weather_desc}, ${temperature}°C, Humidity: ${humidity}%\"}"
exit 0
