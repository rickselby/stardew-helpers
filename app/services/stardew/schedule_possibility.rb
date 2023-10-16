# frozen_string_literal: true

module Stardew
  # A single schedule
  class SchedulePossibility
    attr_accessor :name, :notes, :priority, :steps

    def initialize(name, steps, notes, priority:, rain: false)
      @name = name.dup
      @notes = notes.dup
      @priority = priority.dup
      @rain = rain.dup
      @steps = steps.dup
    end

    def first_step_word?(test)
      @steps.first.definition[0] == test
    end

    def second_step_word
      @steps.first.definition[1]
    end

    def friendship_notes
      notes = "Not at #{@steps.first.definition[3]} hearts with #{@steps.first.definition[2]}"
      if @steps.first.definition.length == 6
        notes = "#{notes} or #{@steps.first.definition[5]} hearts with #{@steps.first.definition[4]}"
      end
      notes
    end

    def mail_alt_schedule
      @steps[1].definition[1]
    end

    def remove_steps(amount)
      @steps.shift(amount)
    end

    def skip_nots
      remove_steps(1) if first_step_word? 'NOT'
    end

    def rain?
      @rain
    end
  end
end
