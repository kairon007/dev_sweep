You’re not building a “cleanup tool”—you’re building a **developer environment garbage collector with guardrails**. Treat it like infra software: deterministic, observable, reversible.

Below is a **production-grade macOS app spec** tailored to your workflows (Android, Flutter, iOS, IntelliJ/AS).

---

# 0) Product Definition

**Name (working):** DevSweep
**Category:** Developer Tooling / Disk Management
**Positioning:** “CleanMyMac for engineers — deterministic, safe, cache-aware”

**Core promise:**

> Reclaim disk space **without breaking builds**

---

# 1) Target Users

* Mobile engineers (Android / iOS / Flutter)
* Multi-repo developers
* Low-storage Mac users (256–512 GB)

---

# 2) Core Use Cases

### Primary

* “I hit `No space left on device` → fix in 1 click”

### Secondary

* Periodic cleanup (weekly automation)
* Project pruning
* Toolchain version pruning

---

# 3) System Architecture

## 3.1 High-level

```
[SwiftUI App]
     ↓
[Cleanup Engine (Swift)]
     ↓
[Rule Engine + Scanner]
     ↓
[Filesystem Ops Layer]
     ↓
[macOS APIs / Shell Execution]
```

---

## 3.2 Modules

### A. Scanner Engine

* Traverses known dev directories
* Calculates:

    * Size
    * Last accessed
    * Type classification

### B. Rule Engine

Encodes cleanup logic:

```json
{
  "rule": "delete_gradle_cache",
  "safe": true,
  "paths": ["~/.gradle/caches"],
  "requires_confirmation": false
}
```

---

### C. Action Executor

* Performs deletion
* Handles:

    * Permissions
    * Failures
    * Partial cleanup

---

### D. Safety Layer (critical)

* Dry run mode
* Snapshot logs
* Undo (Trash-based recovery)

---

### E. UI Layer

* SwiftUI
* Reactive state
* Real-time disk updates

---

# 4) Feature Set

---

## 4.1 Smart Scan (Core)

**Output:**

| Category     | Size  | Risk   | Action |
| ------------ | ----- | ------ | ------ |
| Gradle Cache | 12 GB | Safe   | Auto   |
| DerivedData  | 18 GB | Safe   | Auto   |
| Simulators   | 25 GB | Medium | Review |
| Projects     | 80 GB | Risky  | Manual |

---

## 4.2 Cleanup Categories

### ANDROID

* Gradle:

    * `~/.gradle/caches`
    * `daemon`, `wrapper`

* Android Studio:

    * `~/Library/Caches/Google/AndroidStudio*`

* SDK:

    * Old platforms
    * Old build-tools
    * System images

---

### iOS

* DerivedData
* Archives
* Simulators:

    * Delete unavailable
    * Delete old runtimes

---

### PROJECTS

* Sort by:

    * Last opened
    * Size
* Rules:

    * Keep last N
    * Delete > X GB
    * Git repos only (optional filter)

---

### SYSTEM DEV JUNK

* Homebrew cache
* CocoaPods cache
* npm/yarn cache (optional extension)

---

# 5) UI/UX Specification

---

## 5.1 Main Dashboard

**Top:**

* Disk usage bar (like Xcode storage view)
* “You can free: 67.4 GB”

**Sections:**

### 1. Safe Cleanup (1-click)

* Gradle
* DerivedData
* Temp caches

👉 Button: **“Clean Safe Items”**

---

### 2. Review Required

Cards:

#### Example:

```
📦 iOS Simulators — 28 GB
[View Details] [Clean]
```

---

### 3. Projects

Grid/list:

```
Project Name | Size | Last Opened | Action
```

Filters:

* > 5GB
* Not opened in 30 days

---

## 5.2 Deep View (Drill-down)

Example: “Android SDK”

```
✔ API 34 (keep)
❌ API 30 (remove)
❌ API 29 (remove)
```

---

## 5.3 Confirmation UX

Not annoying. Only where needed:

* Bulk delete → confirm once
* Safe deletes → no prompt

---

## 5.4 Feedback

* Progress bar
* Live reclaimed space counter
* Post-clean summary:

```
✔ Freed 42.6 GB
✔ No build tools affected
```

---

# 6) Safety Model (non-negotiable)

---

## 6.1 Risk Classification

| Level  | Example      | Behavior           |
| ------ | ------------ | ------------------ |
| Safe   | Gradle cache | Auto-delete        |
| Medium | Simulators   | Confirm            |
| Risky  | Projects     | Explicit selection |

---

## 6.2 Undo Strategy

* Move to `~/.Trash` instead of permanent delete
* Optional:

    * “Keep for 7 days”

---

## 6.3 Dry Run Mode

Shows:

```
Will delete:
- ~/.gradle/caches (12 GB)
- DerivedData (18 GB)
```

---

# 7) Performance Considerations

* Use:

    * `FileManager` with lazy traversal
    * Avoid blocking main thread
* Parallel scanning (DispatchQueues)

---

# 8) Tech Stack

---

## Option A (Recommended)

### Native macOS

* Language: **Swift**
* UI: **SwiftUI**
* Shell ops: `Process`

---

## Option B (Your strength)

### Flutter Desktop

* Pros:

    * Faster dev for you
    * Cross-platform future

* Cons:

    * Less native feel
    * Permissions handling trickier

---

# 9) Extensibility

Design rule engine to support:

* Node.js cleanup
* Docker cleanup
* Python venv cleanup

---

# 10) Automation

---

## Scheduled Cleanup

Use:

* `launchd` (mac-native, better than cron)

Example:

* Weekly safe cleanup

---

# 11) Competitive Differentiation

Compared to generic tools:

| Tool       | Problem                       |
| ---------- | ----------------------------- |
| CleanMyMac | Doesn’t understand dev caches |
| DaisyDisk  | Visualization only            |
| DevSweep   | Context-aware + safe          |

---

# 12) MVP Scope (build this first)

**Phase 1:**

* Scan
* Safe cleanup
* Project pruning
* DerivedData + Gradle

**Phase 2:**

* SDK pruning
* Simulator management
* Automation

**Phase 3:**

* Smart recommendations
* External disk offloading

---

# 13) Advanced Ideas (worth it)

* “Before build cleanup” hook
* IntelliJ / Android Studio plugin trigger
* Disk pressure watcher (auto-trigger)

---

# 14) Example User Flow

1. App opens

2. Shows:

   > “You can free 58 GB”

3. User clicks:
   → “Clean Safe Items”

4. Then:
   → Reviews projects > deletes 2

5. Done in **< 60 seconds**

---

# 15) What will break if done wrong

Be precise here:

* Deleting active SDK → build failure
* Removing wrong Gradle dirs → re-download cost
* Deleting project metadata → IDE corruption

That’s why:
👉 Rule engine + classification matters

---


