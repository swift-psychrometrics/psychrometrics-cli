import Dependencies
import Foundation
import SharedModels
import XCTestDynamicOverlay

extension DependencyValues {
  /// Access the cli client middleware as a dependency.
  ///
  /// `@Dependency(\.cliClient) var client`
  ///
  public var cliClient: CLIClient {
    get { self[CLIClient.self] }
    set { self[CLIClient.self] = newValue }
  }
}

/// Acts as a middleware for the command line interface program.
///
/// Converts basic types / requests that are passed in as command line arguments, into request types that
/// are appropriate for calculating psychrometrics properties.
///
/// Also offers transformations for numeric values and their symbols to strings that can be
/// printed to the console.
///
/// You generally do not create this type directly, instead access it through the dependency mechinism.
///
/// `@Dependency(\.cliClient) var client`
///
public struct CLIClient: Sendable {
  
  public var dhClient: DHClient
  public var dewPoint: @Sendable (DewPointRequest) async throws -> DewPoint
  public var enthalpy: @Sendable (EnthalpyRequest) async throws -> EnthalpyOf<MoistAir>
  public var grains: @Sendable (GrainsRequest) async throws -> GrainsOfMoisture
  public var numberFormatter: @Sendable (Int?) -> NumberFormatter
  public var properties: @Sendable (PropertiesRequest) async throws -> PsychrometricProperties
  public var wetBulb: @Sendable (WetBulbRequest) async throws -> WetBulb
  
  public init(
    dhClient: DHClient,
    dewPoint: @escaping @Sendable (DewPointRequest) async throws -> DewPoint,
    enthalpy: @escaping @Sendable (EnthalpyRequest) async throws -> EnthalpyOf<MoistAir>,
    grains: @escaping @Sendable (GrainsRequest) async throws -> GrainsOfMoisture,
    numberFormatter: @escaping @Sendable (Int?) -> NumberFormatter,
    properties: @escaping @Sendable (PropertiesRequest) async throws -> PsychrometricProperties,
    wetBulb: @escaping @Sendable (WetBulbRequest) async throws -> WetBulb
  ) {
    self.dhClient = dhClient
    self.dewPoint = dewPoint
    self.enthalpy = enthalpy
    self.grains = grains
    self.numberFormatter = numberFormatter
    self.properties = properties
    self.wetBulb = wetBulb
  }
  
  public struct DHClient: Sendable {
    
    public var poundsRemoved: @Sendable (Pounds.Request) async throws -> Pounds.Output
    public var sizing: @Sendable (Size.Request) async throws -> Size.Output
    
    public init(
      poundsRemoved: @escaping @Sendable (Pounds.Request) async throws -> Pounds.Output,
      sizing: @escaping @Sendable (Size.Request) async throws -> Size.Output)
    {
      self.poundsRemoved = poundsRemoved
      self.sizing = sizing
    }
    
    public enum Pounds {
      
      public struct Request: Equatable, Sendable {
        public let cfm: Double
        public let grains: [Double]
        
        public init(
          cfm: Double,
          grains: [Double]
        ) {
          self.cfm = cfm
          self.grains = grains
        }
      }
      
      public enum GrainsEnvelope: Equatable, Sendable {
        case single(Double)
        case pair(Double, Double)
      }
      
      public struct PoundsRemovedEnvelope: Equatable, Sendable {
        
        public let input: GrainsEnvelope
        public let deltaGrains: Double
        public let poundsPerHour: Double
        
        public init(
          _ input: GrainsEnvelope,
          deltaGrains: Double,
          poundsPerHour: Double
        ) {
          self.input = input
          self.deltaGrains = deltaGrains
          self.poundsPerHour = poundsPerHour
        }
      }
      
      public typealias Output = [PoundsRemovedEnvelope]
      
    }
    
    public enum Size {
      public struct Request: Equatable, Sendable {
        public let latentLoad: Double
        public let percentages: [Double]?
        
        public init(
          latentLoad: Double,
          percentages: [Double]?
        ) {
          self.latentLoad = latentLoad
          self.percentages = percentages
        }
      }
      
      public typealias Output = [PintsEnvelope]
      
      public struct PintsEnvelope: Equatable, Sendable {
        public let input: Double
        public let percentage: Double
        public let pintsPerHour: Double
        public var pintsPerDay: Double { pintsPerHour * 24 }
        
        public init(
          input: Double,
          percentage: Double,
          pintsPerHour: Double
        ) {
          self.input = input
          self.percentage = percentage
          self.pintsPerHour = pintsPerHour
        }
      }
    }
  }
  
  public struct DewPointRequest: Equatable, Sendable {
    public let altitude: Double?
    public let dryBulb: Double
    public let humidityRatio: Double?
    public let relativeHumidity: Double?
    public let totalPressure: Double?
    public let vaporPressure: Double?
    public let wetBulb: Double?
    public let units: PsychrometricUnits
    
    public init(
      altitude: Double?,
      dryBulb: Double,
      humidityRatio: Double?,
      relativeHumidity: Double?,
      totalPressure: Double?,
      vaporPressure: Double?,
      wetBulb: Double?,
      units: PsychrometricUnits
    ) {
      self.altitude = altitude
      self.dryBulb = dryBulb
      self.humidityRatio = humidityRatio
      self.relativeHumidity = relativeHumidity
      self.totalPressure = totalPressure
      self.vaporPressure = vaporPressure
      self.wetBulb = wetBulb
      self.units = units
    }
  }
  
  public struct EnthalpyRequest: Equatable, Sendable {
    public let altitude: Double?
    public let dryBulb: Double
    public let humidityRatio: Double?
    public let relativeHumidity: Double?
    public let totalPressure: Double?
    public let units: PsychrometricUnits
    
    public init(
      altitude: Double?,
      dryBulb: Double,
      humidityRatio: Double?,
      relativeHumidity: Double?,
      totalPressure: Double?,
      units: PsychrometricUnits
    ) {
      self.altitude = altitude
      self.dryBulb = dryBulb
      self.humidityRatio = humidityRatio
      self.relativeHumidity = relativeHumidity
      self.totalPressure = totalPressure
      self.units = units
    }
  }
  
  public struct GrainsRequest: Equatable, Sendable {
    public let altitude: Double
    public let dryBulb: Double
    public let relativeHumidity: Double
    public let units: PsychrometricUnits
    
    public init(
      altitude: Double,
      dryBulb: Double,
      relativeHumidity: Double,
      units: PsychrometricUnits
    ) {
      self.altitude = altitude
      self.dryBulb = dryBulb
      self.relativeHumidity = relativeHumidity
      self.units = units
    }
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
  
  public struct WetBulbRequest: Equatable, Sendable {
    public let altitude: Double?
    public let dryBulb: Double
    public let humidityRatio: Double?
    public let relativeHumidity: Double?
    public let totalPressure: Double?
    public let units: PsychrometricUnits
    
    public init(
      altitude: Double?,
      dryBulb: Double,
      humidityRatio: Double?,
      relativeHumidity: Double?,
      totalPressure: Double?,
      units: PsychrometricUnits
    ) {
      self.altitude = altitude
      self.dryBulb = dryBulb
      self.humidityRatio = humidityRatio
      self.relativeHumidity = relativeHumidity
      self.totalPressure = totalPressure
      self.units = units
    }
  }
  
}

extension CLIClient {

  /// Generate a string value for the given number that can be printed to the console.
  ///
  /// - Parameters:
  ///   - value: The number to convert to a string.
  ///   - decimalPlaces: The number of fraction digits to allow.
  ///   - symbol: An optional symbol to include in the output string.
  ///   - symbolPrefix: The prefix / value to include before the symbol, defaults to a single space.
  ///   - withSymbol: Control whether symbol string should be included in output.
  public func string(
    _ value: Double,
    decimalPlaces: Int? = nil,
    symbol: String? = nil,
    symbolPrefix: String = " ",
    withSymbol: Bool = true
  ) -> String {
    let formatter = numberFormatter(decimalPlaces)
    let string = formatter.string(for: value) ?? "\(value)"
    
    guard withSymbol,
            let symbol = symbol
    else { return string }
    
    return "\(string)\(symbolPrefix)\(symbol)"
  }
  
  /// Generate a string value for the given number that can be printed to the console, optionally including a symbol.
  ///
  /// - Parameters:
  ///   - value: The number to convert to a string.
  ///   - decimalPlaces: The number of fraction digits to allow.
  ///   - symbolPrefix: The prefix / value to include before the symbol, defaults to a single space.
  ///   - withSymbol: Control whether symbol string should be included in output.
  public func string<T: NumberWithUnitOfMeasure>(
    _ value: T,
    decimalPlaces: Int? = nil,
    symbolPrefix: String = " ",
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
      return "\(numberString)\(symbolPrefix)\(unitString)"
    } else {
      return numberString
    }
  }
  
  /// Generate a string value for the given number that can be printed to the console, optionally including a symbol.
  ///
  /// - Parameters:
  ///   - value: The number to convert to a string.
  ///   - decimalPlaces: The number of fraction digits to allow.
  ///   - symbolPrefix: The prefix / value to include before the symbol, defaults to a single space.
  ///   - withSymbol: Control whether symbol string should be included in output.
  public func string<T: RawSymbolic>(
    _ value: T,
    decimalPlaces: Int? = nil,
    symbolPrefix: String = " ",
    withSymbol: Bool = true
  ) -> String {
    let formatter = numberFormatter(decimalPlaces)
    let numberString = formatter.string(for: value.value) ?? "\(value)"
    if withSymbol {
      return "\(numberString)\(symbolPrefix)\(value.symbol)"
    } else {
      return numberString
    }
  }
}

extension CLIClient: TestDependencyKey {

  public static var testValue: CLIClient = Self.init(
    dhClient: DHClient(
      poundsRemoved: unimplemented("\(Self.self).poundsRemoved", placeholder: []),
      sizing: unimplemented("\(Self.self).sizing", placeholder: [])
    ),
    dewPoint: unimplemented("\(Self.self).dewPoint", placeholder: .zero),
    enthalpy: unimplemented("\(Self.self).enthalpy", placeholder: .zero),
    grains: unimplemented("\(Self.self).grains", placeholder: .zero),
    numberFormatter: unimplemented("\(Self.self).numberFormatter", placeholder: NumberFormatter.init()),
    properties: unimplemented("\(Self.self).properties", placeholder: .zero),
    wetBulb: unimplemented("\(Self.self).wetBulb", placeholder: .zero)
  )
}

