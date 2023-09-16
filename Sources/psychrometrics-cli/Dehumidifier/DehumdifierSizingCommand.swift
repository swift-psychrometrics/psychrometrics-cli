import ArgumentParser
import CLIDependency
import Dependencies
import Foundation

extension DehumidifierCommand {
  struct SizingCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
      commandName: "size",
      abstract: "Calculate dehumdifier sizing based on the latent load of a project."
    )
    
    @Argument
    var latentLoad: Double
    
    func run() async throws {
      @Dependency(\.cliClient) var cliClient
      
      let eightyFivePercentLatent = latentLoad * 0.85
      let eightyFivePintsPerHour = eightyFivePercentLatent / 1054
      let eightyFivePintsPerDay = eightyFivePintsPerHour * 24
      
      let pintsPerHour = latentLoad / 1054
      let pintsPerDay = pintsPerHour * 24
      
      print("Full Coverage:")
      print("-----------------------")
      print("\(cliClient.string(pintsPerHour, decimalPlaces: 1)) pints/hour")
      print("\(cliClient.string(pintsPerDay, decimalPlaces: 1)) pints/day")
      print("-----------------------")
      print()
      print("85% Coverage:")
      print("-----------------------")
      print("\(cliClient.string(eightyFivePintsPerHour, decimalPlaces: 1)) pints/hour")
      print("\(cliClient.string(eightyFivePintsPerDay, decimalPlaces: 1)) pints/day")
      
    }
  }
}
