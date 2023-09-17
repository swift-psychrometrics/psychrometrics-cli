import Foundation
import SharedModels

public protocol Symbolic {
  var symbol: String { get }
}

public protocol RawSymbolic: Symbolic {
  var value: Double { get }
}

extension RawRepresentable where RawValue == String, Self: Symbolic {
  public var symbol: String { self.rawValue }
}

extension DensityUnits: Symbolic { }
extension EnthalpyUnits: Symbolic { }
extension GrainsOfMoisture: RawSymbolic, Symbolic, Mapable {
  public var symbol: String { "gr/lb" }
  public var value: Double { rawValue }
}
extension Length.Unit: Symbolic { }
extension TemperatureUnit: Symbolic { }
extension RelativeHumidity: RawSymbolic, Symbolic {
  public var value: Double {
    self.rawValue.value
  }
  
  public var symbol: String { "%" }
}

public protocol Mapable {
  func map<T>(_ transform: @escaping (Self) -> T) -> T
}

extension Mapable {
  public func map<T>(_ transform: @escaping (Self) -> T) -> T {
    transform(self)
  }
}
