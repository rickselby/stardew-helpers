# frozen_string_literal: true

module Stardew
  # Manage the retrieval of schedules
  class Schedules
    def initialize(person)
      @schedules = JSON::load(File.new("data/schedules/#{person}.json"))
                     .transform_keys(&:to_s)
                     .transform_values(&method(:parse_schedule))
      @person = person
    end

    def schedule(season, day)
      @possibilities = []
      @priority = 0
      find_schedules(season, day)
      fix_goto(season)
      check_for_not
      fix_goto(season)
      skip_nots_after_goto

      check_for_unknowns
    end

    DAYS_OF_WEEK = %w[Sun Mon Tue Wed Thu Fri Sat].freeze

    private

    def add_possibility(schedule, notes, rain = false, increment: true, priority: nil)
      @priority += 1 if increment && priority.nil?
      @possibilities.push({ schedule: schedule, notes: notes, rain: rain, priority: priority || @priority })
    end

    def add_regular(schedule, priority: nil)
      add_possibility schedule, 'Regular Schedule'
    end

    def check_for_not
      @possibilities.map do |p|
        schedule = @schedules[p[:schedule]][0]
        if schedule[0] == 'NOT'
          raise 'Unknown NOT syntax' if schedule[1] != 'friendship'

          increment_priorities p[:priority] + 1
          add_regular 'spring', priority: p[:priority] + 1
          p[:notes] = "Not at #{schedule[3]} hearts with #{schedule[2]}"
          p[:notes] = "#{p[:notes]} or #{schedule[5]} hearts with #{schedule[4]}" if schedule.length == 6
          @schedules[p[:schedule]].shift
        end
      end
    end

    def check_for_unknowns
      @possibilities.each do |p|
        @schedules[p[:schedule]].each do |s|
          raise "Unknown value: #{s[0]}" unless s[0] =~ /^\d+$/
        end
      end
    end

    def day_of_week(day)
      DAYS_OF_WEEK[day % 7]
    end

    def find_schedules(season, day)
      return add_regular "#{season}_#{day}" if @schedules.key? "#{season}_#{day}"

      (13..1).each do |hearts|
        if @schedules.key? "#{day}_#{hearts}"
          add_possibility "#{day}_#{hearts}", "At least #{hearts} hearts with #{@person}"
        end
      end

      return add_regular day if @schedules.key? day

      add_possibility 'bus', 'If the bus is repaired' if @person == 'Pam'

      add_possibility 'rain', 'If raining', true if @schedules.key? 'rain'
      add_possibility 'rain2', 'If raining', true, increment: false if @schedules.key? 'rain2'

      (13..1).each do |hearts|
        if @schedules.key? "#{season}_#{day_of_week(day)}_#{hearts}"
          add_possibility "#{season}_#{day_of_week(day)}_#{hearts}", "At least #{hearts} hearts with #{@person}"
        end
      end

      return add_regular "#{season}_#{day_of_week(day)}" if @schedules.key? "#{season}_#{day_of_week(day)}"
      return add_regular "#{day_of_week(day)}" if @schedules.key? "#{day_of_week(day)}"
      return add_regular "#{season}" if @schedules.key? "#{season}"
      return add_regular "spring" if @schedules.key? "spring"

      add_regular 'noschedule'
    end

    def fix_goto(season)
      @possibilities.map do |p|
        schedule = @schedules[p[:schedule]][0]
        if schedule[0] == 'GOTO'
          season = schedule[0] == 'season' ? season : schedule[0]
          p[:schedule] = @schedules.key?(season) ? season : 'spring'
        end
      end
    end

    def increment_priorities(priority)
      @possibilities.map { |p| p[:priority] += 1 if p[:priority] >= priority }
    end

    def parse_schedule(schedule)
      schedule.split('/').map { |s| s.split ' ' }
    end

    def skip_nots_after_goto
      @possibilities.each do |p|
        schedule = @schedules[p[:schedule]][0]
        if schedule[0] == 'NOT'
          @schedules[p[:schedule]].shift
        end
      end
    end
  end
end
