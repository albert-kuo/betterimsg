import Commander
import Foundation
import Testing

@testable import betterimsg

@Test
func helpPrinterPrintsCommandDetails() throws {
  let signature = CommandSignature(
    arguments: [
      .make(label: "arg", help: "arg help")
    ],
    options: [
      .make(label: "opt", names: [.short("o"), .long("opt")], help: "opt help")
    ],
    flags: [
      .make(label: "flag", names: [.short("f"), .long("flag")], help: "flag help")
    ]
  )
  let spec = CommandSpec(
    name: "demo",
    abstract: "Demo command",
    discussion: "Extra details",
    signature: signature,
    usageExamples: ["betterimsg demo --opt 1"]
  ) { _, _ in }

  let lines = HelpPrinter.renderCommand(rootName: "betterimsg", spec: spec)
  let output = lines.joined(separator: "\n")
  #expect(output.contains("betterimsg demo"))
  #expect(output.contains("Arguments:"))
  #expect(output.contains("Options:"))
  #expect(output.contains("-o, --opt <value>"))
  #expect(output.contains("-f, --flag"))
}
