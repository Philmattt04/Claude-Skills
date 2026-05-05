---
name: convert-media
description: Convert an audio or video file to a different format using ffmpeg. Triggered when the user provides a file path and wants to convert it (e.g. "convert this mp4 to mp3", "turn this wav into an aac file", "/convert-media").
---

# Media Converter Skill

Convert audio or video files to another format using `ffmpeg`. Follow these steps exactly.

## Supported Formats

**Audio:** mp3, wav, aac, m4a, ogg, flac, opus, wma
**Video:** mp4, mov, avi, mkv, webm, m4v, ts

## Steps

### 1. Get the input file

If the user has not provided a file path, ask:
> "What file would you like to convert? Please provide the full path."

Expand any `~` in the path. Verify the file exists using `ls "<path>"`. If it does not exist, tell the user and stop.

### 2. Detect the input format

Run:
```bash
ffprobe -v error -show_entries format=format_name -of default=noprint_wrappers=1:nokey=1 "<input_path>"
```

If `ffprobe` is not found, check for `ffmpeg`:
```bash
which ffmpeg
```

If neither is installed, tell the user:
> "ffmpeg is not installed. Install it with `brew install ffmpeg` and then try again."

Then stop.

### 3. Get the desired output format

If the user has not specified an output format, ask:
> "What format would you like to convert to? (e.g. mp3, wav, mp4, aac, flac)"

Validate that the requested format is in the supported list above. If not, tell the user which formats are supported and ask again.

### 4. Choose an output date (optional)

Ask the user:
> "Would you like to embed a date in the output filename? If yes, enter a date (e.g. 2026-05-04 or 20260504). Press Enter to skip and keep the original filename."

If the user provides a date:
- Accept any common format: `YYYY-MM-DD`, `YYYYMMDD`, `MM/DD/YYYY`, `MM-DD-YYYY`
- Normalise it to `YYYYMMDD` (e.g. `2026-05-04` → `20260504`)
- Detect whether the input filename already contains a date-like segment (8 consecutive digits, e.g. `AUDIO20260514`):
  - If yes, replace that segment with the new date: `AUDIO20260514.wav` → `AUDIO20260504.ogg`
  - If no, append the date before the extension: `podcast.wav` → `podcast_20260504.mp3`
- Use the same directory as the input file.

If the user skips the date prompt, construct the output path by simply replacing the input file's extension with the target format extension:

Example: `/Users/phil/Downloads/podcast.wav` → `/Users/phil/Downloads/podcast.mp3`

In either case, if a file already exists at the output path, append `_converted` before the extension:
`/Users/phil/Downloads/podcast_converted.mp3`

### 5. Build and run the ffmpeg command

Use these format-specific flags for quality:

| Output format | Extra flags |
|---|---|
| mp3 | `-q:a 2` (VBR ~190kbps) |
| aac / m4a | `-b:a 192k` |
| wav | (none) |
| flac | `-compression_level 8` |
| opus | `-b:a 128k` |
| ogg | `-q:a 5` |
| mp4 | `-c:v libx264 -crf 23 -c:a aac -b:a 192k` |
| webm | `-c:v libvpx-vp9 -crf 30 -b:v 0 -c:a libopus -b:a 128k` |
| mov | `-c:v libx264 -crf 23 -c:a aac -b:a 192k` |
| mkv | `-c:v copy -c:a copy` |

For audio-only output from a video input, add `-vn` to strip video.
For video formats, omit `-vn`.

Run:
```bash
ffmpeg -i "<input_path>" <format_flags> "<output_path>" -y
```

Show the user the exact command before running it and ask for confirmation if the conversion will take more than a few seconds (file > 100 MB).

### 6. Verify and report

After the command completes:
1. Check the exit code. If non-zero, show the ffmpeg error output and stop.
2. Run `ls -lh "<output_path>"` to confirm the file was created.
3. Report success:
   > "Converted successfully: `<output_path>` (<file size>)"

If the user wants to convert another file, start from Step 1.
