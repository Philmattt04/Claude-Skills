---
name: ask
description: Ask Claude anything directly from the terminal — streams the answer inline. Triggered when the user wants a quick answer, explanation, or question answered (e.g. "ask Claude what X means", "ask what is...", "/ask").
---

# Ask Skill

Ask Claude any question and get a streamed answer inline in the terminal. No file needed — just ask.

## Steps

### 1. Get the question

If the user has not provided a question after `/ask`, prompt:
> "What would you like to ask Claude?"

### 2. Answer directly

Respond to the question immediately and thoroughly in the conversation. Stream the answer inline.

Keep answers concise but complete. Use markdown formatting where helpful (code blocks, bullet points, headers).

### 3. Offer follow-up

After answering, ask:
> "Do you have a follow-up question? [y/N]"

If yes, answer the follow-up in the same thread.
