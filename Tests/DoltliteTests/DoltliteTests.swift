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
}
