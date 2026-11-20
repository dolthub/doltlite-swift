import XCTest
@testable import Doltlite

final class DoltliteTests: XCTestCase {
    func testCommitRoundTrip() throws {
        let db = try Doltlite(":memory:")

        let engine = try db.query("SELECT doltlite_engine()").first?.first ?? nil
        XCTAssertEqual(engine, "prolly")

        try db.execute("CREATE TABLE t(id INTEGER PRIMARY KEY, v TEXT)")
        try db.execute("INSERT INTO t VALUES (1, 'a')")

        let hash = try db.commit(message: "c1")
        XCTAssertNotNil(hash)

        // Initial commit plus c1 => 2 rows in dolt_log.
        let count = try db.query("SELECT count(*) FROM dolt_log").first?.first ?? nil
        XCTAssertEqual(count, "2")
    }

    func testQueryThrowsAfterReadingARow() throws {
        let db = try Doltlite(":memory:")

        XCTAssertThrowsError(try db.query("SELECT 1 UNION ALL SELECT json_extract('invalid', '$')")) { error in
            guard case Doltlite.Error.exec(let message) = error else {
                return XCTFail("Expected an execution error, got \(error)")
            }
            XCTAssertEqual(message, "malformed JSON")
        }
        XCTAssertEqual(try db.query("SELECT 1 WHERE 0"), [])
        XCTAssertEqual(try db.query("-- no statement"), [])
        XCTAssertEqual(try db.query("SELECT 1, NULL"), [["1", nil]])
    }
}
