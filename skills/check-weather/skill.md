---
name: check-weather
description: Get current weather conditions for any location using the Weather Dashboard API. Triggered when the user wants to check the weather (e.g. "check weather in Miami", "what's the weather in Paris", "/check-weather").
---

# Check Weather Skill

Fetch current weather conditions for any location — city name, zip code, or GPS coordinates. Uses the Weather Dashboard AWS API (Lambda → OpenWeatherMap). Follow these steps exactly.

## API Base URL

```
https://sfvuwnwog3.execute-api.us-east-1.amazonaws.com/prod
```

## Steps

### 1. Get the location

If the user has not provided a location, ask:
> "What location would you like weather for? (city name, zip code, or lat,lon coordinates)"

### 2. Choose units

Ask:
> "Units? imperial (°F) or metric (°C)  [default: imperial]"

Accept Enter for the default.

### 3. Build the request

If the input matches GPS coordinate format (two numbers separated by a comma, e.g. `25.76,-80.19`), extract lat and lon:
```bash
LAT=$(echo "INPUT" | cut -d',' -f1 | tr -d ' ')
LON=$(echo "INPUT" | cut -d',' -f2 | tr -d ' ')
```
Use `lat=$LAT&lon=$LON` as the location parameter.

Otherwise, URL-encode the location string:
```bash
ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('LOCATION'))")
```
Use `q=$ENCODED` as the location parameter.

### 4. Fetch current weather

```bash
curl -s "https://sfvuwnwog3.execute-api.us-east-1.amazonaws.com/prod/weather?type=current&LOCATION_PARAM&units=UNITS"
```

If the response contains `"error"`, show the error message and stop.

### 5. Display the result

Parse and display using Python:

```bash
echo 'RESPONSE_JSON' | python3 -c "
import json, sys
d = json.load(sys.stdin)
m = d['main']
w = d['weather'][0]
wind = d.get('wind', {})
unit = '°F' if 'UNITS' == 'imperial' else '°C'
speed_unit = 'mph' if 'UNITS' == 'imperial' else 'm/s'
dirs = ['N','NNE','NE','ENE','E','ESE','SE','SSE','S','SSW','SW','WSW','W','WNW','NW','NNW']
wind_dir = dirs[round(wind.get('deg', 0) / 22.5) % 16]

print(f\"\"\"\n📍 {d['name']}, {d['sys']['country']}
{'─' * 30}
🌡  {round(m['temp'])}{unit}  (feels like {round(m['feels_like'])}{unit})
   High {round(m['temp_max'])}{unit}  ·  Low {round(m['temp_min'])}{unit}
🌤  {w['description'].capitalize()}
💧 Humidity: {m['humidity']}%
💨 Wind: {round(wind.get('speed', 0))} {speed_unit} {wind_dir}
👁  Visibility: {d.get('visibility', 0) // 1000} km
🌡️  Pressure: {m['pressure']} hPa
\"\"\")
"
```

### 6. Offer follow-up

Ask:
> "Would you like AI insights for this location (activities and clothing recommendations)? [y/N]"

If yes, tell the user to run `/weather-insights LOCATION`.
