import ArgumentParser
import Foundation
import SharedModels

// Represents common options for many of the commands.
struct MoistAirOptions: ParsableArguments {

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

  @Flag(help: "The units of measure.")
  var units: PsychrometricUnits = .imperial

  // A helper to convert to an actual dry-bulb temperature type.
  var dryBulbTemperature: DryBulb {
    .init(.init(dryBulb, units: .defaultFor(units: units)))
  }

  // A helper to convert to an actual relative humidity type.
  var relativeHumidityValue: RelativeHumidity {
    .init(.init(relativeHumidity))
  }

  // A helper to convert to an actual length type.
  var altitudeValue: Length {
    .init(altitude, units: .defaultFor(units: units))
  }

  var includeSymbols: Bool { symbols }
}

extension PsychrometricUnits: EnumerableFlag { }
