import Foundation

struct App: Decodable {
    let name: String
    let url: String
    let evidence: String
}

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let apps = try JSONDecoder().decode([App].self, from: Data(contentsOf: root.appendingPathComponent("Documentation/apps.json")))
func validURL(_ string: String) -> Bool {
    guard let url = URL(string: string) else { return false }
    return url.scheme == "https" && url.host != nil && !string.contains("\n") && !string.contains(")")
}
for app in apps {
    guard !app.name.isEmpty, !app.name.contains("\n"), !app.name.contains("]"),
          validURL(app.url), validURL(app.evidence) else {
        fatalError("Invalid showcase entry")
    }
}
let file = root.appendingPathComponent("README.md")
var readme = try String(contentsOf: file, encoding: .utf8)
let start = "<!-- APPS:START -->"
let end = "<!-- APPS:END -->"
guard let a = readme.range(of: start), let b = readme.range(of: end), a.upperBound <= b.lowerBound else {
    fatalError("Showcase markers missing")
}
let body = apps.isEmpty ? "No published integrations registered yet." :
    apps.sorted { $0.name < $1.name }.map { "- [\($0.name)](\($0.url)) — [integration evidence](\($0.evidence))" }.joined(separator: "\n")
readme.replaceSubrange(a.upperBound..<b.lowerBound, with: "\n" + body + "\n")
try readme.write(to: file, atomically: true, encoding: .utf8)
