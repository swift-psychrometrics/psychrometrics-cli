import ArgumentParser
import Dependencies
import FileClient
import Foundation
import ShellClient
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Builder {
  struct Bottle: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
      commandName: "bottle",
      abstract: "Bottles the `psychrometrics` application."
    )
    
    @Flag
    var dryRun: Bool = false
    
    func run() async throws {
      try await BottleRunner(dryRun: dryRun).run()
    }
  }
}

fileprivate struct BottleRunner {
  @Dependency(\.fileClient) var fileClient: FileClient
  @Dependency(\.logger) var logger: Logger
  @Dependency(\.shellClient) var shellClient: ShellClient
  
  let dryRun: Bool
  
  private var branch: String { "psychrometrics-\(version)" }
  private var brew: String { "brew" }
  private var formula: String { "psychrometrics" }
  private var fullFormula: String { "\(tap)/\(formula)" }
  private var rootUrl: String { "https://github.com/swift-psychrometrics/psychrometrics-cli/releases/download/\(version)" }
  private var tap: String { "swift-psychrometrics/homebrew-formula" }
  private var version: String {
    if !VERSION.contains("main") && !VERSION.contains("develop") {
      return VERSION
    } else {
      return "0.0.1"
    }
  }
  private var commitable: Bool {
    !dryRun && !(version.contains("main"))
  }
  
  func run() async throws {

    logger.info("Starting bottle process.")
    logger.info("""
      DryRun: \(dryRun)
      Version: \(version)
      Commitable: \(commitable)
    """)
    
    // Uninstall first, if we've already installed dots on this machine.
    uninstallFormula()
   
    logger.info("Tapping: \(tap)")
    
    // tap
    try shellClient.foreground(
      [brew, "tap", "\(tap)"]
    )
    
    // Update the formula for bottling.
    try await updateFormulaBeforeBottling()
    
    // install and prepair to bottle.
    logger.info("Installing: \(fullFormula)")
    try shellClient.foreground(
      [brew, "install", "--build-bottle", fullFormula]
    )
    
    // bottle
    let bottleOutput = try bottle()
    
    // Fix the bottle tarball name.
    logger.info("Fixing bottle tarball name.")
    var bottlePath: String = bottleOutput.fileName
    do {
      bottlePath = try updateBottleFilePath(fileName: bottleOutput.fileName)
    } catch {
      logger.info("Could not update bottle file path, falling back to default.")
      logger.error("\(error)")
    }
    
    logger.info("Bottle path: \(bottlePath)")
    
    // Upload bottle to github release.
//    try uploadBottleToRelease(fileName: bottlePath)
//    defer { try? FileManager.default.trashItem(at: URL(fileURLWithPath: bottlePath), resultingItemURL: nil) }
    
    // Update the formula with the new bottle block.
    logger.info("Updating formula.")
    
    // Some bottles are generated in the ci/cd workflow and so those portions of
    // of the bottle do block needs to remain.
    try await updateFormulaAfterBottling(
      bottleBlock: bottleOutput.filePrintableBlock
    )
    
    // Check the formula does not contain formula syntax errors.
    try checkFormula()
    
    // TODO: The following items don't seem to work in ci, but the do locally.
    
    // Commit the updated formula.
//    try commitFormulaRepository()
    
    // Create a branch with the new formula before creating a pull request.
//    try createBranch()
    
    // Create a pull request for the formula repository.
//    try createPullRequest()
    
    let printableFileContents = fileTemplateWithBottleBlock(block: bottleOutput.displayBlock, version: version)
    
    logger.info("\("Please update the homebrew tap file:".green)")
    logger.info("\("----------------------------------------".green)")
    logger.info("\(printableFileContents.green.bold)")
    logger.info("Need to upload the bottle as an asset: use \("`make upload-bottle`".blue).")
    
  }
  
  // MARK: - Helpers
  
  private func uninstallFormula() {
    _ = try? shellClient.background(
      [brew, "uninstall", fullFormula],
      trimmingCharactersIn: .whitespacesAndNewlines
    )
  }
  
  private func createBranch() throws {
    if commitable {
      logger.info("Creating new branch before bottling.")
      do {
        try shellClient.runInFormulaRepository(
          "git", "checkout", "-b", branch
        )
      } catch {
        do {
          // branch may already exist.
          try shellClient.runInFormulaRepository(
            "git", "checkout", branch
          )
        } catch {
          logger.info("Already on branch.")
          return
        }
      }
    }
  }
  
  private func updateFormulaBeforeBottling() async throws {
    let temporaryFormulaFileContents = fileTemplateWithoutBottleBlock(version: version)
    if dryRun {
      logger.info("Dry run called.")
      logger.info("\(temporaryFormulaFileContents)")
    } else {
      logger.info("Updating psychrometrics formula before bottling.")
      let dotsFormulaUrl = try shellClient.formulaUrl()
      try await fileClient.writeFile(
        string: temporaryFormulaFileContents,
        to: dotsFormulaUrl
      )
    }
  }
  
  private func bottle() throws -> ParsedOutput {
    let bottleContext = try shellClient.background(
      [brew, "bottle", "--root-url", rootUrl, fullFormula],
      trimmingCharactersIn: .whitespacesAndNewlines
    )
    // print the bottling output to act like a foreground shell.
    logger.info("\(bottleContext)")
    
    return parseBottleOutput(from: bottleContext)
  }
 
  private func updateBottleFilePath(fileName: String) throws -> String {
    do {
      let sanitizedName = fileName.replacingOccurrences(of: "--", with: "-")
      try FileManager.default.moveItem(atPath: fileName, toPath: sanitizedName)
      return sanitizedName
    } catch {
      logger.info("Failed to relocate: \(fileName)")
      logger.error("\(error)")
      return fileName
    }
  }
  
  private func uploadBottleToRelease(fileName: String) throws {
    if commitable {
      logger.info("Uploading bottle as a release asset.")
      do {
        try shellClient.foreground(
          ["gh", "release", "upload", version, fileName]
        )
      } catch {
        logger.info("Failed to upload bottle as release asset.")
        logger.error("\(error)")
        throw error
      }
    } else {
      logger.info("Dry run called, otherwise would upload: \(fileName)")
    }
  }
  
  @discardableResult
  private func updateFormulaAfterBottling(bottleBlock: String) async throws -> String {
    let updatedFileContents = fileTemplateWithBottleBlock(block: bottleBlock, version: version)
    if dryRun {
      logger.info("Dry run called, not writing new formula.")
      logger.info("\(updatedFileContents.green)")
    } else {
      logger.info("Updating formula after bottling.")
      let dotsFormulaUrl = try shellClient.formulaUrl()
      try await fileClient.writeFile(string: updatedFileContents, to: dotsFormulaUrl)
    }
    return updatedFileContents
  }
  
  private func checkFormula() throws {
    if commitable {
      logger.info("Checking new formula for syntax errors.")
      _ = try shellClient.background(
        [brew, "audit", "--strict", "--new-formula", "--online", fullFormula]
      )
      logger.info("Passed.")
    }
  }
  
  private func commitFormulaRepository() throws {
    if commitable {
      logger.info("Committing formula repository.")
      try shellClient.runInFormulaRepository(
        "git", "commit", "--all", "--message", "Psychrometrics v\(version)"
      )
    }
  }
  
  private func createPullRequest() throws {
    if commitable {
      logger.info("Creating pull request for the formula repository.")
      // push the branch
      try shellClient.runInFormulaRepository(
        "git", "push", "origin", branch
      )
      try shellClient.runInFormulaRepository(
        "gh", "pr", "create", "--fill", 
        "--base", "main",
        "--repo", "swift-psychrometrics/homebrew-formula"
      )
    }
  }
}

fileprivate struct ParsedOutput {
  let fileName: String
  let bottleBlocks: [String.SubSequence]
  var filePrintableBlock: String { bottleBlocks.joined(separator: "\n") }
  var displayBlock: String { bottleBlocks.map { String($0).blue}.joined(separator: "\n") }
}

fileprivate func parseBottleOutput(from string: String) -> ParsedOutput {
  let lines = string.split(separator: "\n")
  let fileName = lines[2].replacingOccurrences(of: "./", with: "")
  var output = [String.SubSequence]()
  if let startIndex = lines.firstIndex(where: { $0.contains("bottle do") }),
     let endIndex = lines.firstIndex(where: { $0.contains("end") })
  {
    output = Array(lines[startIndex...endIndex])
  }
  
  return .init(
    fileName: fileName,
    bottleBlocks: output
  )
}


fileprivate extension FileClient {
  
  func writeFile(string: String, to url: URL) async throws {
    try await self.write(data: Data(string.utf8), to: url)
  }
}

fileprivate extension ShellClient {
  func formulaRepositoryPath() throws -> String {
    try self.background(
      ["brew", "--repository", "swift-psychrometrics/formula"],
      trimmingCharactersIn: .whitespacesAndNewlines
    )
  }
  
  func formulaUrl() throws -> URL {
    let path = try formulaRepositoryPath()
    return URL(fileURLWithPath: path)
      .appendingPathComponent("Formula")
      .appendingPathComponent("psychrometrics.rb")
  }
  
  func runInFormulaRepository(_ arguments: String...) throws {
    let repo = try formulaRepositoryPath()
    FileManager.default.changeCurrentDirectoryPath(repo)
    try self.foreground(.init(arguments))
  }
}

fileprivate let fileTemplate = """
class Psychrometrics < Formula
  desc "Command-line tool for calculating psychrometric properties"
  homepage "https://github.com/swift-psychrometrics/psychrometrics-cli"
  url "https://github.com/swift-psychrometrics/psychrometrics-cli.git", branch: "main"
  version "{{ VERSION }}"
  license "MIT"
{{ BOTTLEBLOCK }}
  depends_on xcode: ["14.2", :build]

  def install
    system "make", "install", "PREFIX=#{prefix}"
    generate_completions_from_executable(bin/"psychrometrics", "--generate-completion-script")
  end

  test do
    system "#{bin}/psychrometrics" "--version"
  end
end

"""

func fileTemplateWithoutBottleBlock(version: String) -> String {
  fileTemplate.replacingOccurrences(
    of: "{{ VERSION }}",
    with: "\(version)"
  )
  .replacingOccurrences(of: "{{ BOTTLEBLOCK }}", with: "")
}

func fileTemplateWithBottleBlock(block: String, version: String) -> String {
  fileTemplate
    .replacingOccurrences(of: "{{ VERSION }}", with: version)
    .replacingOccurrences(of: "{{ BOTTLEBLOCK }}", with: "\n\(block)\n")
}
