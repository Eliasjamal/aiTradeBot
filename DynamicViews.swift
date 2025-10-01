import SwiftUI

struct DynamicPageView: View {
    let page: LayoutPage
    @StateObject var form = FormState()
    @State private var message: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let t = page.title { Text(t).font(.title2).bold() }
                ForEach(page.sections) { SectionCard(section: $0).environmentObject(form) }
                if let acts = page.actions {
                    HStack {
                        ForEach(acts) { ActionButton(action: $0).environmentObject(form) }
                    }
                }
                if let msg = message { Text(msg).foregroundColor(.secondary) }
            }.padding()
        }
        .onAppear {
            if let b = page.bindings {
                let flat = b.mapValues { $0.value }
                form.seed(from: flat)
            }
        }
    }
}

struct SectionCard: View {
    let section: SectionBlock
    @EnvironmentObject var form: FormState
    var body: some View {
        GroupBox(label: Text(section.title ?? "")) {
            VStack(spacing: 12) {
                ForEach(section.components ?? []) { c in
                    if evalCondition(c.when?.expr, values: form.values) {
                        ComponentView(component: c)
                    }
                }
            }.padding(.top, 6)
        }
    }
}

struct ComponentView: View {
    let component: Component
    @EnvironmentObject var form: FormState

    var body: some View {
        switch component.type {
        case .textbox:
            if let b = component.binding {
                TextField(component.label ?? "", text: form.bindingString(b))
                    .textInputAutocapitalization(.never)
            }
        case .number:
            if let b = component.binding {
                TextField(component.label ?? "", value: form.bindingDouble(b), format: .number)
                    .keyboardType(.decimalPad)
            }
        case .date:
            if let b = component.binding {
                DatePicker(component.label ?? "", selection: form.bindingDate(b), displayedComponents: .date)
            }
        case .checkbox:
            if let b = component.binding {
                Toggle(component.label ?? "", isOn: form.bindingBool(b))
            }
        case .select:
            if let b = component.binding {
                let options = component.data?.options ?? []
                Picker(component.label ?? "", selection: form.bindingString(b)) {
                    ForEach(options) { opt in Text(opt.label).tag(opt.value) }
                }
            }
        default:
            EmptyView()
        }
    }
}

struct ActionButton: View {
    let action: ActionSpec
    @EnvironmentObject var form: FormState
    @State private var sending = false
    @State private var result: String?

    var body: some View {
        Button {
            Task { await send() }
        } label: {
            if sending { ProgressView() } else { Text(action.label) }
        }
        .buttonStyle(action.style == "primary" ? .borderedProminent : .bordered)
        .disabled(sending)
    }

    private func send() async {
        sending = true; defer { sending = false }
        guard let url = URL(string: action.invoke.endpoint) else { result = "Bad URL"; return }
        var req = URLRequest(url: url)
        req.httpMethod = action.invoke.method
        if action.invoke.bodyBinding == "$form" {
            req.httpBody = try? JSONSerialization.data(withJSONObject: form.values)
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        do {
            let (_, resp) = try await URLSession.shared.data(for: req)
            if let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) {
                result = "Success"
            } else { result = "Failed" }
        } catch { result = error.localizedDescription }
        print("Submitted payload:", form.values)
    }
}
