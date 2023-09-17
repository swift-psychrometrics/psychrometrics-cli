import ArgumentParser
import CLIClient
import Dependencies
import Foundation
import PsychrometricClient

struct PsychrometricProperties: AsyncParsableCommand {
  static var configuration: CommandConfiguration = .init(
    commandName: "properties",
    abstract: "Cacluate the psychrometric properties of an air stream.",
    discussion: """
    Either a dew-point, relative-humidity, or wet-bulb temperature is required, or
    an error will be thrown and the calulation will not be able to be completed.
    """
  )
  
  @Option(
    name: .shortAndLong,
    help: "The dry bulb temperature of the air stream."
  )
  var dryBulb: Double
  
  @Option(
    name: [.customShort("p"), .long],
    help: "The dew point temperature of the air stream."
  )
  var dewPoint: Double?


  @Option(
    name: .shortAndLong,
    help: "The relative humidity of the air stream."
  )
  var relativeHumidity: Double?
  
  @Option(
    name: .shortAndLong,
    help: "The wet bulb point temperature of the air stream."
  )
  var wetBulb: Double?
  
  @Option(
    name: .shortAndLong,
    help: "The altitude of the project."
  )
  var altitude: Double = 0

  @Flag(
    name: .long,
    inversion: .prefixedEnableDisable,
    help: "Include symbols in the output."
  )
  var symbols: Bool = true
  
  var includeSymbols: Bool { symbols }

  @OptionGroup var globals: BaseOptions

  func run() async throws {
    @Dependency(\.cliClient) var cliClient

    let properties = try await cliClient.properties(.init(
      altitude: self.altitude,
      dryBulb: self.dryBulb,
      dewPoint: self.dewPoint,
      relativeHumidity: self.relativeHumidity,
      wetBulb: self.wetBulb,
      units: self.globals.units
    ))

    print()
    print("Psychrometric Properties:")
    print("-----------------------------------")
    print()
    print("Atmospheric Pressure:    \(cliClient.string(properties.atmosphericPressure.rawValue, withSymbol: self.includeSymbols))")
    print("Degree of Saturation:    \(cliClient.string(properties.degreeOfSaturation.rawValue))")
    print("Density:                 \(cliClient.string(properties.density.rawValue, withSymbol: self.includeSymbols))")
    print("Dew Point Temperature:   \(cliClient.string(properties.dewPoint.rawValue, withSymbol: self.includeSymbols))")
    print("Dry Bulb Temperature:    \(cliClient.string(properties.dryBulb.rawValue, withSymbol: self.includeSymbols))")
    print("Enthalpy:                \(cliClient.string(properties.enthalpy.rawValue, withSymbol: self.includeSymbols))")
    print("Grains of Moisture:      \(cliClient.string(properties.grainsOfMoisture.rawValue)) \(self.includeSymbols ? "gr/lb" : "")")
    print("Humidity Ratio:          \(cliClient.string(properties.humidityRatio.value))")
    print("Relative Humidity:       \(cliClient.string(properties.relativeHumidity.value, decimalPlaces: 0))\(self.includeSymbols ? "%" : "")")
    print("Specific Volume:         \(cliClient.string(properties.specificVolume.rawValue))")
    print("Vapor Pressure:          \(cliClient.string(properties.vaporPressure.rawValue, withSymbol: self.includeSymbols))")
    print("Wet Bulb Temperature:    \(cliClient.string(properties.wetBulb.rawValue, withSymbol: self.includeSymbols))")
    print()
    print("-----------------------------------")
    print()
  }
}
