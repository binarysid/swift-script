import Foundation

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

func runGitCommand(_ arguments: [String]) {
    let process = Process()
    let outputPipe = Pipe()
    let errorPipe = Pipe()

    process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
    process.arguments = arguments
    process.standardOutput = outputPipe
    process.standardError = errorPipe

    do {
        try process.run()
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

// Specify the file path and new version
let podspecFilePath = "StarTrekAI.podspec"  // Update this path
let version = "1.0.4"  // Update the version here
let key = "version"
let commitMessage = "Release update to version \(version)"
let commitCommand = ["commit", "-m", commitMessage]
let tagCommand = ["tag", "-a", version]

modifyVersionInPodspec(atPath: podspecFilePath, key:key, newVersion: version)
runGitCommand(["add", "."])
runGitCommand(commitCommand)
runGitCommand(tagCommand)
