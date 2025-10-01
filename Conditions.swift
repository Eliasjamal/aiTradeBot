import Foundation

func evalCondition(_ expr: String?, values: [String: Any]) -> Bool {
    guard let expr = expr, !expr.isEmpty else { return true }
    // Very small subset: value('path') == 'STRING'
    let pattern = #"value\('([^']+)'\)\s*==\s*'([^']+)'"#
    if let r = try? NSRegularExpression(pattern: pattern) {
        let ns = expr as NSString
        if let m = r.firstMatch(in: expr, range: NSRange(location: 0, length: ns.length)) {
            let path = ns.substring(with: m.range(at: 1))
            let expected = ns.substring(with: m.range(at: 2))
            let actual = (values[path] as? String) ?? ""
            return actual == expected
        }
    }
    return true
}
