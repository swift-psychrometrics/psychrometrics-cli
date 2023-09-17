import ArgumentParser
import CLIClient
import Dependencies
import Foundation
import PsychrometricClient

struct GrainsCommand: AsyncParsableCommand {
  static var configuration: CommandConfiguration = .init(
    commandName: "grains",
    abstract: "Calculate the grains of moisture in an air stream."
  )

  @OptionGroup var globals: MoistAirOptions

  func run() async throws {
    @Dependency(\.cliClient) var cliClient
    @Dependency(\.psychrometricClient.grainsOfMoisture) var grains

    let grainsValue = try await grains(
      .dryBulb(
        globals.dryBulbTemperature,
        relativeHumidity: globals.relativeHumidityValue,
        altitude: globals.altitudeValue
      )
    )
    print("\(cliClient.string(grainsValue.rawValue))\(globals.includeSymbols ? " gr/lb" : "")")
  }
}
