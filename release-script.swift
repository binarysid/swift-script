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
        var fileContents = try String(contentsOf: fileURL, encoding: .utf8)
        
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

func runGitCommand(command: String) {
    let process = Process()
    let outputPipe = Pipe()
    
    process.executableURL = URL(fileURLWithPath: "/usr/bin/git") // Path to the git executable
    process.arguments = command.split(separator: " ").map(String.init) // Split the command into arguments
    process.standardOutput = outputPipe
    process.standardError = outputPipe // Capture any error output as well
    
    do {
        try process.run() // Start the process
        process.waitUntilExit() // Wait for it to finish
        
        let data = outputPipe.fileHandleForReading.readDataToEndOfFile() // Read the output
        if let output = String(data: data, encoding: .utf8) {
            print("Output: \(output)") // Print the output
        }
    } catch {
        print("Error running command: \(error.localizedDescription)")
    }
}

runGitCommand(command: "add .") // Stage all files
runGitCommand(command: "commit -m \"Release update to version \(version)\"") // Commit with message

// Specify the file path and new version
let podspecFilePath = "StarTrekAI.podspec"  // Update this path
let newVersion = "1.0.2"  // Update the version here
let key = "version"
// Call the function to modify the version
modifyVersionInPodspec(atPath: podspecFilePath, key:key, newVersion: newVersion)
