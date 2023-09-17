@_exported import CLIClient
import Dependencies
import Foundation
import PsychrometricClient

extension CLIClient: DependencyKey {
  
  public static func live(client: PsychrometricClient) -> Self {
    .init(
      numberFormatter: { formatter(decimalPlaces: $0) } ,
      properties: { try await $0.output(client: client) }
    )
  }
  
  public static var liveValue: CLIClient {
    @Dependency(\.psychrometricClient) var client
    return .live(client: client)
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
    
    throw InvalidInputs()
  }
}

struct InvalidInputs: Error { }

fileprivate func formatter(decimalPlaces: Int?) -> NumberFormatter {
  let formatter = NumberFormatter()
  formatter.numberStyle = .decimal
  formatter.maximumFractionDigits = decimalPlaces ?? 3
  return formatter
}
