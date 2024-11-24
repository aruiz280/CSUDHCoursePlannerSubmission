import SwiftUI

struct ContentView: View {
    @State private var searchQuery = ""
    @State private var selectedTable = "GeneralEducationCourses"
    @State private var searchResults: [String] = []
    @State private var selectedCourse: Course?
    @State private var isDetailViewPresented = false

    let tables = ["GeneralEducationCourses", "ComputerScienceCourses", "CrossListedCourses", "CourseSchedules"]

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Select Table", selection: $selectedTable) {
                    ForEach(tables, id: \.self) { table in
                        Text(table)
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedTable == table ? Color.green : Color.gray.opacity(0.2))
                            .foregroundColor(selectedTable == table ? .white : .black)
                            .cornerRadius(10)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .onChange(of: selectedTable) {
                    resetSearch()
                }
                
                TextField("Search...", text: $searchQuery)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Search") {
                    performSearch()
                }
                .padding()
                
                List(searchResults, id: \.self) { result in
                    if selectedTable == "CourseSchedules" {
                        // Display the result without a button for CourseSchedules
                        VStack(alignment: .leading, spacing: 8) {
                            Text(result) // Displays the formatted search result
                                .font(.body)
                                .multilineTextAlignment(.leading) // Allows multiline alignment
                        }
                        .padding(.vertical, 8)
                    } else {
                        // Keep the button functionality for other tables
                        Button(action: {
                            let components = result.split(separator: "\n")
                            let courseCode = components.first?.trimmingCharacters(in: .whitespaces)
                            if let courseCode = courseCode {
                                selectedCourse = DatabaseManager.shared.fetchCourseDetails(forEntry: courseCode, inTable: selectedTable)
                            }

                            isDetailViewPresented = (selectedCourse != nil)
                        }) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(result) // Displays the formatted search result
                                    .font(.body)
                                    .multilineTextAlignment(.leading) // Allows multiline alignment
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                
                // Add the new "Upload Transcript" button here
                NavigationLink(destination: UploadTranscriptView()) {
                    Text("Upload Transcript")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5) // Adds a slight shadow for visibility
                }
                .padding()

                
                .navigationDestination(isPresented: $isDetailViewPresented) {
                    if let course = selectedCourse {
                        CourseDetailView(course: course, table: selectedTable)
                    }
                }
                
                


            }
            .padding()
        }
    }

    private func resetSearch() {
        searchQuery = ""
        searchResults = []
        selectedCourse = nil
        isDetailViewPresented = false
    }

    private func performSearch() {
        guard !searchQuery.isEmpty else { return }

        if selectedTable == "CourseSchedules" {
            // Fetch search results specifically for CourseSchedules
            let searchResultsWithSchedules = DatabaseManager.shared.searchCourseSchedules(courseCode: searchQuery)
            
            // Map results to include only actual data
            searchResults = searchResultsWithSchedules.map { schedule in
                """
                Course: \(schedule.courseCode)
                \(schedule.title ?? "")\("\nDays: \(schedule.days ?? "")".trimmingCharacters(in: .whitespaces))
                \(schedule.time != nil ? "Time: \(schedule.time!)" : "")
                \(schedule.location != nil ? "Location: \(schedule.location!)" : "")
                \(schedule.instructor != nil ? "Instructor: \(schedule.instructor!)" : "")
                \(schedule.semester != nil ? "Semester: \(schedule.semester!)" : "")
                \(schedule.units != nil ? "Units: \(schedule.units!)" : "")
                \(schedule.prerequisite != nil ? "Prerequisite: \(schedule.prerequisite!)" : "")
                """
                .trimmingCharacters(in: .whitespacesAndNewlines) // Clean up any empty or trailing spaces/lines
            }
        } else {
            // Handle search for other tables
            searchResults = DatabaseManager.shared.searchCourses(in: selectedTable, code: searchQuery)
        }
    }




    private func fetchCourseDetails(for entry: String) {
        selectedCourse = DatabaseManager.shared.fetchCourseDetails(forEntry: entry, inTable: selectedTable)
        isDetailViewPresented = (selectedCourse != nil)
    }
    
    func formatSearchResult(schedule: (courseCode: String, scheduleID: Int, days: String?, time: String?, instructor: String?, location: String?, semester: String?, title: String?, units: String?, prerequisite: String?)) -> String {
        return """
        Course Code: \(schedule.courseCode)
        Title: \(schedule.title ?? "")
        Days: \(schedule.days ?? ""), Time: \(schedule.time ?? "")
        Instructor: \(schedule.instructor ?? "")
        Location: \(schedule.location ?? "")
        Semester: \(schedule.semester ?? "")
        Units: \(schedule.units ?? "")
        Prerequsite: \(schedule.prerequisite ?? "")
        """
    }


}

//rever to this point
