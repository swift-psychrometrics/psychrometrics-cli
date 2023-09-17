import Dependencies
import Foundation
import SharedModels
import XCTestDynamicOverlay

extension DependencyValues {
  public var cliClient: CLIClient {
    get { self[CLIClient.self] }
    set { self[CLIClient.self] = newValue }
  }
}

public struct CLIClient {
  
  public var numberFormatter: @Sendable (Int?) -> NumberFormatter
  public var properties: @Sendable (PropertiesRequest) async throws -> PsychrometricProperties
  
  public init(
    numberFormatter: @escaping @Sendable (Int?) -> NumberFormatter,
    properties: @escaping @Sendable (PropertiesRequest) async throws -> PsychrometricProperties
  ) {
    self.numberFormatter = numberFormatter
    self.properties = properties
  }
  
  public struct PropertiesRequest: Equatable, Sendable {
    public let altitude: Double
    public let dryBulb: Double
    public let dewPoint: Double?
    public let relativeHumidity: Double?
    public let wetBulb: Double?
    public let units: PsychrometricUnits
    
    public init(
      altitude: Double,
      dryBulb: Double,
      dewPoint: Double?,
      relativeHumidity: Double?,
      wetBulb: Double?,
      units: PsychrometricUnits
    ) {
      self.altitude = altitude
      self.dryBulb = dryBulb
      self.dewPoint = dewPoint
      self.relativeHumidity = relativeHumidity
      self.wetBulb = wetBulb
      self.units = units
    }
  }
  
}

extension CLIClient {

  public func string(_ value: Double, decimalPlaces: Int? = nil) -> String {
    let formatter = numberFormatter(decimalPlaces)
    return formatter.string(for: value) ?? "\(value)"
  }

  public func string<T: NumberWithUnitOfMeasure>(
    _ value: T,
    decimalPlaces: Int? = nil,
    withSymbol: Bool = true
  ) -> String {
    let formatter = numberFormatter(decimalPlaces)
    let numberString = formatter.string(for: value.rawValue) ?? "\(value)"
    if withSymbol {
      let unitString: String
      if let units = value.units as? Symbolic {
        unitString = units.symbol
      } else {
        unitString = "\(value.units)"
      }
      return "\(numberString) \(unitString)"
    } else {
      return numberString
    }
  }
}

protocol Symbolic {
  var symbol: String { get }
}

extension RawRepresentable where RawValue == String, Self: Symbolic {
  var symbol: String { self.rawValue }
}

extension DensityUnits: Symbolic { }
extension EnthalpyUnits: Symbolic { }
extension Length.Unit: Symbolic { }
extension TemperatureUnit: Symbolic { }

extension CLIClient: TestDependencyKey {

//  public static var liveValue: CLIClient = Self.init(
//    numberFormatter: formatter
//  )

  public static var testValue: CLIClient = Self.init(
    numberFormatter: unimplemented("\(Self.self).numberFormatter", placeholder: NumberFormatter.init()), 
    properties: unimplemented("\(Self.self).properties", placeholder: .zero))
}

