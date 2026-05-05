---
name: generate-image
description: Generate an image from a text prompt using Pollinations.ai (free, no API key required). Triggered when the user wants to create, generate, or make an image (e.g. "generate an image of...", "create a picture of...", "/generate-image").
---

# Image Generator Skill (Pollinations.ai)

Generate images from text prompts using Pollinations.ai — free and unlimited, no API key needed. Uses `curl` to download the image directly. Follow these steps exactly.

## Available Models

| Value | Label |
|---|---|
| `flux` | Flux — Default, best quality |
| `flux-realism` | Flux Realism |
| `flux-cablyai` | Flux CablyAI |
| `flux-anime` | Flux Anime |
| `flux-3d` | Flux 3D |
| `any-dark` | Any Dark |
| `flux-pro` | Flux Pro |
| `turbo` | Turbo — Fastest |

## Art Styles (appended to prompt)

| Label | Appended text |
|---|---|
| None | _(nothing added)_ |
| Photorealistic | `photorealistic, ultra detailed photography` |
| Anime | `anime style, vibrant, cel shaded` |
| Cinematic | `cinematic film still, dramatic lighting, movie scene` |
| Oil Painting | `oil painting, expressive brushwork, fine art` |
| Digital Art | `digital art, concept art, highly detailed illustration` |
| Watercolor | `watercolor painting, soft washes, delicate` |
| 3D Render | `3D render, octane render, photorealistic CGI` |
| Pixel Art | `pixel art, retro 8-bit, pixel perfect` |
| Sketch | `pencil sketch, graphite, fine linework` |
| Cyberpunk | `neon cyberpunk, dark, futuristic city, glowing lights` |

## Aspect Ratios → Pixel Dimensions

| Ratio | Width | Height |
|---|---|---|
| 1:1 | 1024 | 1024 |
| 16:9 | 1344 | 768 |
| 9:16 | 768 | 1344 |
| 4:3 | 1152 | 896 |
| 3:2 | 1216 | 832 |

## Steps

### 1. Get the prompt

If the user has not provided a prompt, ask:
> "Describe the image you'd like to generate."

### 2. Choose options

Ask the following (accept Enter for the default):

**Model** (default: `flux`)
> "Model? Options: flux, flux-realism, flux-cablyai, flux-anime, flux-3d, any-dark, flux-pro, turbo  [default: flux]"

**Art style** (default: None)
> "Art style? Options: None, Photorealistic, Anime, Cinematic, Oil Painting, Digital Art, Watercolor, 3D Render, Pixel Art, Sketch, Cyberpunk  [default: None]"

**Negative prompt** (default: none)
> "Anything to exclude from the image? (e.g. blurry, watermark)  [default: none]"

**Aspect ratio** (default: `1:1`)
> "Aspect ratio? Options: 1:1, 16:9, 9:16, 4:3, 3:2  [default: 1:1]"

**Variations** (default: `1`, max: `4`)
> "How many variations? (1–4)  [default: 1]"

**Seed** (default: random)
> "Seed number for reproducibility?  [default: random]"

**Output directory** (default: `~/Downloads`)
> "Where should the image(s) be saved?  [default: ~/Downloads]"

Expand `~` in the output directory. Verify it exists; if not, offer to create it with `mkdir -p`.

### 3. Build the full prompt

If an art style was chosen (not None), append its text to the user's prompt:
```
{user prompt}, {style text}
```

URL-encode the full prompt for use in the URL. Use Python for encoding:
```bash
python3 -c "import urllib.parse; print(urllib.parse.quote('FULL_PROMPT'))"
```

### 4. Generate each image

For each variation (1 to N), calculate the seed as `BASE_SEED + (i - 1)`. If no seed was given, generate a random one:
```bash
python3 -c "import random; print(random.randint(0, 999999))"
```

Build the URL:
```
https://image.pollinations.ai/prompt/{encoded_prompt}?width={W}&height={H}&model={model}&nologo=true&enhance=false{negative}{seed}
```

Where:
- `{negative}` = `&negative_prompt={url-encoded negative prompt}` (omit if empty)
- `{seed}` = `&seed={seed_value}`

Determine the output filename:
- Single image: `imagen_{timestamp}.png` where timestamp = `YYYYMMDD_HHMMSS`
- Multiple images: `imagen_{timestamp}_1.png`, `imagen_{timestamp}_2.png`, etc.

Download with curl (follow redirects, show progress):
```bash
curl -L --progress-bar "{URL}" -o "{output_path}"
```

Show the user each curl command before running it.

### 5. Verify and report

After each download, run:
```bash
ls -lh "{output_path}"
```

If the file is smaller than 5 KB, it likely failed (the API returned an error page instead of an image). Show the URL and tell the user to try a different prompt or model.

Report success for each file:
> "Generated: `{output_path}` ({file size})"

Ask:
> "Would you like to generate another image?"

If yes, go back to Step 1.
