import ArgumentParser
@_exported import CLIClient
import Dependencies
import Foundation
import PsychrometricClient
import Rainbow

extension CLIClient: DependencyKey {
  
  public static func live(client: PsychrometricClient) -> Self {
    .init(
      dewPoint: { try await $0.output(client: client) },
      enthalpy: { try await $0.output(client: client) },
      grains: { try await $0.output(client: client) },
      numberFormatter: { formatter(decimalPlaces: $0) } ,
      properties: { try await $0.output(client: client) },
      wetBulb: { try await $0.output(client: client) }
    )
  }
  
  public static var liveValue: CLIClient {
    @Dependency(\.psychrometricClient) var client
    return .live(client: client)
  }
}

extension CLIClient.DewPointRequest {
  
  func totalPressureValue() throws -> TotalPressure {
    if let totalPressure = self.totalPressure {
      return TotalPressure(.init(totalPressure, units: .defaultFor(units: self.units)))
    } else if let altitude = self.altitude {
      return TotalPressure(
        altitude: .init(altitude, units: .defaultFor(units: self.units)),
        units: self.units
      )
    }
    throw ValidationError("""
      Either a total pressure or altitude is required with a humidity ratio.
    """.red.bold)
  }
  
  func output(client: PsychrometricClient) async throws -> DewPoint {
    let dryBulb = DryBulb(.init(self.dryBulb, units: .defaultFor(units: self.units)))
    
    if let humidityRatio = self.humidityRatio {
      let totalPressure = try self.totalPressureValue()
      return try await client.dewPoint(.dryBulb(
        dryBulb,
        humidityRatio: .init(.init(humidityRatio)),
        totalPressure: totalPressure,
        units: self.units
      ))
    }
    
    if let relativeHumidity = self.relativeHumidity {
      return try await client.dewPoint(.dryBulb(
        dryBulb,
        relativeHumidity: relativeHumidity%,
        units: self.units
      ))
    }
    
    if let vaporPressure = self.vaporPressure {
      return try await client.dewPoint(.dryBulb(
        dryBulb,
        vaporPressure: .init(.init(vaporPressure, units: .defaultFor(units: self.units))),
        units: self.units
      ))
    }
    
    if let wetBulb = self.wetBulb {
      let totalPressure = try self.totalPressureValue()
      return try await client.dewPoint(.wetBulb(
        .init(.init(wetBulb, units: .defaultFor(units: self.units))),
        dryBulb: dryBulb,
        totalPressure: totalPressure,
        units: self.units
      ))
    }
    
    throw ValidationError(
    """
    Must supply either humidity ratio with total pressure or altitude,
    relative humidity,
    vapor pressure,
    or wet bulb with total pressure or altitude.
    """.red.bold
    )
  }
}

extension CLIClient.EnthalpyRequest {
  func totalPressureValue() throws -> TotalPressure {
    if let totalPressure = self.totalPressure {
      return TotalPressure(.init(totalPressure, units: .defaultFor(units: self.units)))
    } else if let altitude = self.altitude {
      return TotalPressure(
        altitude: .init(altitude, units: .defaultFor(units: self.units)),
        units: self.units
      )
    }
    throw ValidationError("""
      Either a total pressure or altitude is required with a humidity ratio.
    """.red.bold)
  }
  
  func output(client: PsychrometricClient) async throws -> EnthalpyOf<MoistAir> {
    let dryBulb = DryBulb(.init(self.dryBulb, units: .defaultFor(units: self.units)))
    
    if let humidityRatio = self.humidityRatio {
      return try await client.enthalpy.moistAir(
        .dryBulb(
          dryBulb,
          humidityRatio: .init(.init(humidityRatio)),
          units: self.units
        )
      )
    }
    
    if let relativeHumidity = self.relativeHumidity {
      let totalPressure = try self.totalPressureValue()
      return try await client.enthalpy.moistAir(
        .dryBulb(
          dryBulb,
          relativeHumidity: relativeHumidity%,
          totalPressure: totalPressure,
          units: self.units
        )
      )
    }
    
    if self.totalPressure != nil {
      let totalPressure = try self.totalPressureValue()
      return try await client.enthalpy.moistAir(
        .dryBulb(
          dryBulb,
          totalPressure: totalPressure,
          units: self.units
        )
      )
    }
    
    throw ValidationError(
      """
      Must supply either humidity ratio, relative humidity, or total pressure.
      """.red.bold
    )
  }
}

extension CLIClient.GrainsRequest {
  
  func output(client: PsychrometricClient) async throws -> GrainsOfMoisture {
    try await client.grainsOfMoisture(
      .dryBulb(
        .init(.init(self.dryBulb, units: .defaultFor(units: self.units))),
        relativeHumidity: self.relativeHumidity%,
        altitude: .init(self.altitude, units: .defaultFor(units: self.units))
      )
    )
  }
}

extension CLIClient.PropertiesRequest {
  
  func output(client: PsychrometricClient) async throws -> PsychrometricProperties {
    let altitude = Length(self.altitude, units: .defaultFor(units: self.units))
    let dryBulb = DryBulb(.init(self.dryBulb, units: .defaultFor(units: self.units)))
    
    if let dewPoint = self.dewPoint {
      return try await client.psychrometricProperties(
        .dewPoint(
          .init(.init(dewPoint, units: .defaultFor(units: self.units))),
          dryBulb: dryBulb,
          altitude: altitude,
          units: units
        ))
    }
    
    if let relativeHumidity = self.relativeHumidity {
      return try await client.psychrometricProperties(
        .dryBulb(
          dryBulb,
          relativeHumidity: relativeHumidity%,
          altitude: altitude,
          units: units
        ))
    }
    
    if let wetBulb = self.wetBulb {
      return try await client.psychrometricProperties(
        .wetBulb(
          .init(.init(wetBulb, units: .defaultFor(units: self.units))),
          dryBulb: dryBulb,
          altitude: altitude,
          units: units
        )
      )
    }
    
    throw ValidationError("""
    A dew-point, relative-humidity, or wet-bulb is required.
    """.red.bold)
  }
}

extension CLIClient.WetBulbRequest {
  
  func totalPressureValue() throws -> TotalPressure {
    if let totalPressure = self.totalPressure {
      return TotalPressure(.init(totalPressure, units: .defaultFor(units: self.units)))
    } else if let altitude = self.altitude {
      return TotalPressure(
        altitude: .init(altitude, units: .defaultFor(units: self.units)),
        units: self.units
      )
    }
    throw ValidationError("""
      Either a total pressure or altitude is required with a humidity ratio.
    """.red.bold)
  }
  
  func output(client: PsychrometricClient) async throws -> WetBulb {
    let dryBulb = DryBulb(.init(self.dryBulb, units: .defaultFor(units: self.units)))
    let totalPressure = try self.totalPressureValue()
    
    if let humidityRatio = self.humidityRatio {
      return try await client.wetBulb(
        .dryBulb(
          dryBulb,
          humidityRatio: .init(.init(humidityRatio)),
          totalPressure: totalPressure,
          units: self.units
        )
      )
    }
    
    if let relativeHumidity = self.relativeHumidity {
      return try await client.wetBulb(
        .dryBulb(
          dryBulb,
          relativeHumidity: relativeHumidity%,
          totalPressure: totalPressure,
          units: self.units
        )
      )
    }
    
    throw ValidationError(
      """
      Either a humidity ratio or relative humidity is required.
      """.red.bold
    )
  }
}

fileprivate func formatter(decimalPlaces: Int?) -> NumberFormatter {
  let formatter = NumberFormatter()
  formatter.numberStyle = .decimal
  formatter.maximumFractionDigits = decimalPlaces ?? 3
  return formatter
}
