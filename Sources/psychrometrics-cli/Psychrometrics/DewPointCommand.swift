import ArgumentParser
import CLIClient
import Dependencies
import Foundation
import PsychrometricClient
import Rainbow

struct DewPointCommand: AsyncParsableCommand {
  static var configuration: CommandConfiguration = .init(
    commandName: "dew-point",
    abstract: "Calculate the dew point temperature of an air stream.",
    discussion: """
    This offers several ways to calculate the dew point temperature. All
    calculations require the dry bulb temperature to be supplied.  
     
    Please note that the options that require total pressure or altitude will
    use the default altitude of sea level if it is not overriden.   
    
    The following is a list of any other arguments that are required
    for a given calculation. 
    
    \("Humidity Ratio".bold):     Must supply total pressure or altitude.
    
    \("Relative Humidity".bold):  No other arguments required.
    
    \("Vapor Pressure".bold):     No other arguments required.
    
    \("Wet Bulb".bold):           Must supply total pressure or altitude.
    
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
  
  @Option(
    name: .shortAndLong,
    help: "The partial vapor pressure of the air stream."
  )
  var vaporPressure: Double?
  
  @Option(
    name: .shortAndLong,
    help: "The wet bulb temperature of the air stream."
  )
  var wetBulb: Double?

  @OptionGroup var globals: BasePsychrometricOptions

  func run() async throws {
    @Dependency(\.cliClient) var client

    let output = try await client.dewPoint(
      .init(
        altitude: self.altitude,
        dryBulb: self.dryBulb,
        humidityRatio: self.humidityRatio,
        relativeHumidity: self.relativeHumidity,
        totalPressure: self.totalPressure,
        vaporPressure: self.vaporPressure,
        wetBulb: self.wetBulb,
        units: self.globals.units
      )
    )
      .map { client.string($0, withSymbol: globals.includeSymbols) }

    print(output)
  }
}
