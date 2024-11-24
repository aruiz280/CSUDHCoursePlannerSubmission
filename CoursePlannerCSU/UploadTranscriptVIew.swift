import SwiftUI
import PDFKit

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
    private func handleFilePicked(url: URL) {
        isProcessing = true
        transcriptContent = parsePDF(url: url) // Parse the PDF content
        processTranscript(content: transcriptContent) // Process the extracted content
        isProcessing = false
        successMessage = "Transcript successfully uploaded and processed!" // Notify user
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

        var currentCourseID = ""
        var currentCourseName = ""
        var currentGrade = ""

        for (index, line) in lines.enumerated() {
            // Extract Student ID
            if line.contains("Student ID") {
                studentID = extractStudentID(from: line)
            }

            // Extract Course ID
            if line.contains("Course") {
                let nextLineIndex = index + 1
                if nextLineIndex < lines.count {
                    currentCourseID = lines[nextLineIndex]
                }
            }

            // Extract Course Description
            if line.contains("Description") {
                let nextLineIndex = index + 1
                if nextLineIndex < lines.count {
                    currentCourseName = lines[nextLineIndex]
                }
            }

            // Extract Grade
            if line.contains("Grade") {
                let nextLineIndex = index + 1
                if nextLineIndex < lines.count {
                    currentGrade = lines[nextLineIndex]
                    // After extracting all necessary data, add the entry to the courses list
                    let category = determineCategory(for: currentCourseID)
                    courses.append((courseID: currentCourseID, courseName: currentCourseName, grade: currentGrade, category: category))
                }
            }
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

    // MARK: - Extract Student ID
    /// Extracts the Student ID from the line containing it
    private func extractStudentID(from line: String) -> String {
        let components = line.split(separator: ":")
        return components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : ""
    }

    // MARK: - Determine Category
    /// Determines the category of the course based on the course ID
    private func determineCategory(for courseID: String) -> String {
        let csKeywords = ["CSC", "MAT", "PHY"] // Add other Computer Science keywords if necessary
        for keyword in csKeywords {
            if courseID.uppercased().contains(keyword) {
                return "Computer Science"
            }
        }
        return "General Education"
    }

}
