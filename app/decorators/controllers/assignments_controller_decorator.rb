AssignmentsController.class_eval do
  def tiny_student_hash(group)
    group.map {|obj| {id: obj.user_id, name: obj.user.name} }
  end

  def students_in_course
    tiny_student_hash(@context.student_enrollments.where(type: "StudentEnrollment"))
  end

  def excused_students
    tiny_student_hash(@assignment.excused_submissions)
  end

  def strongmind_show
    @assignment ||= @context.assignments.find(params[:id])
    if excused_students.any?
      @excused = excused_students.map { |stu| stu[:name] }.join(', ')
    end
    instructure_show
  end

  alias_method :instructure_show, :show
  alias_method :show, :strongmind_show
end