import ArgumentParser
import CLIClientLive
import PsychrometricClientLive

@main
struct PsychrometricCli: AsyncParsableCommand {
  static let configuration: CommandConfiguration = .init(
    commandName: "psychrometrics",
    abstract: "A command line utility to perform psychrometric calculations.",
    version: VERSION ?? "0.0.1",
    subcommands: [
      DehumidifierCommand.self,
      DewPointCommand.self,
      EnthalpyCommand.self,
      GrainsCommand.self,
      PsychrometricProperties.self,
      WetBulbCommand.self
    ],
    defaultSubcommand: PsychrometricProperties.self
  )
}
