import ArgumentParser
import Foundation
import SharedModels

// TODO: Fix the options to be more generic.

@dynamicMemberLookup
struct BasePsychrometricOptions: ParsableArguments {
  
  @Flag(
    name: .long,
    inversion: .prefixedEnableDisable,
    help: "Include symbols in the output."
  )
  var symbols: Bool = true
  
  @OptionGroup var base: BaseOptions
  
  var includeSymbols: Bool { self.symbols }
  
  subscript<T>(dynamicMember keyPath: KeyPath<BaseOptions, T>) -> T {
    self.base[keyPath: keyPath]
  }
}
