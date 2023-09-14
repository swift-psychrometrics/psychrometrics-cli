import Dependencies
import Foundation
import PsychrometricClient

extension DependencyValues {
  public var cliClient: CLIClient {
    get { self[CLIClient.self] }
    set { self[CLIClient.self] = newValue }
  }
}

public struct CLIClient {
  public var numberFormatter: (Int?) -> NumberFormatter

  public init(numberFormatter: @escaping (Int?) -> NumberFormatter) {
    self.numberFormatter = numberFormatter
  }

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

extension CLIClient: DependencyKey {

  public static var liveValue: CLIClient = Self.init(
    numberFormatter: formatter
  )

  public static var testValue: CLIClient { .liveValue }
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

fileprivate func formatter(decimalPlaces: Int?) -> NumberFormatter {
  let formatter = NumberFormatter()
  formatter.numberStyle = .decimal
  formatter.maximumFractionDigits = decimalPlaces ?? 3
  return formatter
}
