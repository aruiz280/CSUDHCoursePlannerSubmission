import SwiftUI
import PDFKit
//////////////////////
struct UploadTranscriptView: View {
    // State variables for managing the UI and user interactions
    @State private var showDocumentPicker = false // Toggles the document picker
    @State private var transcriptContent: String = "" // Stores extracted text from the PDF
    @State private var isProcessing = false // Indicates whether processing is ongoing
    @State private var successMessage: String? // Displays success or error messages to the user
    @State private var showConfirmationDialog = false // Toggles the reset confirmation dialog

    var body: some View {
        VStack {
            // Title
            Text("Upload Transcript")
                .font(.largeTitle)
                .bold()
                .padding()

            // Upload Button
            Button(action: {
                showDocumentPicker = true
            }) {
                Text("Select Transcript PDF")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker(onFilePicked: handleFilePicked)
            }

            // Reset Button with Confirmation Dialog
            Button(action: {
                showConfirmationDialog = true
            }) {
                Text("Reset CompletedCourses")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            .alert(isPresented: $showConfirmationDialog) {
                Alert(
                    title: Text("Confirm Reset"),
                    message: Text("Are you sure you want to reset the CompletedCourses table? This action cannot be undone."),
                    primaryButton: .destructive(Text("Reset")) {
                        DatabaseManager.shared.clearCompletedCoursesTable()
                        successMessage = "CompletedCourses table has been reset."
                    },
                    secondaryButton: .cancel()
                )
            }

            // Success Message
            if let message = successMessage {
                Text(message)
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding()
            }

            Spacer()
        }
        .padding()
    }


    // MARK: - File Handling
    /// Handles the file once it is picked by the user
    // UploadTranscriptView.swift
    private func handleFilePicked(url: URL) {
        isProcessing = true
        DispatchQueue.global().async {
            self.transcriptContent = self.parsePDF(url: url) // Parse the PDF content
            self.processTranscript(content: self.transcriptContent) // Process the extracted content
            DispatchQueue.main.async {
                self.isProcessing = false
                self.successMessage = "Transcript successfully uploaded and processed!"
                
                // Print the contents of the CompletedCourses table
                DatabaseManager.shared.printAllCompletedCourses()
            }
        }
    }


    // MARK: - PDF Parsing
    /// Extracts text content from the PDF
    private func parsePDF(url: URL) -> String {
        guard let pdfDocument = PDFDocument(url: url) else { return "" }
        var fullText = ""
        for pageIndex in 0..<pdfDocument.pageCount {
            if let page = pdfDocument.page(at: pageIndex),
               let pageText = page.string {
                fullText += pageText + "\n"
            }
        }
        return fullText
    }

    // MARK: - Process Transcript Content
    /// Processes the parsed content and inserts data into the database
    private func processTranscript(content: String) {
        let lines = content.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        var studentID = ""
        var courses: [(courseID: String, courseName: String, grade: String, category: String)] = []
        var tempLine = ""

        for line in lines {
            // Extract Student ID
            if line.contains("Student ID") {
                studentID = extractStudentID(from: line)
                continue
            }

            // Combine multi-line course descriptions
            if line.range(of: #"^[A-Z]{3} \d{3}"#, options: .regularExpression) != nil {
                // Course ID pattern
                if !tempLine.isEmpty {
                    processCourseLine(tempLine, into: &courses)
                }
                tempLine = line
            } else {
                tempLine += " " + line // Append to previous line
            }
        }

        // Process the last accumulated line
        if !tempLine.isEmpty {
            processCourseLine(tempLine, into: &courses)
        }

        // Insert extracted data into the database
        for course in courses {
            DatabaseManager.shared.insertIntoCompletedCourses(
                studentID: studentID,
                courseID: course.courseID,
                courseName: course.courseName,
                grade: course.grade,
                category: course.category
            )
        }

        successMessage = "Transcript processed successfully! \(courses.count) courses added."
    }


    // MARK: - Helper for Processing Course Lines
    /// Processes a single course line and appends it to the courses array
    private func processCourseLine(_ line: String, into courses: inout [(courseID: String, courseName: String, grade: String, category: String)]) {
        let courseSegments = splitMultipleCourses(from: line)
        for segment in courseSegments {
            if let courseData = parseCourseLine(segment) {
                courses.append(courseData)
            }
        }
    }

    // MARK: - Parse Individual Course Line
    /// Extracts data from a course row
    private func parseCourseLine(_ line: String) -> (courseID: String, courseName: String, grade: String, category: String)? {
        // Flexible pattern to match course lines
        let pattern = #"^([A-Z]{3} \d{3})\s+(.+?)\s+(?:\d+\.\d{3})?\s+(?:\d+\.\d{3})?\s+([A-F][+-]?)?"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])

        if let match = regex?.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count)) {
            let courseID = String(line[Range(match.range(at: 1), in: line)!])
            let courseName = String(line[Range(match.range(at: 2), in: line)!])
            let grade: String
            if let gradeRange = Range(match.range(at: 3), in: line) {
                grade = String(line[gradeRange])
            } else {
                grade = "N/A" // Default if grade is missing
            }
            let category = determineCategory(for: courseID)
            return (courseID, courseName, grade, category)
        }

        // Log skipped line for debugging
        print("Skipped line: \(line)")
        return nil
    }

    // MARK: - Split Multiple Courses
    /// Splits the line by course ID patterns (e.g., "CSC 115", "MAT 153")
    private func splitMultipleCourses(from line: String) -> [String] {
        let coursePattern = #"([A-Z]{3} \d{3})"# // Match course IDs like "CSC 115"
        let regex = try? NSRegularExpression(pattern: coursePattern, options: [])
        let matches = regex?.matches(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count)) ?? []

        var segments: [String] = []
        var lastIndex = line.startIndex

        for match in matches {
            if let range = Range(match.range, in: line) {
                // Extract content before the current match
                if lastIndex != range.lowerBound {
                    let segment = String(line[lastIndex..<range.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
                    if !segment.isEmpty {
                        segments.append(segment)
                    }
                }
                lastIndex = range.lowerBound
            }
        }

        // Add the last remaining part of the line
        let remaining = String(line[lastIndex...]).trimmingCharacters(in: .whitespacesAndNewlines)
        if !remaining.isEmpty {
            segments.append(remaining)
        }

        return segments
    }

    // MARK: - Extract Student ID
    /// Extracts the Student ID from the line containing it
    private func extractStudentID(from line: String) -> String {
        let components = line.split(separator: ":")
        return components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : ""
    }

    // MARK: - Determine Category
    /// Determines the category of the course based on the course ID
    private func determineCategory(for courseID: String) -> String {
        let csKeywords = ["CSC", "MAT", "PHY", "CIS"] // Add other Computer Science-related codes if necessary
        for keyword in csKeywords {
            if courseID.uppercased().contains(keyword) {
                return "Computer Science"
            }
        }
        return "General Education"
    }



}
