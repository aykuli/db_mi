

```mermaid
erDiagram
  courses {
    int id
    string title
    int credits
  }
  students {
    int id
    string name
  }
  tutors {
    int id
    string name
  }
  exams {
    int id
    int student_id
    int course_id
    int examiner_id
    int grade
  }
  students_cources {
    int student_id
    int course_id
  }
  tutors_cources {
    int tutor_id
    int course_id    
  }

  students  ||--o{  students_cources: has_many
  courses  ||--o{  students_cources: has_many

  tutors  ||--o{  tutors_cources: has_many
  courses  ||--o{  tutors_cources: has_many

  tutors  ||--o{  exams: has_many
  students  ||--o{  exams: has_many
  courses  ||--o{  exams: has_many
  ```
  