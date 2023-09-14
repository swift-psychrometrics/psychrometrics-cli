import ArgumentParser
import PsychrometricClientLive

@main
struct PsychrometricCli: AsyncParsableCommand {
  static let configuration: CommandConfiguration = .init(
    commandName: "psychrometrics",
    abstract: "A command line utility to perform psychrometric calculations.",
    version: VERSION,
    subcommands: [
      DehumdifierSizingCommand.self,
      DewPointCommand.self,
      EnthalpyCommand.self,
      GrainsCommand.self,
      PoundsRemovedCommand.self,
      PsychrometricProperties.self,
      WetBulbCommand.self
    ],
    defaultSubcommand: PsychrometricProperties.self
  )
}
