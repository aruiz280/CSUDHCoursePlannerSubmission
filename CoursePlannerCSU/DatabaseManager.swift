import SQLite 
import Foundation
//revert to this point
class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: Connection?

    private init() {
        connectDatabase()
    }

    func fetchCourseDetailsForSchedules(courseCode: String) -> Course? {
        guard let db = db else { return nil }
        
        let query = """
        SELECT CourseCode, ScheduleID Title, Units, Instructor, Time, Location, Semester, Days, ScheduleID
        FROM CourseSchedules
        WHERE CourseCode = '\(courseCode)'
        ORDER BY ScheduleID
        """
        
        do {
            for row in try db.prepare(query) {
                return Course(
                    id: row[8] as? Int ?? 0,  // ScheduleID for internal use
                    courseCode: row[0] as? String ?? "",
                    courseTitle: row[1] as? String,
                    units: row[2] as? String,
                    instructor: row[3] as? String,
                    time: row[4] as? String,
                    location: row[5] as? String,
                    semester: row[6] as? String,
                    days: row[7] as? String
                )
            }
        } catch {
            print("❌ Error fetching course details: \(error)")
        }
        return nil
    }

    private func connectDatabase() {
        if let dbPath = Bundle.main.path(forResource: "CSUDH_Course_Planner", ofType: "db") {
            do {
                db = try Connection(dbPath)
                print("✅ Database connected successfully")
            } catch {
                print("❌ Error connecting to database: \(error)")
            }
        }
    }

    func searchCourseSchedules(courseCode: String) -> [(courseCode: String, scheduleID: Int, days: String?, time: String?, instructor: String?, location: String?, semester: String?, title: String?, units: String?, prerequisite: String?)] {
        guard let db = db else { return [] }
        var results = [(courseCode: String, scheduleID: Int, days: String?, time: String?, instructor: String?, location: String?, semester: String?, title: String?, units: String?, prerequisite: String?)]()

        let query = """
        SELECT DISTINCT CourseCode, ScheduleID, Days, Time, Instructor, Location, Semester, Title, Units, Prerequisite
        FROM CourseSchedules
        WHERE LOWER(CourseCode) LIKE LOWER('%\(courseCode)%')
        ORDER BY CourseCode, ScheduleID
        """

        print("Executing query: \(query)")

        do {
            for row in try db.prepare(query) {
                results.append((
                    courseCode: row[0] as? String ?? "",
                    scheduleID: row[1] as? Int ?? 0,
                    days: row[2] as? String,
                    time: row[3] as? String,
                    instructor: row[4] as? String,
                    location: row[5] as? String,
                    semester: row[6] as? String,
                    title: row[7] as? String,
                    units: row[8] as? String,
                    prerequisite: row[9] as? String
                ))
            }
        } catch {
            print("❌ Error searching course schedules: \(error)")
        }

        print("Total rows found: \(results.count)")
        return results
    }





    func searchCourses(in table: String, code: String) -> [String] {
        guard let db = db else { return [] }
        var result = [String]()
        
        let query = "SELECT CourseCode FROM \(table) WHERE LOWER(CourseCode) LIKE LOWER('%\(code)%')"
        do {
            for row in try db.prepare(query) {
                if let courseCode = row[0] as? String {
                    result.append(courseCode)
                }
            }
        } catch {
            print("❌ Error searching courses: \(error)")
        }
        return result
    }

    func fetchCourseSchedulesDetails(courseCode: String, scheduleID: Int) -> Course? {
        guard let db = db else { return nil }
        
        // Query to fetch details using both CourseCode and ScheduleID
        let query = """
        SELECT DISTINCT CourseCode, Title, Units, Instructor, Time, Location, Semester, Days
        FROM CourseSchedules
        WHERE CourseCode = '\(courseCode)' AND ScheduleID = \(scheduleID)
        """
        
        print("Executing query: \(query)")  // Debugging statement
        
        do {
            for row in try db.prepare(query) {
                print("Row found: \(row)")  // Debugging statement
                
                return Course(
                    id: 0,
                    courseCode: row[0] as? String ?? "",
                    courseTitle: row[1] as? String,
                    units: row[2] as? String,
                    instructor: row[3] as? String,
                    time: row[4] as? String,
                    location: row[5] as? String,
                    semester: row[6] as? String,
                    days: row[7] as? String
                )
            }
        } catch {
            print("❌ Error fetching course schedules details: \(error)")
        }
        return nil
    }


    func fetchCourseDetails(forEntry entry: String, inTable table: String) -> Course? {
        guard let db = db else { return nil }
        
        let query: String
        switch table {
        case "GeneralEducationCourses":
            query = """
            SELECT CourseCode, CourseTitle, Units, Description, Area, SubArea, GradingScheme, OfferedTerms
            FROM GeneralEducationCourses WHERE CourseCode = '\(entry)'
            """
        case "ComputerScienceCourses":
            query = """
            SELECT CourseCode, CourseTitle, Units, Division, Description, OfferedTerms, IsElective
            FROM ComputerScienceCourses WHERE CourseCode = '\(entry)'
            """
        //case "CourseSchedules":
            //query = """
            //SELECT CourseCode, Title, Units, Instructor, Time, Location, Semester, Days
            //FROM CourseSchedules WHERE CourseCode = '\(entry)'
            //"""
        case "CrossListedCourses":
            query = """
            SELECT CourseCode, GeneralEducationArea, MajorRequirement
            FROM CrossListedCourses WHERE CourseCode = '\(entry)'
            """
        default:
            return nil
        }

        do {
            let statement = try db.prepare(query)
            for row in statement {
                switch table {
                case "GeneralEducationCourses":
                    // Corrected argument order
                    return Course(
                        id: 0,
                        courseCode: row[0] as? String ?? "",
                        courseTitle: row[1] as? String,
                        units: row[2] as? String,
                        description: row[3] as? String,
                        area: row[4] as? String,
                        subArea: row[5] as? String,
                        gradingScheme: row[6] as? String, // GradingScheme before OfferedTerms
                        offeredTerms: row[7] as? String   // Corrected position
                    )
                    
                case "ComputerScienceCourses":
                    // Corrected argument order
                    return Course(
                        id: 0,
                        courseCode: row[0] as? String ?? "",
                        courseTitle: row[1] as? String,
                        units: row[2] as? String,            // Units before Division
                        description: row[4] as? String, offeredTerms: row[5] as? String, division: row[3] as? String,
                        isElective: row[6] as? String
                    )
                    
                //case "CourseSchedules":
                    //return Course(
                        //id: 0,
                        //courseCode: row[0] as? String ?? "",
                        //courseTitle: row[1] as? String,
                        //units: row[2] as? Int,
                        //instructor: row[3] as? String,
                        //time: row[4] as? String,
                        //location: row[5] as? String,
                        //semester: row[6] as? String,
                        //days: row[7] as? String
                    //)
                    
                case "CrossListedCourses":
                    return Course(
                        id: 0,
                        courseCode: row[0] as? String ?? "",
                        generalEducationArea: row[1] as? String,
                        majorRequirement: row[2] as? String
                    )
                default:
                    return nil
                }
            }
        } catch {
            print("❌ Error fetching course details: \(error)")
        }
        return nil
    }
    
    

}

extension DatabaseManager {
    func getAllCompletedCourses() -> [(studentID: String, courseID: String, courseName: String, grade: String, category: String)] {
            guard let db = db else { return [] }
            var courses = [(studentID: String, courseID: String, courseName: String, grade: String, category: String)]()
            
            let query = "SELECT studentID, courseID, courseName, grade, category FROM CompletedCourses"
            do {
                for row in try db.prepare(query) {
                    let studentID = row[0] as? String ?? "N/A"
                    let courseID = row[1] as? String ?? "N/A"
                    let courseName = row[2] as? String ?? "N/A"
                    let grade = row[3] as? String ?? "N/A"
                    let category = row[4] as? String ?? "N/A"
                    
                    courses.append((studentID, courseID, courseName, grade, category))
                }
            } catch {
                print("❌ Error fetching courses: \(error)")
            }
            return courses
        }
    
    
    func insertIntoCompletedCourses(studentID: String, courseID: String, courseName: String, grade: String, category: String) {
        guard let db = db else { return }
        let query = """
        INSERT INTO CompletedCourses (studentID, courseID, courseName, grade, category)
        VALUES (?, ?, ?, ?, ?)
        """
        do {
            let statement = try db.prepare(query)
            try statement.run(studentID, courseID, courseName, grade, category)
            print("✅ Successfully inserted course: \(courseID)")
        } catch {
            print("❌ Error inserting course: \(error)")
        }
    }
    
    // DatabaseManager.swift

    /// Clears all data from the CompletedCourses table.
    func clearCompletedCoursesTable() {
        guard let db = db else {
            print("Database connection not initialized.")
            return
        }
        let query = "DELETE FROM CompletedCourses"
        do {
            try db.run(query)
            print("CompletedCourses table cleared successfully.")
        } catch {
            print("Error clearing CompletedCourses table: \(error)")
        }
    }
    
    // DatabaseManager.swift
    func printAllCompletedCourses() {
        guard let db = db else {
            print("Database connection not initialized.")
            return
        }

        let query = "SELECT studentID, courseID, courseName, grade, category FROM CompletedCourses"
        print("Fetching all rows from CompletedCourses...")

        do {
            for row in try db.prepare(query) {
                let studentID = row[0] as? String ?? "N/A"
                let courseID = row[1] as? String ?? "N/A"
                let courseName = row[2] as? String ?? "N/A"
                let grade = row[3] as? String ?? "N/A"
                let category = row[4] as? String ?? "N/A"

                print("""
                Student ID: \(studentID)
                Course ID: \(courseID)
                Course Name: \(courseName)
                Grade: \(grade)
                Category: \(category)
                """)
            }
        } catch {
            print("Error fetching courses: \(error)")
        }
    }

}




