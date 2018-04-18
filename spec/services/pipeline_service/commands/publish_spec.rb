describe PipelineService::Commands::Publish do
  let(:object)                { Enrollment.new }
  let(:user)                  { double('user') }
  let(:test_message)          { double('message') }
  let(:client_instance)       { double('pipeline_client', call: double('call_result', message: test_message)) }
  let(:client_class)          { double('pipeline_client_class', new: client_instance) }
  let(:serializer_class)      { double('serializer_class', new: serializer_instance) }
  let(:serializer_instance)   { double('serializer_instance', call: nil) }

  subject do
    described_class.new(
      object:       object,
      user:         user,
      client:       client_class,
      serializer:   serializer_class
    )
  end

  describe '#call' do
    it 'sends a message to the pipeline' do
      expect(client_instance).to receive(:call)
      subject.call
    end

    context "Serializer" do
      subject do
        described_class.new(
          object:       object,
          user:         user,
          client:       client_class
        )
      end

      it 'looks up the serializer' do
        expect(subject.call.serializer).to eq PipelineService::Serializers::Enrollment
      end

      context 'blows up if the serializer cant be found' do
        let(:object) { double('unknown object') }
        it do
          expect { subject.call }.to raise_error NameError, 'Could not find the serializer for #[Double "unknown object"]'
        end
      end
    end
  end
end
