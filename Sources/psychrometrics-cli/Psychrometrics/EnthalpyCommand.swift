import ArgumentParser
import CLIClient
import Dependencies
import Foundation
import PsychrometricClient

struct EnthalpyCommand: AsyncParsableCommand {
  static var configuration: CommandConfiguration = .init(
    commandName: "enthalpy",
    abstract: "Calculate the enthalpy of an air stream."
  )

  @OptionGroup var globals: MoistAirOptions

  func run() async throws {
    @Dependency(\.cliClient) var cliClient
    @Dependency(\.psychrometricClient.enthalpy.moistAir) var enthalpy

    let enthalpyValue = try await enthalpy(
      .dryBulb(
        globals.dryBulbTemperature,
        relativeHumidity: globals.relativeHumidityValue,
        altitude: globals.altitudeValue,
        units: globals.units
      )
    )
    print(cliClient.string(enthalpyValue.rawValue, withSymbol: globals.includeSymbols))
  }
}
