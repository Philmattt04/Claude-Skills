---
name: kafa-dev
description: Development assistant for the KAFA Member Portal Flutter project at /Users/philsterr/Projects/kafa_member. Handles the three most common tasks: (1) adding multi-language strings to app_strings.dart across all 5 languages, (2) scaffolding a new screen with project patterns, (3) extending demo mode mock data. Triggered when the user wants to add strings, add a screen, or update demo data in the KAFA project.
---

# KAFA Member Portal Dev Skill

You are assisting with the **KAFA Member Portal** — a Flutter insurance cooperative management app. The app supports 5 languages (FR, EN, HT, ES, PT) and runs in demo mode by default (member ID prefix `MK-DEMO`).

Key files:
- `lib/misc/app_strings.dart` — 5-language string map (~1,830 lines)
- `lib/screens/member_dashboard_screen.dart` — Main 4-tab screen (~2,952 lines)
- `lib/services/api_service.dart` — AWS SigV4-signed HTTP calls
- `lib/main.dart` — Entry point, theme, routing

Brand colors: `_green = Color(0xFF1A5C2A)`, `_gold = Color(0xFFC8A96E)`, `_bg = Color(0xFFF2F4F7)`

---

## Task 1 — Add Multi-Language Strings

Use this when the user needs to add new UI text that must appear in all 5 languages.

### Steps

**1. Identify what strings are needed.**
Ask the user for the key name(s) and the English text. Example:
> "What key name should I use, and what's the English text?"

If the user gives English only, derive the other 4 languages using your knowledge (or ask if precision is critical).

**2. Read the current bottom of each language block.**
The structure of `app_strings.dart` is:
```dart
class AppStrings {
  static const Map<String, Map<String, String>> _data = {
    'fr': { ... },
    'en': { ... },
    'ht': { ... },
    'es': { ... },
    'pt': { ... },
  };
  ...
}
```
Find the section each new key belongs in (use the existing comment sections like `// Login`, `// Payment`, etc.) and add the key to **all 5 language blocks** in the same relative position within the section.

**3. Generate translations.**
Provide translations for all 5 languages. Use formal register matching the existing strings. Language notes:
- `fr` — French (formal, e.g. "vous")
- `en` — English
- `ht` — Haitian Creole (e.g. "mèsi" for thanks, "ou" for you)
- `es` — Spanish (formal, "usted" register in UI labels, informal in messages)
- `pt` — Portuguese (Brazilian, informal register is fine for UI)

**4. Edit the file.**
Add the key-value pair in each of the 5 language blocks. Always keep the same section grouping (comment-guided) across all languages.

**5. Verify usage.**
Show the user how to use the new string in a widget:
```dart
AppStrings.get('yourKey', context)
// or however the project retrieves strings — check the get() method in app_strings.dart
```

---

## Task 2 — Scaffold a New Screen

Use this when the user wants to add a new screen to the app.

### Steps

**1. Clarify the screen.**
Ask: screen name, purpose, which tab it belongs to (Dashboard / Policies / Services / Profile), and whether it needs API data or demo-mode mock data.

**2. Create the screen file** at `lib/screens/{name}_screen.dart` using this template:

```dart
import 'package:flutter/material.dart';

// Brand colors (match app-wide palette)
const _green = Color(0xFF1A5C2A);
const _gold  = Color(0xFFC8A96E);
const _bg    = Color(0xFFF2F4F7);

class YourNameScreen extends StatefulWidget {
  final String memberId;
  const YourNameScreen({super.key, required this.memberId});

  @override
  State<YourNameScreen> createState() => _YourNameScreenState();
}

class _YourNameScreenState extends State<YourNameScreen> {
  bool _loading = true;
  String? _error;
  // TODO: add your data fields here

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Demo mode: skip API call
    if (widget.memberId.startsWith('MK-DEMO')) {
      setState(() {
        // TODO: assign mock data here
        _loading = false;
      });
      return;
    }
    try {
      // TODO: call ApiService
      setState(() => _loading = false);
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _green,
        foregroundColor: Colors.white,
        title: const Text('Screen Title'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    return const Placeholder(); // TODO: replace with real UI
  }
}
```

**3. Wire it up.**
Show the user where to add navigation — typically a `Navigator.push` call inside `member_dashboard_screen.dart` or from another screen. Use `MaterialPageRoute`.

**4. Add any required strings** to `app_strings.dart` (see Task 1).

---

## Task 3 — Extend Demo Mode Mock Data

Use this when the user wants to add or update hardcoded demo data for `MK-DEMO` users so the app works fully offline in demo mode.

### Steps

**1. Identify where demo data lives.**
Search `member_dashboard_screen.dart` for `_demoPolicies` and `MK-DEMO` patterns. Demo data is usually defined as a `const List<Map<String, dynamic>>` near the top of the relevant `State` class or as a file-level constant.

**2. Clarify what mock data is needed.**
Ask the user what entity (policies, transactions, beneficiaries, partners, etc.) and what realistic values to use.

**3. Follow the existing mock data structure.**
Read the real API response shape from `api_service.dart` (look at the endpoint's `jsonDecode` handling) to match the exact field names and types.

**4. Add the demo guard.**
All demo data returns must be gated:
```dart
if (memberId.startsWith('MK-DEMO')) {
  // return mock data, skip API call
  return _demoYourEntity;
}
```

**5. Update both state classes if needed.**
`member_dashboard_screen.dart` has multiple `State` classes (`_DashboardTabState`, `_TransactionsTabState`, etc.) — update any that fetch the same entity type.

---

## General Guidance

- **Never break demo mode.** Every API fetch must have an `MK-DEMO` guard that returns mock data.
- **Always update all 5 language blocks** when touching `app_strings.dart` — a missing language key throws at runtime if that locale is active.
- **Match the color palette** — use `_green`, `_gold`, `_bg` constants rather than raw hex values in new screens.
- **No new dependencies** unless discussed — the pubspec is already stable.
- **Stripe integration** is platform-conditional — if touching payment flows, check both `stripe_confirmer.dart` (native) and `stripe_confirmer_web.dart` (web).
