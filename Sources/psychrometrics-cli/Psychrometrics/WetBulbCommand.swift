import ArgumentParser
import CLIClient
import Dependencies
import Foundation
import PsychrometricClient

// TODO: Fix
struct WetBulbCommand: AsyncParsableCommand {
  static var configuration: CommandConfiguration = .init(
    commandName: "wet-bulb",
    abstract: "Calculate the wet bulb temperature of an air stream.",
    discussion: """
      This offers several ways to calculate the enthalpy. All
      calculations require the dry bulb temperature to be supplied.
       
      Please note that the options that require total pressure or altitude will
      use the default altitude of sea level if it is not overriden.
      
      The following is a list of any other arguments that are required
      for a given calculation.
      
      \("Humidity Ratio".bold):     Must supply altitude or total pressure.
      
      \("Relative Humidity".bold):  Must supply altitude or total pressure.
    
    """
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
    help: "The humdity ratio of the air stream."
  )
  var humidityRatio: Double?
  
  @Option(
    name: .shortAndLong,
    help: "The relative humidity of the air stream."
  )
  var relativeHumidity: Double?
  
  @Option(
    name: .shortAndLong,
    help: "The total pressure of the air stream."
  )
  var totalPressure: Double?

  @OptionGroup var globals: BasePsychrometricOptions

  func run() async throws {
    @Dependency(\.cliClient) var cliClient

    let output = try await cliClient.wetBulb(
      .init(
        altitude: self.altitude,
        dryBulb: self.dryBulb,
        humidityRatio: self.humidityRatio,
        relativeHumidity: self.relativeHumidity,
        totalPressure: self.totalPressure,
        units: self.globals.units
      )
    )
      .map { cliClient.string($0, withSymbol: self.globals.includeSymbols) }
    
    print(output)
  }
}
