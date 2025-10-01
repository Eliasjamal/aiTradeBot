import Foundation

enum ComponentType: String, Codable {
    case textbox, number, textarea, select, date, time, datetime, checkbox, checkboxGroup
}

struct Option: Codable, Identifiable, Hashable {
    let label: String
    let value: String
    var id: String { value }
}

struct DataSource: Codable {
    enum Source: String, Codable { case `static`, endpoint }
    let source: Source
    let options: [Option]?
    let endpoint: String?
}

struct Validator: Codable {
    let type: String       // "required", "min", "max"
    let value: Double?
}

struct WhenExpr: Codable { let expr: String? }

struct Component: Codable, Identifiable {
    let id: String
    let type: ComponentType
    let label: String?
    let binding: String?
    let data: DataSource?
    let validators: [Validator]?
    let when: WhenExpr?
    let props: [String: String]?
}

struct SectionBlock: Codable, Identifiable {
    let id: String
    let type: String       // "card"
    let title: String?
    let components: [Component]?
}

struct ActionInvoke: Codable {
    let endpoint: String
    let method: String
    let bodyBinding: String?    // "$form"
}

struct ActionSpec: Codable, Identifiable {
    let id: String
    let type: String            // "button"
    let style: String?          // "primary"/"secondary"
    let label: String
    let when: WhenExpr?
    let invoke: ActionInvoke
}

struct LayoutPage: Codable {
    let type: String            // "page"
    let title: String?
    let sections: [SectionBlock]
    let actions: [ActionSpec]?
    let bindings: [String: AnyCodable]?
}

/// Minimal JSON “any” to decode `bindings`
struct AnyCodable: Codable {
    let value: Any
    init(_ v: Any) { value = v }
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let b = try? c.decode(Bool.self)   { value = b; return }
        if let i = try? c.decode(Int.self)    { value = i; return }
        if let d = try? c.decode(Double.self) { value = d; return }
        if let s = try? c.decode(String.self) { value = s; return }
        if let arr = try? c.decode([AnyCodable].self) { value = arr.map{$0.value}; return }
        if let dict = try? c.decode([String: AnyCodable].self) { value = dict.mapValues{$0.value}; return }
        value = NSNull()
    }
    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch value {
        case let b as Bool: try c.encode(b)
        case let i as Int: try c.encode(i)
        case let d as Double: try c.encode(d)
        case let s as String: try c.encode(s)
        case let arr as [Any]: try c.encode(arr.map{ AnyCodable($0) })
        case let dict as [String: Any]: try c.encode(dict.mapValues{ AnyCodable($0) })
        default: try c.encodeNil()
        }
    }
}
