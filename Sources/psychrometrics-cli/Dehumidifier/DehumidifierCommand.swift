import ArgumentParser
import Foundation

struct DehumidifierCommand: AsyncParsableCommand {
  
  static let configuration = CommandConfiguration(
    commandName: "dh",
    abstract: "Perform dehumidifier / dehumidification calculations or conversions.",
    subcommands: [
      SizingCommand.self,
      PoundsRemovedCommand.self
    ],
    defaultSubcommand: SizingCommand.self
  )
}
