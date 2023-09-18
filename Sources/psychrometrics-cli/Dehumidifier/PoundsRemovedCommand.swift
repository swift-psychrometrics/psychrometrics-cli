import ArgumentParser
import CLIClient
import Dependencies
import Foundation
import Rainbow

extension DehumidifierCommand {
  struct PoundsRemovedCommand: AsyncParsableCommand {
    
    static let configuration = CommandConfiguration(
      commandName: "pounds-removed",
      abstract: "Calculate the pounds of water removed.",
      discussion: """
      This command can accept multiple `grains` arguments to perform
      the calculation on.
      
      The arguments will be broken into pairs to calculate the delta-grains.
      If a single value is passed in or the number of arguments is odd, then it
      will treat that as a delta of grains.
      
      \("Example:".bold)
      
      The below will calculate the pounds removed at 800 cfm,
      using 66 and 52 to calculate the delta-grains (14 delta-grains).
      
      `$ psychrometrics dh pounds-removed --cfm 800 66 52`
      
      To force the values to be used as single value delta-grains, then use the
      `--delta` option, which can be supplied multiple times or with multiple
      values that are all treated as delta's.
      
      \("Example using delta option:".bold)
      
      The below will show the pounds removed at 800 cfm, using the values
      of 14, 12, 10 as delta-grains values.
      
      `$ psychrometrics dh pounds-removed --cfm 800 --delta 14 12 10`
      
      \("OR".bold)
      
      `$ psychrometrics dh pounds-removed --cfm 800 --delta 14 --delta 12 --delta 10`
      
      If you want to use both forced `delta` values and arguments to
      calculate delta grains then you can pass `--` prior to the argument
      values, when the `--delta` option is the last option.
      
      \("Example combining delta and arguments:".bold)
      
      Below will calculate using the delta of 12 and calculate the delta between
      66 and 52 (14 delta-grains).
      
      `$ psychrometrics dh pounds-removed --cfm 800 --verbose --delta 12 -- 66 52`
      
      The `--` are not needed if we switch the place of some of the other arguments,
      or if any options are supplied after the `--delta`, it only applies when the
      last option is the `--delta` option.
      
      `$ psychrometrics dh pounds-removed --cfm 800 --delta 12 --verbose 66 52`
      
      """
    )
    
    @Option(
      name: .shortAndLong,
      help: "The cubic feet per minute of airflow."
    )
    var cfm: Double
    
    @Option(
      name: .shortAndLong,
      parsing: .upToNextOption,
      help: "Value(s) treated as delta-grains."
    )
    var delta: [Double]
    
    @Argument(
      help: "The grains used in the calculation."
    )
    var grains: [Double] = []
    
    @OptionGroup var globals: BaseOptions
    
    func run() async throws {
      @Dependency(\.cliClient) var cliClient
      
      guard grains.count > 0 || delta.count > 0 else {
        throw ValidationError("No grains supplied.".red.bold)
      }
      
      var output: CLIClient.DHClient.Pounds.Output = []
      
      if grains.count > 0 {
        output += try await cliClient.dhClient.poundsRemoved(
          .init(cfm: self.cfm, grains: self.grains)
        )
      }
     
      // Loop through delta's individually.
      for deltaGrains in self.delta {
        output += try await cliClient.dhClient.poundsRemoved(
          .init(cfm: self.cfm, grains: [deltaGrains])
        )
      }
      
      if globals.verbose {
        print()
        print("CFM:     \(self.cfm)".lightGreen.bold)
        print()
      }
      
      var printSeparator: Bool = false
      
      for poundsOutput in output {
        if printSeparator {
          print("-------------------------------")
        }
        
        if globals.verbose {
          print("Delta-grains:    \(poundsOutput.deltaGrains)")
        }
        
        print("\(cliClient.string(poundsOutput.poundsPerHour, symbol: "lb/hour", withSymbol: self.globals.includeSymbols))")
        
        printSeparator = true
      }
    }
  }
}
