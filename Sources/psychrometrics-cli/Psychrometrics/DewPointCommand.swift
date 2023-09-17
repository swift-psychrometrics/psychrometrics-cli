import ArgumentParser
import CLIClient
import Dependencies
import Foundation
import PsychrometricClient

struct DewPointCommand: AsyncParsableCommand {
  static var configuration: CommandConfiguration = .init(
    commandName: "dew-point",
    abstract: "Calculate the dew point temperature of an air stream."
  )

  @OptionGroup var globals: MoistAirOptions

  func run() async throws {
    @Dependency(\.cliClient) var cliClient
    @Dependency(\.psychrometricClient.dewPoint) var dewPoint

    let dewPointTemperature = try await dewPoint(
      .dryBulb(
        globals.dryBulbTemperature,
        relativeHumidity: globals.relativeHumidityValue,
        units: globals.units
      )
    )

    print(cliClient.string(dewPointTemperature.rawValue, withSymbol: globals.includeSymbols))
  }
}
