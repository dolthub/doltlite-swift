# Doltlite for Swift

[DoltLite](https://github.com/dolthub/doltlite) for iOS and macOS: SQLite with
Dolt-style version control — `dolt_commit`, `dolt_branch`, `dolt_merge`,
`dolt_diff`, and the rest — shipped as a prebuilt XCFramework.

Dolt can't run on iOS (it's written in Go); DoltLite is the Dolt-compatible
engine that can.

## Install

Swift Package Manager — in Xcode, **File ▸ Add Package Dependencies** and enter:

```
https://github.com/dolthub/doltlite-swift
```

Or in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/dolthub/doltlite-swift", from: "0.11.17")
]
```

Platforms: iOS 14+, macOS 11+, Mac Catalyst 14+.

## Usage

```swift
import Doltlite

let db = try Doltlite("/path/to/app.db")   // or ":memory:"

try db.execute("CREATE TABLE notes(id INTEGER PRIMARY KEY, body TEXT)")
try db.execute("INSERT INTO notes(body) VALUES ('first note')")

let hash = try db.commit(message: "add first note")
print("committed", hash ?? "")

for row in try db.query("SELECT commit_hash, message FROM dolt_log") {
    print(row[0] ?? "", row[1] ?? "")
}
```

### Full C API

The complete `sqlite3_*` C API is available — import the C module directly, or
reach the underlying handle from a `Doltlite` instance:

```swift
import CDoltlite

let raw = db.handle   // OpaquePointer? to the sqlite3* connection
```

The `dolt_*` version-control functions and virtual tables (`dolt_log`,
`dolt_status`, `dolt_diff`, `dolt_branches`, ...) are invoked through SQL.

## License

Apache-2.0. The bundled engine is built from
[dolthub/doltlite](https://github.com/dolthub/doltlite); SQLite itself is public
domain.
