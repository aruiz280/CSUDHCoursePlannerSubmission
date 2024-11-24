import SwiftUI

struct CourseDetailView: View {
    let course: Course
    let table: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Course Code: \(course.courseCode)")
                .font(.title)
                .bold()
            
            if let title = course.courseTitle {
                Text("Title: \(title)")
            }
            
            if let description = course.description {
                Text("Description: \(description)")
            }
            
            switch table {
            case "GeneralEducationCourses":
                if let area = course.area {
                    Text("Area: \(area)")
                }
                if let subArea = course.subArea {
                    Text("Sub-Area: \(subArea)")
                }
                if let gradingScheme = course.gradingScheme {
                    Text("Grading Scheme: \(gradingScheme)")
                }
                if let offeredTerms = course.offeredTerms {
                    Text("Offered Terms: \(offeredTerms)")
                }
                
            case "ComputerScienceCourses":
                if let division = course.division {
                    Text("Division: \(division)")
                }
                if let units = course.units {
                    Text("Units: \(units)")
                }
                if let offeredTerms = course.offeredTerms {
                    Text("Offered Terms: \(offeredTerms)")
                }
                if let isElective = course.isElective {
                    Text("Elective: \(isElective)")
                }
                
            case "CourseSchedules":
                if let title = course.courseTitle {
                    Text("Title: \(title)")
                }
                if let units = course.units {
                    Text("Units: \(units)")
                }
                if let instructor = course.instructor {
                    Text("Instructor: \(instructor)")
                }
                if let time = course.time {
                    Text("Time: \(time)")
                }
                if let location = course.location {
                    Text("Location: \(location)")
                }
                if let semester = course.semester {
                    Text("Semester: \(semester)")
                }
                if let days = course.days {
                    Text("Days: \(days)")
                }
                
            case "CrossListedCourses":
                if let generalEducationArea = course.generalEducationArea {
                    Text("General Education Area: \(generalEducationArea)")
                }
                if let majorRequirement = course.majorRequirement {
                    Text("Major Requirement: \(majorRequirement)")
                }
                
            default:
                Text("No additional information available.")
            }
        }
        .padding()
        .navigationTitle("Course Details")
    }
}
