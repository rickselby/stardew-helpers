# frozen_string_literal: true

RSpec.describe Stardew::Schedules do
  subject { described_class.new(person) }

  before { allow(JSON).to receive(:load).and_return({ foo: :bar }) }

  let(:day) { 1 }
  let(:person) { 'Person' }
  let(:season) { 'spring' }

  example { expect(subject.foo).to eq 'foo' }
end
