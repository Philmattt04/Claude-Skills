---
name: Summarize
description: Summarize any document, file, or pasted text using Claude. Produces structured output — executive summary, key points, main topics, notable details, and conclusion. Triggered when the user wants to summarize something (e.g. "summarize this document", "give me the key points of this file", "/summarize").
---

# Document Summarizer Skill

Summarize any text content using Claude. Accepts file paths (PDF, TXT, MD) or plain pasted text. Follow these steps exactly.

## Steps

### 1. Get the content

If the user provided a file path, verify it exists:
```bash
ls -lh "FILE_PATH"
```
If the file does not exist, tell the user and stop.

If no content was provided, ask:
> "What would you like summarized? Provide a file path or paste the text."

### 2. Extract text

**For PDF files**, use Python with pdfminer or just read the raw bytes and send to Claude for extraction:
```bash
python3 -c "
import sys
try:
    import pdfminer.high_level
    text = pdfminer.high_level.extract_text('FILE_PATH')
    print(text[:100000])
except ImportError:
    # Fallback: read as binary and let Claude handle it
    print('PDF_BINARY_FALLBACK')
"
```

If pdfminer is not installed, tell the user:
> "For PDF summarization, install pdfminer: `pip install pdfminer.six`"
Then stop.

**For TXT / MD files:**
```bash
head -c 100000 "FILE_PATH"
```

**For pasted text:** use it directly.

### 3. Summarize with Claude

Ask Claude to produce a structured summary in this exact format:

```
Please summarize the following document in markdown with these sections:

## Executive Summary
## Key Points
## Main Topics
## Notable Details
## Conclusion

Document:
---
{DOCUMENT_TEXT}
---
```

Claude will generate the summary directly in the conversation.

### 4. Offer follow-up

After the summary, ask:
> "Would you like to ask any follow-up questions about this document? [y/N]"

If yes, answer questions using the document content as context. Keep answers grounded in what the document actually says.
