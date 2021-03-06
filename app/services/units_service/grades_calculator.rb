module UnitsService
  class GradesCalculator
    def initialize unit_submissions, course
      @unit_submissions = unit_submissions
      @course = course
    end

    def call
      result = {}

      @unit_submissions.each do |unit, submissions|
        next if submissions.count == 0
        result[unit] = weighted_average(submissions)
      end

      result
    end

    private

    def weighted_average(submissions)
      category_weights = submissions.map do |submission| submission.assignment.assignment_group end.map { |ag| [ag.name, ag.group_weight] }.to_h

      result = {}
      submissions.group_by do |submission|
        submission.assignment.assignment_group
      end.each do |group, submissions|
        result[group.name] = [] unless result[group]
        average = submissions.map(&:score).compact.sum.to_f / submissions.count
        weight  = category_weights[group.name] / zero_guard_weights(category_weights.values.sum)
        result[group.name] << zero_guard_average_weight(average, weight)
      end

      result.sum { |r, weighted| weighted.sum }
    end

    def zero_guard_weights(n)
      n.zero? ? 1 : n
    end

    def zero_guard_average_weight(average, weight)
      average * weight == 0 ? average : average * weight
    end
  end
end
