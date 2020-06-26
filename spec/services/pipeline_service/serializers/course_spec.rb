describe PipelineService::Serializers::Course do
    include_context "stubbed_network"
  
    subject { described_class.new(object: noun) }
  
    let(:active_record_object) { Course.create!() }
    let(:noun) { PipelineService::Models::Noun.new(active_record_object)}

    before do
      allow(SettingsService).to receive(:get_settings).and_return({
        'passing_threshold' => 50,
        'passing_exam_threshold' => 50
      })

      allow(IdentityMapperService).to receive(:get_powerschool_course_id).and_return(254)
      allow(IdentityMapperService).to receive(:get_powerschool_school_id).and_return(452)
    end

    it 'Return an attribute hash of the noun' do
      expect(subject.call).to include({
        noun.primary_key => active_record_object.id,
        'passing_thresholds' => {
          "assignment"=>50.0,
          "exam"=>50.0
        }
      })
    end

    it 'Includes the powerschool_course_id attribute' do
      expect(subject.call).to include({
        'powerschool_course_id' => 254
      })
    end

    it 'includes the powerschool_school_id attribute' do
      expect(subject.call).to include({
        'powerschool_school_id' => 452
      })
    end
end