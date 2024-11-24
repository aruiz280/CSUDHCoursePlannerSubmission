import SwiftUI
import PDFKit

struct UploadTranscriptView: View {
    // State variables for managing the UI and user interactions
    @State private var showDocumentPicker = false // Toggles the document picker
    @State private var transcriptContent: String = "" // Stores extracted text from the PDF
    @State private var isProcessing = false // Indicates whether processing is ongoing
    @State private var successMessage: String? // Displays success or error messages to the user

    var body: some View {
        VStack {
            // Title
            Text("Upload Transcript")
                .font(.largeTitle)
                .bold()
                .padding()

            // Upload Button
            Button(action: {
                showDocumentPicker = true // Trigger document picker
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
                // Show the custom document picker when triggered
                DocumentPicker(onFilePicked: handleFilePicked)
            }

            // Processing Indicator
            if isProcessing {
                ProgressView("Processing Transcript...")
                    .padding()
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
        // Split the transcript into individual lines for processing
        let lines = content.split(separator: "\n")
        for line in lines {
            // Parse and insert only valid course lines
            if line.contains("Course Description") {
                if let courseData = parseCourseLine(String(line)) {
                    DatabaseManager.shared.insertIntoCompletedCourses(
                        studentID: courseData.studentID,
                        courseID: courseData.courseID,
                        courseName: courseData.courseName,
                        grade: courseData.grade,
                        category: courseData.category
                    )
                }
            }
        }
    }

    // MARK: - Parse Individual Course Line
    /// Extracts data from a line of the transcript
    private func parseCourseLine(_ line: String) -> (studentID: String, courseID: String, courseName: String, grade: String, category: String)? {
        let components = line.split(separator: " ")
        guard components.count >= 5 else { return nil } // Ensure enough data is present

        let studentID = "211547663" // Static for now; can be dynamically parsed
        let courseID = String(components[0])
        let courseName = components[1...2].joined(separator: " ")
        let grade = String(components[3])
        let category = "Default"

        return (studentID, courseID, courseName, grade, category)
    }
}
