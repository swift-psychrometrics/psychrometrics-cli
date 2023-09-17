import ArgumentParser
import CLIClient
import Dependencies
import Foundation
import PsychrometricClient

struct WetBulbCommand: AsyncParsableCommand {
  static var configuration: CommandConfiguration = .init(
    commandName: "wet-bulb",
    abstract: "Calculate the wet bulb temperature of an air stream."
  )

  @OptionGroup var globals: MoistAirOptions

  func run() async throws {
    @Dependency(\.cliClient) var cliClient
    @Dependency(\.psychrometricClient.wetBulb) var wetBulb

    let wetBulbValue = try await wetBulb(
      .dryBulb(
        globals.dryBulbTemperature,
        relativeHumidity: globals.relativeHumidityValue,
        totalPressure: .init(altitude: globals.altitudeValue, units: globals.units),
        units: globals.units
      )
    )
    print(cliClient.string(wetBulbValue.rawValue, withSymbol: globals.includeSymbols))
  }
}
