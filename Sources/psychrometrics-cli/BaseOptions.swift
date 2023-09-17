import ArgumentParser
import Foundation
import SharedModels

struct BaseOptions: ParsableArguments {
  
  @Flag(
    name: .long,
    inversion: .prefixedEnableDisable,
    help: "Include symbols in the output."
  )
  var symbols: Bool = true
  
  var includeSymbols: Bool { self.symbols }
  
  @Flag(name: .long, help: "Increase output logging.")
  var verbose: Bool = false
}

@dynamicMemberLookup
struct BaseOptionsWithUnits: ParsableArguments {
  
  @Flag(help: "The units of measure.")
  var units: PsychrometricUnits = .imperial
  
  @OptionGroup var base: BaseOptions
  
  subscript<T>(dynamicMember keyPath: KeyPath<BaseOptions, T>) -> T {
    base[keyPath: keyPath]
  }
  
}

extension PsychrometricUnits: EnumerableFlag { }
