import ArgumentParser
import CLIDependency
import Dependencies
import Foundation

extension DehumidifierCommand {
  struct PoundsRemovedCommand: AsyncParsableCommand {
    
    static let configuration = CommandConfiguration(
      commandName: "pounds-removed",
      abstract: "Calculate the pounds of water removed."
    )
    
    @Option(
      name: .long,
      help: "The cubic feet per minute of airflow."
    )
    var cfm: Double
    
    @Flag(name: .shortAndLong, help: "Add more verbose printing")
    var verbose: Bool = false
    
    @Argument(
      help: """
      The grains to calculate, either one value as the delta-grains 
      or two values used to calculate the delta-grains
      """
    )
    var grains: [Double]
    
    func run() async throws {
      @Dependency(\.cliClient) var cliClient
      
      guard let firstValue = grains.first else {
        print("No arguments passed in.")
        return
      }
      
      var deltaGrains = firstValue
      
      if grains.count == 2 {
        let secondValue = grains[1]
        switch (firstValue > secondValue) {
        case true:
          deltaGrains = firstValue - secondValue
        case false:
          deltaGrains = secondValue - firstValue
        }
      }
      
      let poundsRemoved = (4.5 * cfm * deltaGrains) / 7000
      
      if verbose {
        print("Calculating based on cfm: \(cliClient.string(cfm, decimalPlaces: 0))")
        print("Delta-Grains:             \(cliClient.string(deltaGrains))")
      }
      print("\(cliClient.string(poundsRemoved))")
    }
  }
}
