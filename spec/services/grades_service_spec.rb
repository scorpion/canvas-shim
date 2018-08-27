describe GradesService do
  let(:assignment) { double('assignment') }
  let(:instance) { double('command_instance', call!: nil)}
  before do
    allow(GradesService::Commands::ZeroOutAssignmentGrades)
      .to receive(:new).and_return(instance)

    allow(GradesService::Commands::ZeroOutAssignmentGrades).to receive(:new).and_return(instance)
    allow(SettingsService).to receive(:get_settings).and_return({'zero_out_past_due' => 'on'})
  end

  it 'calls the command' do
    expect(instance).to receive(:call!)
    described_class.zero_out_grades!
  end
end
