import XCTest
import Dependencies
import CLIClientLive
import PsychrometricClientLive
@testable import psychrometrics_cli

final class psychrometrics_cliTests: XCTestCase {
  override func invokeTest() {
    withDependencies {
      $0.psychrometricClient = .liveValue
      $0.psychrometricEnvironment = .liveValue
      $0.cliClient = .live(client: .liveValue)
    } operation: {
      super.invokeTest()
    }

  }
  
  func testProperties() async throws {
    @Dependency(\.cliClient) var client
    
    do {
      // Dew Point
      _ = try await client.properties(.init(
        altitude: 0,
        dryBulb: 75,
        dewPoint: 73,
        relativeHumidity: nil,
        wetBulb: nil,
        units: .imperial
      ))
      
      // Relative Humidity
      _ = try await client.properties(.init(
        altitude: 0,
        dryBulb: 75,
        dewPoint: nil,
        relativeHumidity: 50,
        wetBulb: nil,
        units: .imperial
      ))
      
      // Wet bulb
      _ = try await client.properties(.init(
        altitude: 0,
        dryBulb: 75,
        dewPoint: nil,
        relativeHumidity: 50,
        wetBulb: nil,
        units: .imperial
      ))
      
    } catch {
      XCTFail()
    }
  }
  
  func testPropertiesFails() async throws {
    @Dependency(\.cliClient) var client
    do {
      _ = try await client.properties(
        .init(
          altitude: 0,
          dryBulb: 75,
          dewPoint: nil,
          relativeHumidity: nil,
          wetBulb: nil,
          units: .imperial
        )
      )
      XCTFail()
    } catch {
      XCTAssert(true)
    }
  }
}
