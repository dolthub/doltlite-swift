import CDoltlite
import Foundation

/// A DoltLite database connection: SQLite plus Dolt version control.
///
/// `Doltlite` is a thin Swift layer over the doltlite C API. The full
/// `sqlite3_*` C API is also available via `import CDoltlite`, and the
/// `dolt_*` version-control functions (`dolt_commit`, `dolt_branch`,
/// `dolt_merge`, `dolt_diff`, ...) are reached through SQL.
public final class Doltlite {
    public enum Error: Swift.Error, CustomStringConvertible {
        case open(code: Int32, message: String)
        case exec(message: String)
        case prepare(message: String)

        public var description: String {
            switch self {
            case let .open(code, message): return "doltlite open failed (\(code)): \(message)"
            case let .exec(message): return "doltlite exec failed: \(message)"
            case let .prepare(message): return "doltlite prepare failed: \(message)"
            }
        }
    }

    /// The underlying `sqlite3*` handle, for direct C API use.
    public private(set) var handle: OpaquePointer?

    /// Open (creating if needed) a database at `path`. Use ":memory:" for an
    /// in-memory database.
    public init(_ path: String) throws {
        var db: OpaquePointer?
        let rc = sqlite3_open(path, &db)
        if rc != SQLITE_OK {
            let message = db.flatMap { String(cString: sqlite3_errmsg($0)) } ?? "unknown error"
            sqlite3_close(db)
            throw Error.open(code: rc, message: message)
        }
        handle = db
    }

    deinit {
        sqlite3_close(handle)
    }

    /// Run one or more SQL statements, discarding any result rows.
    public func execute(_ sql: String) throws {
        var errorPointer: UnsafeMutablePointer<CChar>?
        let rc = sqlite3_exec(handle, sql, nil, nil, &errorPointer)
        if rc != SQLITE_OK {
            let message = errorPointer.map { String(cString: $0) } ?? "unknown error"
            sqlite3_free(errorPointer)
            throw Error.exec(message: message)
        }
    }

    /// Run a query and return its rows as arrays of column values (text, with
    /// NULL as nil). For typed access, use the C API via `handle`.
    public func query(_ sql: String) throws -> [[String?]] {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(handle, sql, -1, &statement, nil) == SQLITE_OK else {
            let message = handle.flatMap { String(cString: sqlite3_errmsg($0)) } ?? "unknown error"
            throw Error.prepare(message: message)
        }
        defer { sqlite3_finalize(statement) }

        var rows: [[String?]] = []
        let columnCount = sqlite3_column_count(statement)
        while sqlite3_step(statement) == SQLITE_ROW {
            var row: [String?] = []
            for column in 0..<columnCount {
                if let text = sqlite3_column_text(statement, column) {
                    row.append(String(cString: text))
                } else {
                    row.append(nil)
                }
            }
            rows.append(row)
        }
        return rows
    }

    /// Convenience for `SELECT dolt_commit(...)`. Stages all changes when
    /// `all` is true. Returns the new commit hash.
    @discardableResult
    public func commit(message: String, all: Bool = true) throws -> String? {
        let args = all ? "'-A', '-m', ?" : "'-m', ?"
        var statement: OpaquePointer?
        let sql = "SELECT dolt_commit(\(args))"
        guard sqlite3_prepare_v2(handle, sql, -1, &statement, nil) == SQLITE_OK else {
            let errorMessage = handle.flatMap { String(cString: sqlite3_errmsg($0)) } ?? "unknown error"
            throw Error.prepare(message: errorMessage)
        }
        defer { sqlite3_finalize(statement) }
        // SQLITE_TRANSIENT: tell SQLite to copy the string.
        let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        sqlite3_bind_text(statement, 1, message, -1, transient)
        guard sqlite3_step(statement) == SQLITE_ROW else {
            let errorMessage = handle.flatMap { String(cString: sqlite3_errmsg($0)) } ?? "unknown error"
            throw Error.exec(message: errorMessage)
        }
        return sqlite3_column_text(statement, 0).map { String(cString: $0) }
    }

    /// The doltlite version string (`SELECT dolt_version()`).
    public func version() throws -> String? {
        try query("SELECT dolt_version()").first?.first ?? nil
    }
}
