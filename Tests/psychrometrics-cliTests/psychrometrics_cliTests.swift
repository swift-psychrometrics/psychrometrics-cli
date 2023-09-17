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
  
  func testDHClientPounds() async throws {
    @Dependency(\.cliClient) var client
    
    let outputs = try await client.dhClient.poundsRemoved(
      .init(cfm: 797, grains: [66, 52, 14])
    )
    XCTAssert(outputs.count == 2)
    XCTAssertEqual(outputs.first, outputs[1])
  }
  
  func testDewPoint() async throws {
    @Dependency(\.cliClient) var client
    
    do {
      // Humidity Ratio + altitude
      _ = try await client.dewPoint(
        .init(
          altitude: 0,
          dryBulb: 75,
          humidityRatio: 0.123,
          relativeHumidity: nil,
          totalPressure: nil,
          vaporPressure: nil,
          wetBulb: nil,
          units: .imperial
        )
      )
      
      // Humidity Ratio + total pressure
      _ = try await client.dewPoint(
        .init(
          altitude: nil,
          dryBulb: 75,
          humidityRatio: 0.123,
          relativeHumidity: nil,
          totalPressure: 14.696,
          vaporPressure: nil,
          wetBulb: nil,
          units: .imperial
        )
      )
      
      // Relative Humidity
      _ = try await client.dewPoint(
        .init(
          altitude: nil,
          dryBulb: 75,
          humidityRatio: nil,
          relativeHumidity: 50,
          totalPressure: nil,
          vaporPressure: nil,
          wetBulb: nil,
          units: .imperial
        )
      )
      
      // Vapor Pressure
      _ = try await client.dewPoint(
        .init(
          altitude: nil,
          dryBulb: 75,
          humidityRatio: nil,
          relativeHumidity: nil,
          totalPressure: nil,
          vaporPressure: 12.12,
          wetBulb: nil,
          units: .imperial
        )
      )
      
      // Wet Bulb + altitude
      _ = try await client.dewPoint(
        .init(
          altitude: 0,
          dryBulb: 75,
          humidityRatio: nil,
          relativeHumidity: nil,
          totalPressure: nil,
          vaporPressure: nil,
          wetBulb: 73,
          units: .imperial
        )
      )
      
      // Wet Bulb + total pressure
      _ = try await client.dewPoint(
        .init(
          altitude: nil,
          dryBulb: 75,
          humidityRatio: nil,
          relativeHumidity: nil,
          totalPressure: 14.696,
          vaporPressure: nil,
          wetBulb: 73,
          units: .imperial
        )
      )
    } catch {
      XCTFail("\(error)")
    }
  }
  
  func testDewPointFails() async throws {
    @Dependency(\.cliClient) var client
    
    do {
      // Humidity Ratio + altitude
      _ = try await client.dewPoint(
        .init(
          altitude: nil,
          dryBulb: 75,
          humidityRatio: nil,
          relativeHumidity: nil,
          totalPressure: nil,
          vaporPressure: nil,
          wetBulb: nil,
          units: .imperial
        )
      )
      XCTFail()
    } catch {
      XCTAssert(true)
    }
    
  }
  
  func testEnthalpy() async throws {
    @Dependency(\.cliClient) var client
    
    do {
      // Humidity Ratio
      _ = try await client.enthalpy(
        .init(
          altitude: nil,
          dryBulb: 75,
          humidityRatio: 0.123,
          relativeHumidity: nil,
          totalPressure: nil,
          units: .imperial
        )
      )
      
      // Relative + altitude
      _ = try await client.enthalpy(
        .init(
          altitude: 0,
          dryBulb: 75,
          humidityRatio: nil,
          relativeHumidity: 50,
          totalPressure: nil,
          units: .imperial
        )
      )
      
      // Relative Humidity + total pressure
      _ = try await client.enthalpy(
        .init(
          altitude: nil,
          dryBulb: 75,
          humidityRatio: nil,
          relativeHumidity: 50,
          totalPressure: 14.696,
          units: .imperial
        )
      )
      
    } catch {
      XCTFail("\(error)")
    }
  }
  
  func testEnthalpyFails() async throws {
    @Dependency(\.cliClient) var client
    
    do {
      _ = try await client.enthalpy(
        .init(
          altitude: nil,
          dryBulb: 75,
          humidityRatio: nil,
          relativeHumidity: nil,
          totalPressure: nil,
          units: .imperial
        )
      )
      XCTFail()
    } catch {
      XCTAssert(true)
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
  
  func testWetBulb() async throws {
    @Dependency(\.cliClient) var client
    
    do {
      // Humidity Ratio + altitude
      _ = try await client.wetBulb(
        .init(
          altitude: 0,
          dryBulb: 75,
          humidityRatio: 0.123,
          relativeHumidity: nil,
          totalPressure: nil,
          units: .imperial
        )
      )
      
      // Humidity Ratio + total pressure
      _ = try await client.wetBulb(
        .init(
          altitude: nil,
          dryBulb: 75,
          humidityRatio: 0.123,
          relativeHumidity: nil,
          totalPressure: 14.696,
          units: .imperial
        )
      )
      
      // Relative + altitude
      _ = try await client.wetBulb(
        .init(
          altitude: 0,
          dryBulb: 75,
          humidityRatio: nil,
          relativeHumidity: 50,
          totalPressure: nil,
          units: .imperial
        )
      )
      
      // Relative Humidity + total pressure
      _ = try await client.wetBulb(
        .init(
          altitude: nil,
          dryBulb: 75,
          humidityRatio: nil,
          relativeHumidity: 50,
          totalPressure: 14.696,
          units: .imperial
        )
      )
      
    } catch {
      XCTFail("\(error)")
    }
  }
  
  func testWetBulbFails() async throws {
    @Dependency(\.cliClient) var client
    
    do {
      _ = try await client.wetBulb(
        .init(
          altitude: nil,
          dryBulb: 75,
          humidityRatio: nil,
          relativeHumidity: nil,
          totalPressure: nil,
          units: .imperial
        )
      )
      XCTFail()
    } catch {
      XCTAssert(true)
    }
    
  }
}
