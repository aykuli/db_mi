```mermaid
  flowchart LR
    name0((name)) --- students --- students_courses{students_courses} --- cources0(cources) --- title0((title))
    cources0 --- creadits0((credits))

    name1((name)) --- tutors --- tutors_courses{tutors_courses} --- cources1(cources) --- title1((title))
    cources1 --- creadits1((credits))

    name20((name)) --- students2(students) --- exams --- course2(course) --- title2((title))
    exams --- tutors2(tutors) ---  name21((name))
    exams --- grade((grade))
  ```

