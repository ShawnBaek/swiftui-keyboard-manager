import SwiftUI
import SwiftUIKeyboardManager

@main
struct KeyboardDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ProfileFormView()
        }
    }
}

private struct ProfileFormView: View {
    private enum Field: Hashable {
        case name
        case email
        case role
        case location
        case bio
    }

    @State private var name = ""
    @State private var email = ""
    @State private var role = ""
    @State private var location = ""
    @State private var bio = ""
    @State private var swipeToDismiss: SwipeToDismiss = .onDrag
    @FocusState private var focusedField: Field?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    keyboardBehaviorPicker
                    profileFields
                    actions
                }
                .padding()
            }
            .keyboardManager(dismiss: swipeToDismiss)
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Keyboard-aware profile form")
                .font(.title2.weight(.bold))
            Text("Focus any field to keep it comfortably visible while editing. Change the swipe mode to compare keyboard dismissal behavior.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var keyboardBehaviorPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Swipe to dismiss")
                .font(.headline)
            Picker("Swipe to dismiss", selection: $swipeToDismiss) {
                ForEach(SwipeToDismiss.allCases, id: \.self) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("keyboard-demo-mode-picker")
        }
    }

    private var profileFields: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Your details")
                .font(.headline)

            TextField("Name", text: $name)
                .textContentType(.name)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .name)
                .accessibilityIdentifier("keyboard-demo-name")

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .email)
                .accessibilityIdentifier("keyboard-demo-email")

            TextField("Role", text: $role)
                .textContentType(.jobTitle)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .role)
                .accessibilityIdentifier("keyboard-demo-role")

            TextField("Location", text: $location)
                .textContentType(.fullStreetAddress)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .location)
                .accessibilityIdentifier("keyboard-demo-location")

            VStack(alignment: .leading, spacing: 8) {
                Text("About you")
                    .font(.subheadline.weight(.medium))
                TextEditor(text: $bio)
                    .frame(minHeight: 160)
                    .padding(4)
                    .scrollContentBackground(.hidden)
                    .background(.background, in: RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.quaternary, lineWidth: 1)
                    }
                    .focused($focusedField, equals: .bio)
                    .accessibilityIdentifier("keyboard-demo-bio")
            }
        }
    }

    private var actions: some View {
        HStack {
            Button("Dismiss keyboard") {
                focusedField = nil
            }
            .buttonStyle(.bordered)

            Button("Focus next", action: focusNextField)
                .buttonStyle(.borderedProminent)
        }
        .accessibilityElement(children: .contain)
    }

    private func focusNextField() {
        switch focusedField {
        case .name:
            focusedField = .email
        case .email:
            focusedField = .role
        case .role:
            focusedField = .location
        case .location:
            focusedField = .bio
        case .bio, nil:
            focusedField = .name
        }
    }
}

private extension SwipeToDismiss {
    var title: String {
        switch self {
        case .never:
            "Never"
        case .onDrag:
            "On Drag"
        case .interactive:
            "Interactive"
        }
    }
}
