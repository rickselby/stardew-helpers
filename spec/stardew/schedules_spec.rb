# frozen_string_literal: true

RSpec.describe Stardew::Schedules do
  subject(:schedule) { described_class.new(person) }

  before do
    pending 'Write some schedule best tests'
  end

  before { allow(File).to receive(:read).and_return({ foo: :bar }.to_json) }

  let(:day) { 1 }
  let(:person) { 'Person' }
  let(:season) { 'spring' }

  example { expect(schedule.schedule(season, day)).to eq 'foo' }
end
