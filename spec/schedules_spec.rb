# frozen_string_literal: true

RSpec.describe 'GET /api/schedules' do
  let(:url) { '/api/schedules' }

  before { allow(Dir).to receive(:[]).and_return(['path/to/file.json']) }

  it 'does not throw an error' do
    get url
    expect(last_response).to be_ok
  end

  it 'contains the file name only' do
    get url
    expect(last_response.body).to eq ['file'].to_json
  end

  context 'with multiple files' do
    before { allow(Dir).to receive(:[]).and_return(%w[foo.json bar.json]) }

    it 'contains both file names sorted alphabetically' do
      get url
      expect(last_response.body).to eq %w[bar foo].to_json
    end
  end
end
