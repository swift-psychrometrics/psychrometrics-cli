import ArgumentParser
import Foundation
import SharedModels

struct BaseOptions: ParsableArguments {
  
  @Flag(help: "The units of measure.")
  var units: PsychrometricUnits = .imperial
  
  @Flag(name: .long, help: "Increase output logging.")
  var verbose: Bool = false
  
}

extension PsychrometricUnits: EnumerableFlag { }
