import ArgumentParser
import CLIDependency
import Dependencies
import Foundation
import PsychrometricClient

struct PsychrometricProperties: AsyncParsableCommand {
  static var configuration: CommandConfiguration = .init(
    commandName: "properties",
    abstract: "Cacluate the psychrometric properties of an air stream."
  )

  @OptionGroup var globals: MoistAirOptions

  func run() async throws {
    @Dependency(\.cliClient) var cliClient
    @Dependency(\.psychrometricClient.psychrometricProperties) var psychrometricProperties

    let properties = try await psychrometricProperties(
      .dryBulb(
        globals.dryBulbTemperature,
        relativeHumidity: globals.relativeHumidityValue,
        altitude: globals.altitudeValue,
        units: globals.units
      )
    )

    print()
    print("Psychrometric Properties:")
    print("-----------------------------------")
    print()
    print("Atmospheric Pressure:    \(cliClient.string(properties.atmosphericPressure.rawValue, withSymbol: globals.includeSymbols))")
    print("Degree of Saturation:    \(cliClient.string(properties.degreeOfSaturation.rawValue))")
    print("Density:                 \(cliClient.string(properties.density.rawValue, withSymbol: globals.includeSymbols))")
    print("Dew Point Temperature:   \(cliClient.string(properties.dewPoint.rawValue, withSymbol: globals.includeSymbols))")
    print("Dry Bulb Temperature:    \(cliClient.string(properties.dryBulb.rawValue, withSymbol: globals.includeSymbols))")
    print("Enthalpy:                \(cliClient.string(properties.enthalpy.rawValue, withSymbol: globals.includeSymbols))")
    print("Grains of Moisture:      \(cliClient.string(properties.grainsOfMoisture.rawValue)) \(globals.includeSymbols ? "gr/lb" : "")")
    print("Humidity Ratio:          \(cliClient.string(properties.humidityRatio.value))")
    print("Relative Humidity:       \(cliClient.string(properties.relativeHumidity.value, decimalPlaces: 0))\(globals.includeSymbols ? "%" : "")")
    print("Specific Volume:         \(cliClient.string(properties.specificVolume.rawValue))")
    print("Vapor Pressure:          \(cliClient.string(properties.vaporPressure.rawValue, withSymbol: globals.includeSymbols))")
    print("Wet Bulb Temperature:    \(cliClient.string(properties.wetBulb.rawValue, withSymbol: globals.includeSymbols))")
    print()
    print("-----------------------------------")
    print()
  }
}
