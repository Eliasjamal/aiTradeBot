import Foundation
import SwiftUI

final class FormState: ObservableObject {
    @Published var values: [String: Any] = [:]   // "spa.qtyMt" -> 170000

    func seed(from bindings: [String: Any]) {
        func flatten(prefix: String, val: Any) {
            if let d = val as? [String: Any] {
                for (k, v) in d { flatten(prefix: prefix.isEmpty ? k : "\(prefix).\(k)", val: v) }
            } else { values[prefix] = val }
        }
        for (k, v) in bindings { flatten(prefix: k, val: v) }
    }

    func bindingString(_ path: String) -> Binding<String> {
        Binding(get: { (self.values[path] as? String) ?? "" },
                set: { self.values[path] = $0 })
    }
    func bindingDouble(_ path: String) -> Binding<Double> {
        Binding(get: { (self.values[path] as? Double) ?? 0 },
                set: { self.values[path] = $0 })
    }
    func bindingBool(_ path: String) -> Binding<Bool> {
        Binding(get: { (self.values[path] as? Bool) ?? false },
                set: { self.values[path] = $0 })
    }
    func bindingDate(_ path: String) -> Binding<Date> {
        let fmt = ISO8601DateFormatter()
        return Binding(get: {
            if let s = self.values[path] as? String, let d = fmt.date(from: s) { return d }
            return Date()
        }, set: { self.values[path] = fmt.string(from: $0) })
    }
}
