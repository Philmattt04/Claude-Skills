---
name: weather-insights
description: Get AI-powered weather insights for a location — activity recommendations and clothing suggestions powered by Amazon Bedrock (Claude 3 Haiku). Triggered when the user wants weather recommendations (e.g. "weather insights for Tokyo", "what should I wear in Seattle", "/weather-insights").
---

# Weather Insights Skill

Fetch live weather data then pass it to Amazon Bedrock (Claude 3 Haiku) via the Weather Dashboard API to generate a weather summary, activity recommendations, and clothing suggestions. Follow these steps exactly.

## API Base URL

```
https://sfvuwnwog3.execute-api.us-east-1.amazonaws.com/prod
```

## Steps

### 1. Get the location

If the user has not provided a location, ask:
> "What location would you like weather insights for?"

### 2. Choose units

Ask:
> "Units? imperial (°F) or metric (°C)  [default: imperial]"

Accept Enter for the default.

### 3. Fetch current weather

URL-encode the location if it is not GPS coordinates:
```bash
ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('LOCATION'))")
```

For GPS coordinates (e.g. `25.76,-80.19`), use `lat=LAT&lon=LON` instead.

```bash
curl -s "https://sfvuwnwog3.execute-api.us-east-1.amazonaws.com/prod/weather?type=current&q=$ENCODED&units=UNITS"
```

If the response contains `"error"`, show the error message and stop.

Show the user a brief summary while Bedrock generates insights:
> "Fetching AI insights for CITY, COUNTRY…"

### 4. Call the AI insights endpoint

Extract the required fields from the weather response using Python, then POST to the `/ai` endpoint:

```bash
echo 'WEATHER_JSON' | python3 -c "
import json, sys
d = json.load(sys.stdin)
m = d['main']
w = d['weather'][0]
wind = d.get('wind', {})
dirs = ['N','NNE','NE','ENE','E','ESE','SE','SSE','S','SSW','SW','WSW','W','WNW','NW','NNW']
wind_dir = dirs[round(wind.get('deg', 0) / 22.5) % 16]
payload = {
    'city': d['name'],
    'country': d['sys']['country'],
    'temperature': round(m['temp']),
    'feelsLike': round(m['feels_like']),
    'tempMax': round(m['temp_max']),
    'tempMin': round(m['temp_min']),
    'humidity': m['humidity'],
    'windSpeed': round(wind.get('speed', 0)),
    'windDir': wind_dir,
    'visibility': str(d.get('visibility', 0) // 1000),
    'pressure': m['pressure'],
    'weatherDescription': w['description'],
    'units': 'UNITS'
}
print(json.dumps(payload))
" | curl -s -X POST \
    -H "Content-Type: application/json" \
    -d @- \
    "https://sfvuwnwog3.execute-api.us-east-1.amazonaws.com/prod/ai"
```

If the response contains `"error"` or `summary` is null, show:
> "AI insights are unavailable right now. Bedrock may not be enabled in the AWS account."
Then stop.

### 5. Display the insights

Parse and display using Python:

```bash
echo 'INSIGHTS_JSON' | python3 -c "
import json, sys
d = json.load(sys.stdin)

print('\n✨ AI Weather Insights')
print('Powered by Amazon Bedrock (Claude 3 Haiku)')
print('─' * 40)

if d.get('summary'):
    print(f\"\n{d['summary']}\n\")

if d.get('activities'):
    print('🏃 Activities')
    for a in d['activities']:
        print(f'  ✓ {a}')
    print()

if d.get('clothing'):
    print('👗 What to Wear')
    for c in d['clothing']:
        print(f'  • {c}')
    print()
"
```

### 6. Offer follow-up

Ask:
> "Would you like insights for a different location? [y/N]"

If yes, go back to Step 1.
