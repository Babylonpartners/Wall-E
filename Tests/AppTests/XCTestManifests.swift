#if !canImport(ObjectiveC)
import XCTest

extension JSONLoggerTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__JSONLoggerTests = [
        ("test_json_logs_formatting", test_json_logs_formatting),
        ("test_loglevel_compare_custom_level", test_loglevel_compare_custom_level),
        ("test_loglevel_compare_info_level", test_loglevel_compare_info_level),
        ("test_loglevel_compare_verbose_level", test_loglevel_compare_verbose_level),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(JSONLoggerTests.__allTests__JSONLoggerTests),
    ]
}
#endif
