---
name: find-restaurants
description: "Find nearby restaurants for any location — returns top results with cuisine, address, and distance. Triggered when the user wants food recommendations or restaurant discovery (e.g. 'find restaurants near me', 'best pizza near Miami', '/find-restaurants')."
---

# Find Restaurants Skill

Find nearby restaurants for any location using the Overpass API (OpenStreetMap data). Return results with name, cuisine, address, and distance.

## Steps

### 1. Get the location

If the user has not provided a location, ask:
> "What location should I search near? (city, address, or coordinates)"

### 2. Geocode the location

Convert the location to coordinates using the Nominatim API:
```bash
curl -s "https://nominatim.openstreetmap.org/search?q=LOCATION&format=json&limit=1" \
  -H "User-Agent: claude-skill/find-restaurants"
```

Extract `lat` and `lon` from the first result.

### 3. Query nearby restaurants

Use the Overpass API to find restaurants within 1km:
```bash
curl -s "https://overpass-api.de/api/interpreter" \
  --data 'data=[out:json][timeout:10];(node["amenity"~"restaurant|cafe|fast_food|bar|ice_cream"](around:1000,LAT,LON););out body 20;'
```

### 4. Format the results

For each result, extract and display:
- **Name** (`tags.name`)
- **Type** (`tags.amenity` → restaurant / café / fast food / bar)
- **Cuisine** (`tags.cuisine`, if available)
- **Address** (`tags["addr:street"]` + `tags["addr:housenumber"]`)
- **Distance** (calculate from coordinates using Haversine formula)
- **Hours** (`tags.opening_hours`, if available)
- **Phone** (`tags.phone`, if available)
- **Website** (`tags.website`, if available)

Sort by distance (closest first). Show top 5–10 results.

### 5. Offer follow-up

Ask: "Would you like directions, more details on any of these, or to filter by cuisine type?"
