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

  @Option(
    name: .shortAndLong,
    help: "The altitude of the project."
  )
  var altitude: Double = 0
  
  @Option(
    name: .shortAndLong,
    help: "The dry bulb temperature of the air stream."
  )
  var dryBulb: Double
  
  @Option(
    name: .shortAndLong,
    help: "The relative humidity of the air stream."
  )
  var relativeHumidity: Double
  
  @OptionGroup var globals: BasePsychrometricOptions

  func run() async throws {
    @Dependency(\.cliClient) var cliClient

    let output = try await cliClient.grains(
      .init(
        altitude: self.altitude,
        dryBulb: self.dryBulb,
        relativeHumidity: self.relativeHumidity,
        units: globals.units
      )
    )
      .map { cliClient.string($0, withSymbol: globals.includeSymbols) }
    
    print(output)
  }
}
