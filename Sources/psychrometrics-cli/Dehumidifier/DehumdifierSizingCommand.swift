import ArgumentParser
import CLIClient
import Dependencies
import Foundation
import Rainbow

extension DehumidifierCommand {
  struct SizingCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
      commandName: "size",
      abstract: "Calculate dehumdifier sizing based on the latent load of a project.",
      discussion: """
      This command can calculate the dehumidifier sizing in pints per day & pints
      per hour, as well as for different coverages of the latent load based on the
      passed in percentages.
      
      The default command calculates the pints per day & hour for 100% and 85% coverage
      of the given latent load.  The coverage values can be overriden by using the
      `--coverage` option.  If the coverage option is the last option before passing
      in the latent load, then a `--` can be used to separate the coverage values from
      the latent load.
      
      \("Example:".bold)
      
      The below will calculate the pints for the coverages 80% and 70%, at the
      given latent load of 4,334 BTU/hour.
      
      `$ psychrometrics dh size --verbose --coverage 80 70 -- 4334`
      
      If the options are rearranged then the `--` are not required.
      
      `$ psychrometrics dh size --coverage 80 70 --verbose 4334`
      
      """
    )
    
    @Option(
      name: .shortAndLong,
      parsing: .upToNextOption,
      help: "The coverage percentages to calculate."
    )
    var coverage: [Double] = [100, 85]
    
    @Argument
    var latentLoad: Double
    
    @OptionGroup var globals: BaseOptions
    
    func run() async throws {
      @Dependency(\.cliClient) var cliClient
      
      let outputs = try await cliClient.dhClient.sizing(
        .init(
          latentLoad: self.latentLoad,
          percentages: self.coverage
        )
      )
      
      var printSeparator = false
      
      print()
      for output in outputs {
        if printSeparator {
          print("-------------------------")
        }
        
        if globals.verbose {
          print("\(output.percentage * 100)% Coverage:".magenta.bold)
          print(cliClient.string(output.pintsPerHour, symbol: "pints/hour", withSymbol: self.globals.includeSymbols))
        }
        print(cliClient.string(output.pintsPerDay, symbol: "pints/day", withSymbol: self.globals.includeSymbols))
        printSeparator = true
      }
      
    }
  }
}
