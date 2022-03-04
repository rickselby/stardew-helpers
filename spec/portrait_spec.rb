# frozen_string_literal: true

RSpec.describe 'GET /portrait/:name' do
  let(:url) { "/portrait/#{name}" }

  before { allow(Dir).to receive(:[]).and_return(['path/to/file.png']) }

  context 'with an invalid file name' do
    let(:name) { 'invalid' }

    it 'throws an error with an invalid file name' do
      get url
      expect(last_response).to be_not_found
    end
  end

  context 'with a valid file name' do
    let(:name) { 'file' }

    before { allow(File).to receive(:expand_path).and_return 'spec/samples/file.txt' }

    it 'does not throw an error' do
      get url
      expect(last_response).to be_ok
    end

    it 'contains the file contents' do
      get url
      expect(last_response.body).to eq 'Foo.'
    end
  end
end
