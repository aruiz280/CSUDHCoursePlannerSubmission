import SwiftUI

struct ViewAcademicRequirements: View {
    @State private var requirements: [(courseID: String, courseName: String, category: String)] = []
    @State private var expandedCategories: Set<String> = [] // Tracks expanded categories

    var body: some View {
        VStack {
            // Title
            Text("Unmet Academic Requirements")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
                .foregroundColor(Color.blue)

            // Display requirements
            if requirements.isEmpty {
                Text("No unmet requirements found.")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.top, 20)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 30) {
                        // Unmet GE Requirements Section
                        if !groupedRequirementsGE().isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                // Enhanced Section Header (Black Box)
                                HStack {
                                    Text("Unmet GE Requirements")
                                        .font(.system(size: 26, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.black)
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                }
                                .frame(height: 100) // Taller than category boxes
                                .padding(.horizontal)

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
                                            ForEach(removeDuplicates(from: courses), id: \.courseID) { course in
                                                HStack {
                                                    VStack(alignment: .leading, spacing: 5) {
                                                        Text("\(course.courseID): \(course.courseName)")
                                                            .font(.headline)
                                                            .foregroundColor(.black)
                                                        Text("Category: \(course.category)")
                                                            .font(.subheadline)
                                                            .foregroundColor(.gray)
                                                    }
                                                    Spacer()
                                                }
                                                .padding(10)
                                                .background(Color.white)
                                                .cornerRadius(8)
                                                .shadow(radius: 2)
                                                .frame(height: 80) // Uniform size for all boxes
                                                .padding(.horizontal)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Unmet CSC Requirements Section
                        if !groupedRequirementsCSC().isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                // Enhanced Section Header (Black Box)
                                HStack {
                                    Text("Unmet CSC Requirements")
                                        .font(.system(size: 26, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.black)
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                }
                                .frame(height: 100) // Taller than category boxes
                                .padding(.horizontal)

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
                                            ForEach(removeDuplicates(from: courses), id: \.courseID) { course in
                                                HStack {
                                                    VStack(alignment: .leading, spacing: 5) {
                                                        Text("\(course.courseID): \(course.courseName)")
                                                            .font(.headline)
                                                            .foregroundColor(.black)
                                                        Text("Category: \(course.category)")
                                                            .font(.subheadline)
                                                            .foregroundColor(.gray)
                                                    }
                                                    Spacer()
                                                }
                                                .padding(10)
                                                .background(Color.white)
                                                .cornerRadius(8)
                                                .shadow(radius: 2)
                                                .frame(height: 80) // Uniform size for all boxes
                                                .padding(.horizontal)
                                            }
                                        }
                                    }
                                }
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
        Dictionary(grouping: requirements.filter { !["Upper", "Lower", "Elective"].contains($0.category) }, by: { $0.category })
            .sorted(by: { $0.key < $1.key }) // Sort categories alphabetically
    }

    // Group requirements for CSC
    private func groupedRequirementsCSC() -> [(key: String, value: [(courseID: String, courseName: String, category: String)])] {
        Dictionary(grouping: requirements.filter { ["Upper", "Lower", "Elective"].contains($0.category) }, by: { $0.category })
            .sorted(by: { $0.key < $1.key }) // Sort categories alphabetically
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

    // Remove duplicate courses
    private func removeDuplicates(from courses: [(courseID: String, courseName: String, category: String)]) -> [(courseID: String, courseName: String, category: String)] {
        var seen = Set<String>()
        return courses.filter { course in
            guard !seen.contains(course.courseID) else { return false }
            seen.insert(course.courseID)
            return true
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
    @State private var shoppingCart: [(courseCode: String, title: String)] = [] // Shopping cart state
    @State private var isShoppingCartViewPresented = false

    let tables = ["GeneralEducationCourses", "ComputerScienceCourses", "CrossListedCourses", "CourseSchedules"]

    var body: some View {
        NavigationStack {
            VStack {
                // Picker for Table Selection
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

                // Search Bar
                TextField("Search...", text: $searchQuery)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                // Search Button
                Button("Search") {
                    performSearch()
                }
                .padding()

                // Search Results List
                List(searchResults, id: \.self) { result in
                    if selectedTable == "CourseSchedules" {
                        // CourseSchedules Format with Add Course Button
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(result)
                                    .font(.body)
                                    .multilineTextAlignment(.leading)
                            }

                            Spacer()

                            // Add Course Button for CourseSchedules
                            Button(action: {
                                addToShoppingCart(course: result)
                            }) {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                            }
                            .buttonStyle(BorderlessButtonStyle()) // Prevents list item selection
                        }
                        .padding(.vertical, 8)
                    } else {
                        // Original Button Functionality for Other Tables
                        Button(action: {
                            let components = result.split(separator: "\n")
                            let courseCode = components.first?.trimmingCharacters(in: .whitespaces)
                            if let courseCode = courseCode {
                                selectedCourse = DatabaseManager.shared.fetchCourseDetails(forEntry: courseCode, inTable: selectedTable)
                            }

                            isDetailViewPresented = (selectedCourse != nil)
                        }) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(result)
                                    .font(.body)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }

                // Upload Transcript Button
                NavigationLink(destination: UploadTranscriptView()) {
                    Text("Upload Transcript")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding()

                // View Academic Requirements Button
                NavigationLink(destination: ViewAcademicRequirements()) {
                    Text("View Academic Requirements")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .padding()
            .navigationBarTitle("Course Planner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Shopping Cart Button in the top-right corner
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isShoppingCartViewPresented = true
                    }) {
                        HStack {
                            Image(systemName: "cart.fill")
                            Text("\(shoppingCart.count)")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Circle().fill(Color.red))
                        }
                    }
                    .sheet(isPresented: $isShoppingCartViewPresented) {
                        ShoppingCartView(shoppingCart: $shoppingCart)
                    }
                }
            }
            .navigationDestination(isPresented: $isDetailViewPresented) {
                if let course = selectedCourse {
                    CourseDetailView(course: course, table: selectedTable)
                }
            }
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
            // Fetch search results for CourseSchedules
            let searchResultsWithSchedules = DatabaseManager.shared.searchCourseSchedules(courseCode: searchQuery)

            // Format search results for display
            searchResults = searchResultsWithSchedules.map { schedule in
                """
                Course: \(schedule.courseCode)
                Title: \(schedule.title ?? "")
                Days: \(schedule.days ?? ""), Time: \(schedule.time ?? "")
                Location: \(schedule.location ?? "")
                Instructor: \(schedule.instructor ?? "")
                Semester: \(schedule.semester ?? "")
                Units: \(schedule.units ?? "")
                Prerequisite: \(schedule.prerequisite ?? "")
                """
            }
        } else {
            // Original functionality for other tables
            searchResults = DatabaseManager.shared.searchCourses(in: selectedTable, code: searchQuery)
        }
    }

    private func addToShoppingCart(course: String) {
        let components = course.split(separator: "\n")
        let courseCode = components.first?.trimmingCharacters(in: .whitespaces) ?? "Unknown"
        let title = components.dropFirst().joined(separator: " ").trimmingCharacters(in: .whitespaces)

        shoppingCart.append((courseCode: courseCode, title: title))
    }
}

struct ShoppingCartView: View {
    @Binding var shoppingCart: [(courseCode: String, title: String)] // Binding to the shopping cart in ContentView
    @State private var errorMessage: String? // State for error message
    @State private var isSuccessMessageVisible = false // State to show success message

    var body: some View {
        NavigationStack {
            VStack {
                // Title
                Text("Your Shopping Cart")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                // Error Message Display
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                if !shoppingCart.isEmpty {
                    Text("Please verify you have met all prerequisite courses before registering.")
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.yellow.opacity(0.2))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }

                // Check if the shopping cart is empty
                if shoppingCart.isEmpty {
                    Text("No courses in your shopping cart.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        // List of courses in the shopping cart
                        ForEach(shoppingCart, id: \.courseCode) { course in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(course.courseCode)
                                    .font(.headline)
                                Text(course.title)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding()

                            // Remove Button
                            Button(action: {
                                removeFromShoppingCart(course: course)
                            }) {
                                Text("Remove Course")
                                    .padding(8)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }

                    // Register Courses Button
                    Button(action: registerCourses) {
                        Text("Register Courses")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                    .alert("Success", isPresented: $isSuccessMessageVisible) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("Courses for Spring 2025 have been scheduled!")
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Shopping Cart")
        }
    }

    // Remove a course from the shopping cart
    private func removeFromShoppingCart(course: (courseCode: String, title: String)) {
        if let index = shoppingCart.firstIndex(where: { $0.courseCode == course.courseCode }) {
            shoppingCart.remove(at: index)
        }
    }

    // Register Courses Logic
    private func registerCourses() {
        // Check for duplicates in the shopping cart
        let courseCodeCounts = Dictionary(grouping: shoppingCart, by: { $0.courseCode }).mapValues { $0.count }

        if let duplicate = courseCodeCounts.first(where: { $0.value > 1 }) {
            // If duplicates exist, show error message
            errorMessage = "You have multiple instances of \(duplicate.key). Please verify your selecion to Register for Spring 2025."
        } else {
            // No duplicates, proceed with registration
            errorMessage = nil
            isSuccessMessageVisible = true
            // Add additional logic here to save the courses to a database or mark them as registered
        }
    }
}
