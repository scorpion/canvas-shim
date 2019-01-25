module CanvasShim
  module CourseProgress
    def module_progressions
      @_module_progressions ||= course.context_module_progressions.
                                    where(user_id: User.find(find_user_id), context_module_id: modules).to_a
    end

    def self.included(mod)
      (mod.instance_methods & self.instance_methods).each do |method|
        mod.instance_eval{remove_method method.to_sym}
      end
    end

    def requirements
      # e.g. [{id: 1, type: 'must_view'}, {id: 2, type: 'must_view'}]
      @_requirements ||=
        begin
          if modules.empty?
            []
          else
            fm = modules.first # the visibilites are the same for all the modules - load them all now and reuse them
            user_ids = [find_user_id]
            opts = {
              :is_teacher => false,
              :assignment_visibilities => true, # fm.assignment_visibilities_for_users(user_ids),
              :discussion_visibilities => true, # fm.discussion_visibilities_for_users(user_ids),
              :page_visibilities => true, # fm.page_visibilities_for_users(user_ids),
              :quiz_visibilities => true # fm.quiz_visibilities_for_users(user_ids)
            }
            modules.flat_map { |m| m.completion_requirements_visible_to(User.find(find_user_id), opts) }.uniq
          end
        end
    end

    def to_json
      if allow_course_progress?
        {
          requirement_count: requirement_count,
          requirement_completed_count: requirement_completed_count,
          next_requirement_url: current_requirement_url,
          completed_at: completed_at
        }
      else
        { error:
            { message: 'no progress available because this course is not module based (has modules and module completion requirements) or the user is not enrolled as a student in this course' }
        }
      end
    end


    private

    def find_user_id
      @observed_user ||= observed_user
      @observed_user ? @observed_user.associated_user_id : @user.id
    end

    def observed_user
      @user.enrollments.where(type: 'ObserverEnrollment', course: course).where.not(associated_user_id: nil).first
    end

    def allow_course_progress?
      (course.module_based? && course.user_is_student?(user, include_all: true)) ||
      (course.module_based? && observed_user && course.user_is_student?(observed_user, include_all: true))
    end
  end
end
