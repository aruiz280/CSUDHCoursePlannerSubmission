import SwiftUI

struct ViewAcademicRequirements: View {
    @State private var requirements: [(courseID: String, courseName: String, category: String)] = []
    @State private var expandedCategories: Set<String> = [] // Tracks expanded categories
    @State private var searchText: String = "" // For dynamic filtering

    var body: some View {
        VStack {
            // Title
            Text("Unmet Academic Requirements")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
                .foregroundColor(Color.blue)

            // Search bar
            HStack {
                TextField("Search by course or category", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
            }
            .padding(.bottom)

            // Display requirements
            if filteredRequirements().isEmpty {
                Text("No unmet requirements found.")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.top, 20)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        // Unmet GE Requirements Section
                        if !groupedRequirementsGE().isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Unmet GE Requirements")
                                    .font(.largeTitle)
                                    .fontWeight(.heavy)
                                    .padding()
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                LazyVStack(alignment: .leading, spacing: 20) {
                                    ForEach(groupedRequirementsGE(), id: \.key) { category, courses in
                                        VStack(alignment: .leading, spacing: 10) {
                                            // Category Header
                                            Button(action: {
                                                toggleCategoryExpansion(category)
                                            }) {
                                                HStack {
                                                    Text("Category: \(category)")
                                                        .font(.title3)
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(.white)
                                                    Spacer()
                                                    Image(systemName: expandedCategories.contains(category) ? "chevron.up" : "chevron.down")
                                                        .foregroundColor(.white)
                                                }
                                                .padding()
                                                .background(categoryColor(category))
                                                .cornerRadius(10)
                                            }

                                            // Courses List (visible only if category is expanded)
                                            if expandedCategories.contains(category) {
                                                ForEach(courses, id: \.courseID) { course in
                                                    HStack {
                                                        VStack(alignment: .leading, spacing: 5) {
                                                            Text("\(course.courseID): \(course.courseName)")
                                                                .font(.headline)
                                                            Text("Category: \(course.category)")
                                                                .font(.subheadline)
                                                                .foregroundColor(.gray)
                                                        }
                                                        Spacer()
                                                        Button(action: {
                                                            // Placeholder for Add Course functionality
                                                        }) {
                                                            Text("Add Course")
                                                                .font(.footnote)
                                                                .foregroundColor(.blue)
                                                                .padding(.vertical, 8)
                                                                .padding(.horizontal, 12)
                                                                .overlay(
                                                                    RoundedRectangle(cornerRadius: 5)
                                                                        .stroke(Color.blue, lineWidth: 1)
                                                                )
                                                        }
                                                    }
                                                    .frame(height: 80) // Uniform size for all course boxes
                                                    .padding(10)
                                                    .background(Color.white)
                                                    .cornerRadius(8)
                                                    .shadow(radius: 2)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        // Unmet CSC Requirements Section
                        if !groupedRequirementsCSC().isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Unmet CSC Requirements")
                                    .font(.largeTitle)
                                    .fontWeight(.heavy)
                                    .padding()
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                LazyVStack(alignment: .leading, spacing: 20) {
                                    ForEach(groupedRequirementsCSC(), id: \.key) { category, courses in
                                        VStack(alignment: .leading, spacing: 10) {
                                            // Category Header
                                            Button(action: {
                                                toggleCategoryExpansion(category)
                                            }) {
                                                HStack {
                                                    Text("Category: \(category)")
                                                        .font(.title3)
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(.white)
                                                    Spacer()
                                                    Image(systemName: expandedCategories.contains(category) ? "chevron.up" : "chevron.down")
                                                        .foregroundColor(.white)
                                                }
                                                .padding()
                                                .background(categoryColor(category))
                                                .cornerRadius(10)
                                            }

                                            // Courses List (visible only if category is expanded)
                                            if expandedCategories.contains(category) {
                                                ForEach(courses, id: \.courseID) { course in
                                                    HStack {
                                                        VStack(alignment: .leading, spacing: 5) {
                                                            Text("\(course.courseID): \(course.courseName)")
                                                                .font(.headline)
                                                            Text("Category: \(course.category)")
                                                                .font(.subheadline)
                                                                .foregroundColor(.gray)
                                                        }
                                                        Spacer()
                                                        Button(action: {
                                                            // Placeholder for Add Course functionality
                                                        }) {
                                                            Text("Add Course")
                                                                .font(.footnote)
                                                                .foregroundColor(.blue)
                                                                .padding(.vertical, 8)
                                                                .padding(.horizontal, 12)
                                                                .overlay(
                                                                    RoundedRectangle(cornerRadius: 5)
                                                                        .stroke(Color.blue, lineWidth: 1)
                                                                )
                                                        }
                                                    }
                                                    .frame(height: 80) // Uniform size for all course boxes
                                                    .padding(10)
                                                    .background(Color.white)
                                                    .cornerRadius(8)
                                                    .shadow(radius: 2)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }

            // Refresh button
            Button(action: fetchRequirements) {
                Text("Refresh Requirements")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .onAppear {
            fetchRequirements()
        }
        .padding()
        .background(Color(UIColor.systemGray6).edgesIgnoringSafeArea(.all)) // Background color
    }

    // Group requirements for GE
    private func groupedRequirementsGE() -> [(key: String, value: [(courseID: String, courseName: String, category: String)])] {
        Dictionary(grouping: filteredRequirements().filter { !["Upper", "Lower", "Elective"].contains($0.category) }, by: { $0.category })
            .sorted(by: { $0.key < $1.key }) // Sort categories alphabetically
    }

    // Group requirements for CSC
    private func groupedRequirementsCSC() -> [(key: String, value: [(courseID: String, courseName: String, category: String)])] {
        Dictionary(grouping: filteredRequirements().filter { ["Upper", "Lower", "Elective"].contains($0.category) }, by: { $0.category })
            .sorted(by: { $0.key < $1.key }) // Sort categories alphabetically
    }

    // Filter requirements based on search text
    private func filteredRequirements() -> [(courseID: String, courseName: String, category: String)] {
        if searchText.isEmpty {
            return requirements
        } else {
            return requirements.filter { requirement in
                requirement.courseID.contains(searchText) ||
                requirement.courseName.lowercased().contains(searchText.lowercased()) ||
                requirement.category.lowercased().contains(searchText.lowercased())
            }
        }
    }

    // Toggle category expansion
    private func toggleCategoryExpansion(_ category: String) {
        if expandedCategories.contains(category) {
            expandedCategories.remove(category)
        } else {
            expandedCategories.insert(category)
        }
    }

    // Determine category color
    private func categoryColor(_ category: String) -> Color {
        switch category.prefix(1) {
        case "A": return Color.blue
        case "B": return Color.green
        case "C": return Color.orange
        case "D": return Color.purple
        case "E": return Color.teal
        case "F": return Color.red
        default: return Color.gray
        }
    }

    // Fetch unmet requirements from the database
    private func fetchRequirements() {
        requirements = DatabaseManager.shared.fetchUnmetDegreeRequirements()
    }
}


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
                
                NavigationStack {
                    VStack {
                        NavigationLink(destination: ViewAcademicRequirements()) {
                            Text("View Academic Requirements")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding()
                        // Other buttons or UI elements
                    }
                }


                
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
