import Foundation

enum Command {
    case git, bash
    
    var path: String {
        switch self {
        case .git: return "/usr/bin/git"
        case .bash: return "/bin/bash"
        }
    }
    
    var name: String {
        switch self {
        case .git: return "git"
        case .bash: return "bash"
        }
    }
    
    enum Argument {
        static let version = "--version"
        static let mirrorDir = "--mirrorDir"
    }
}

// Function to get the value of a command-line option
func getCommandLineOption(_ option: String) -> String? {
    for arg in CommandLine.arguments {
        if arg.starts(with: option) {
            let value = arg.replacingOccurrences(of: "\(option)=", with: "")
            return value
        }
    }
    return nil
}

// Function to modify the s.version in the file
func modifyVersionInPodspec(atPath path: String, key: String, newVersion: String) {
    let fileManager = FileManager.default
    
    // Check if the file exists at the specified path
    guard fileManager.fileExists(atPath: path) else {
        print("File not found at path \(path)")
        return
    }
    
    // Read the file contents
    do {
        let fileURL = URL(fileURLWithPath: path)
        let fileContents = try String(contentsOf: fileURL, encoding: .utf8)
        
        // Split the file contents into lines
        var lines = fileContents.components(separatedBy: .newlines)
        var versionUpdated = false
        
        // Modify the line that contains s.version
        for i in 0..<lines.count {
            if lines[i].contains(key) {
                let oldVersionLine = lines[i]
                print("Found line: \(oldVersionLine)")  // Log the found line
                
                // Extract the line containing version
                let components = oldVersionLine.components(separatedBy: "'")
                
                // Ensure the structure is valid (3 parts: s.version, oldVersion, and closing quote)
                if components.count == 3 {
                    let newVersionLine = "\(components[0])'\(newVersion)'"
                    lines[i] = newVersionLine
                    versionUpdated = true
                    print("Updated line: \(newVersionLine)")  // Log the updated line
                    break
                } else {
                    print("Unexpected line structure for version")
                }
            }
        }
        
        if versionUpdated {
            // Join the modified lines back into a single string
            let modifiedContents = lines.joined(separator: "\n")
            
            // Write the modified content back to the file
            try modifiedContents.write(to: fileURL, atomically: true, encoding: .utf8)
            print("Version updated to \(newVersion) successfully!")
        } else {
            print("Version update failed: Could not find or update the version line.")
        }
        
    } catch {
        print("Error reading or writing to the file: \(error)")
    }
}

func runCommand(command: Command, arguments: [String], workingDirectory: String? = nil) {
    let process = Process()
    let outputPipe = Pipe()
    let errorPipe = Pipe()

    process.executableURL = URL(fileURLWithPath: command.path)
    process.arguments = arguments
    process.standardOutput = outputPipe
    process.standardError = errorPipe
    
    if let directory = workingDirectory {
        process.currentDirectoryURL = URL(fileURLWithPath: directory)
        print("Working directory changed to \(directory)")
    }

    do {
        try process.run()
        print("Executing: \(([command.name] + arguments).joined(separator: " "))")

        process.waitUntilExit()

        let exitStatus = process.terminationStatus
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        if exitStatus == 0 {
            if let output = String(data: outputData, encoding: .utf8) {
                print("Output: \(output)")
            }
        } else {
            if let errorOutput = String(data: errorData, encoding: .utf8) {
                print("Error: \(errorOutput)")
            }
            print("Error: Command failed with exit code \(exitStatus). Command: \(arguments.joined(separator: " "))")
        }
    } catch {
        print("Error running command: \(error.localizedDescription)")
    }
}

func gitRelease(version: String) {
    let add = ["add", "."]
    let commitMessage = "Release update to version \(version)"
    let commit = ["commit", "-m", commitMessage]
    let createTag = ["tag", "-a", version, "-m", "Tagging version \(version)"]
    let pushCommitsWithTags = ["push", "--follow-tags"]
    
    runCommand(command: .git, arguments: add)
    runCommand(command: .git, arguments: commit)
    runCommand(command: .git, arguments: createTag)
    runCommand(command: .git, arguments: pushCommitsWithTags)
}

func syncGitMirror() {
    let fetchOriginCommand = ["fetch", "origin"]
    let pushMirrorCommand = ["push", "--mirror", "target"]
    guard let mirrorDir = getCommandLineOption(Command.Argument.mirrorDir) else {
        print("Usage: swift release-script.swift --mirrorDir=<mirrorDir>")
        exit(1)
    }

    runCommand(command: .git, arguments: fetchOriginCommand, workingDirectory: mirrorDir)
    runCommand(command: .git, arguments: pushMirrorCommand, workingDirectory: mirrorDir)

}

// Get the version from command-line arguments
guard let version = getCommandLineOption(Command.Argument.version) else {
    print("Usage: swift release-script.swift --version=<version>")
    exit(1)
}

// Specify the file path and new version
let podspecFilePath = "StarTrekAI.podspec"
let key = "version"

modifyVersionInPodspec(atPath: podspecFilePath, key:key, newVersion: version)
gitRelease(version: version)
syncGitMirror()
