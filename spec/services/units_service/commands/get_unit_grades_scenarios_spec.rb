
describe UnitsService::Commands::GetUnitGrades do
  let(:course) { Course.create }
  let(:user) { User.create(pseudonym: Pseudonym.create) }

  before do
    allow(PipelineService).to receive(:publish)
    allow(SettingsService).to receive(:get_settings).and_return('enable_unit_grade_calculations' => true)
    seed
  end

  it 'calculates a weighted score for each unit' do
    result = described_class.new(course: course, student: user, submission: Submission.first).call

    expect(result[:units].count).to eq 6
    result[:units].each do |unit|
      expect(unit[:score]).to eq 75
    end
  end

  def seed
    6.times do |count|
      assignment_group1 = AssignmentGroup.create(name: "assignments", group_weight: 0.5)
      assignment_group2 = AssignmentGroup.create(name: "workbook", group_weight: 0.5)
      assignment1 = Assignment.create(workflow_state: 'published', assignment_group: assignment_group1)
      content_tag1 = ContentTag.create(content: assignment1)
      assignment2 = Assignment.create(workflow_state: 'published', assignment_group: assignment_group2)
      content_tag2 = ContentTag.create(content: assignment2)

      course.context_modules << ContextModule.create(
        content_tags: [content_tag1, content_tag2]
      )
      course.assignment_groups = [assignment_group1, assignment_group2]

      course.assignments << assignment1
      course.assignments << assignment2
      assignment1.submissions << Submission.create(user: user, assignment: assignment1, score: 50)
      assignment2.submissions << Submission.create(user: user, assignment: assignment2, score: 100)
    end
  end
end