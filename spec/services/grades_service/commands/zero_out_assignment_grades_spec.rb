describe GradesService::Commands::ZeroOutAssignmentGrades do
  subject {described_class.new(submission)}
  let(:assignment) do
    double(
      "assignment",
      grade_student: nil,
      published?: true,
      due_at: 1.hour.ago,
      context: course
    )
  end

  let(:user) {double("user")}
  let(:grader) {double("grader")}
  let(:enrollment) {double("enrollment")}
  let(:course) {
    double(
      'course',
      includes_user?: true,
      admin_visible_student_enrollments: [enrollment]
    )
  }

  let(:submission) do
    double(
      "submission",
      id: 1,
      assignment: assignment,
      user: user,
      workflow_state: 'unsubmitted',
      score: nil,
      grade: nil,
      grader: nil
    )
  end

  before do
    allow(GradesService::Account).to receive(:account_admin).and_return(grader)
    allow(SettingsService).to receive(:update_settings)
  end

  context '#call' do
    it 'uses the correct grader' do
      expect(assignment).to receive(:grade_student).with(any_args, hash_including(grader: grader))
      subject.call!
    end

    it 'updates the score to 0' do
      expect(assignment).to receive(:grade_student).with(any_args, hash_including(score: 0))
      subject.call!
    end

    it 'logs' do
      expect(SettingsService).to receive(:update_settings)
      subject.call!
    end

    context 'notifications' do
      it 'mutes notifications'
      it 'unmutes notifications'
    end

    context 'will not grade' do
      after do
        expect(assignment).to_not receive(:grade_student)
        subject.call!
      end

      it 'when submission is submitted' do
        allow(submission).to receive(:workflow_state).and_return('submitted')
      end

      it 'when submission is graded' do
        allow(submission).to receive(:workflow_state).and_return('graded')
      end

      it 'when submission has a score' do
        allow(submission).to receive(:score).and_return(1)
      end

      it 'when submission is not late' do
        allow(submission).to receive(:grade).and_return(1)
      end

      it 'when submission is on an unpublished assignment' do
        allow(assignment).to receive(:published?).and_return(false)
      end

      it 'when student is not enrolled in the course' do
        allow(course).to receive(:includes_user?).with(
          user,
          course.admin_visible_student_enrollments
        ).and_return(false)
      end
    end

    context 'when in dry run mode' do
      let(:file) { double(:file, write: nil, close: nil) }

      before do
        allow(File).to receive(:open).and_return(file)
      end

      after do
        subject.call!(dry_run: true)
      end

      it 'will append the file' do
        expect(File).to receive(:open).with('dry_run.log', 'a')
      end

      it 'will not run the command' do
        expect(assignment).to_not receive(:grade_student).with(any_args, hash_including(score: 0))
      end

      it 'will log execution plan' do
        expect(file).to receive(:write).with("Changing submission 1 from nil to 0\n")
      end
    end
  end
end
