# 💬 betterimsg — Send, read, stream iMessage & SMS

This is a fork of imsg, a macOS Messages.app CLI used to send, read, and stream iMessage/SMS (with attachment metadata). imsg comes bundled with OpenClaw as a tool for allowing the user to communicate with their agent, but was deprecated in favor of BlueBubbles. However, there are still many reasons to prefer imsg over BlueBubbles as BlueBubbles requires extensive setup and disabling SIP.

imsg started suffering from message echo issues, where the agent would receive its own messages as new incoming messages, burning tokens and confusing the agent. betterimsg addresses this by filtering out the agent's own messages using the is_from_me flag. The filtering can be disabled by a flag.

## Features
- List chats, view history, or stream new messages (`watch`).
- Send text and attachments via iMessage or SMS (AppleScript, no private APIs).
- Phone normalization to E.164 for reliable buddy lookup (`--region`, default US).
- Optional attachment metadata output (mime, name, path, missing flag).
- Filters: participants, start/end time, JSON output for tooling.
- Read-only DB access (`mode=ro`), no DB writes.
- Event-driven watch via filesystem events.

## Requirements
- macOS 14+ with Messages.app signed in.
- Full Disk Access for your terminal to read `~/Library/Messages/chat.db`.
- Automation permission for your terminal to control Messages.app (for sending).
- For SMS relay, enable “Text Message Forwarding” on your iPhone to this Mac.

## Install

### Download prebuilt release
1. Download `betterimsg-macos.zip` from the latest GitHub release.
2. Unzip it.
3. Move `betterimsg` somewhere on your `PATH`, for example:

```bash
chmod +x betterimsg
sudo mv betterimsg /usr/local/bin/
```

If macOS warns because the binary is not notarized, right-click it and choose Open, or remove the quarantine flag:

```bash
xattr -d com.apple.quarantine /path/to/betterimsg
```

### Build from source
```bash
make build
# binary at ./bin/betterimsg
```

## Commands
- `betterimsg chats [--limit 20] [--json]` — list recent conversations.
- `betterimsg history --chat-id <id> [--limit 50] [--attachments] [--participants +15551234567,...] [--start 2025-01-01T00:00:00Z] [--end 2025-02-01T00:00:00Z] [--json]`
- `betterimsg watch [--chat-id <id>] [--since-rowid <n>] [--debounce 250ms] [--attachments] [--participants …] [--start …] [--end …] [--json]`
- `betterimsg send --to <handle> [--text "hi"] [--file /path/img.jpg] [--service imessage|sms|auto] [--region US]`

### Quick samples
```
# list 5 chats
betterimsg chats --limit 5

# list chats as JSON
betterimsg chats --limit 5 --json

# last 10 messages in chat 1 with attachments
betterimsg history --chat-id 1 --limit 10 --attachments

# filter by date and emit JSON
betterimsg history --chat-id 1 --start 2025-01-01T00:00:00Z --json

# live stream a chat
betterimsg watch --chat-id 1 --attachments --debounce 250ms

# send a picture
betterimsg send --to "+14155551212" --text "hi" --file ~/Desktop/pic.jpg --service imessage
```

## Attachment notes
`--attachments` prints per-attachment lines with name, MIME, missing flag, and resolved path (tilde expanded). Only metadata is shown; files aren’t copied.

## JSON output
`betterimsg chats --json` emits one JSON object per chat with fields: `id`, `name`, `identifier`, `service`, `last_message_at`.
`betterimsg history --json` and `betterimsg watch --json` emit one JSON object per message with fields: `id`, `chat_id`, `guid`, `reply_to_guid`, `destination_caller_id`, `sender`, `is_from_me`, `text`, `created_at`, `attachments` (array of metadata with `filename`, `transfer_name`, `uti`, `mime_type`, `total_bytes`, `is_sticker`, `original_path`, `missing`), `reactions`.

Note: `reply_to_guid`, `destination_caller_id`, and `reactions` are read-only metadata.

## Permissions troubleshooting
If you see “unable to open database file” or empty output:
1) Grant Full Disk Access: System Settings → Privacy & Security → Full Disk Access → add your terminal.
2) Ensure Messages.app is signed in and `~/Library/Messages/chat.db` exists.
3) For send, allow the terminal under System Settings → Privacy & Security → Automation → Messages.

## Testing
```bash
make test
```

Note: `make test` applies a small patch to SQLite.swift to silence a SwiftPM warning about `PrivacyInfo.xcprivacy`.

## Linting & formatting
```bash
make lint
make format
```

## Core library
The reusable Swift core lives in `Sources/IMsgCore` and is consumed by the CLI target. Apps can depend on the `IMsgCore` library target directly.
