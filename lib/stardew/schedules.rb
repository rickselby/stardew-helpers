# frozen_string_literal: true

module Stardew
  # Manage the retrieval of schedules
  class Schedules
    def initialize(person)
      @schedules = JSON::load(File.new("data/schedules/#{person}.json"))
                     .to_h { |k, v| [k.to_s, Schedule.new(k, v)] }
      @person = person
    end

    def check(season, day)
      schedule(season, day)
      check_for_unknowns
    end

    def schedule(season, day)
      @possibilities = []
      @priority = 0
      find_schedules(season, day)
      fix_goto(season)
      check_for_not
      check_for_mail
      fix_goto(season)
      skip_nots_after_goto

      check_for_inaccessible_locations

      @possibilities.sort_by(&:priority)
    end

    DAYS_OF_WEEK = %w[Sun Mon Tue Wed Thu Fri Sat].freeze
    MAIL = {
      'beachBridgeFixed' => 'Beach bridge fixed',
      'ccVault' => 'Community Centre vault completed',
      'saloonSportsRoom' => 'After Alex\'s 14 heart event',
      'shanePK' => 'After Shane\'s 14 heart event'
    }.freeze

    private

    def add_possibility(schedule, notes, rain = false, increment: true, priority: nil)
      @priority += 1 if increment && priority.nil?
      @possibilities.push SchedulePossibility.new(@schedules[schedule].routes, notes, priority: priority || @priority, rain: rain)
    end

    def add_regular(schedule, priority: nil)
      add_possibility schedule, 'Regular Schedule', priority: priority
    end

    def check_for_inaccessible_locations
      @possibilities.map do |possibility|
        possibility.routes.each do |r|
          # case r.definition[1]
          # when 'JojaMart', 'Railroad'
          #   if @schedules.key? "#{r.definition[1]}_Replacement"
          #     # TODO: create an alternative
          #     [r.definition[0]].concat(@schedules["#{r.definition[1]}_Replacement"].routes)
          #     new_schedule = 'sth'
          #   else
          #     new_schedule = @schedules.key?('default') ? 'default' : 'spring'
          #   end
          #   increment_priorities possibility.priority
          #   add_possibility new_schedule, "If #{r.definition[1]} is not available", priority: possibility.priority
          # when 'CommunityCenter'
          #   new_schedule = @schedules.key?('default') ? 'default' : 'spring'
          #   increment_priorities possibility.priority
          #   add_possibility new_schedule, "If Community Center is not available", priority: possibility.priority
          # end
        end
      end
    end

    def check_for_mail
      @possibilities.map do |possibility|
        if possibility.mail?
          increment_priorities possibility.priority
          add_regular possibility.mail_alt_schedule, priority: possibility.priority
          possibility.notes = MAIL[possibility.mail]
          possibility.remove_routes(2)
        end
      end
    end

    def check_for_not
      @possibilities.map do |possibility|
        if possibility.not?
          raise 'Unknown NOT syntax' unless possibility.not == 'friendship'

          increment_priorities possibility.priority + 1
          add_regular 'spring', priority: possibility.priority + 1
          possibility.notes = possibility.not_notes
          possibility.remove_routes(1)
        end
      end
    end

    def check_for_unknowns
      @possibilities.each do |possibility|
        possibility.routes.each do |r|
          raise "Unknown value: #{r.definition[0]}" unless r.definition[0] =~ /^a?\d+$/
        end
      end
    end

    def day_of_week(day)
      DAYS_OF_WEEK[day.to_i % 7]
    end

    def find_schedules(season, day)
      return add_regular "#{season}_#{day}" if @schedules.key? "#{season}_#{day}"

      (13..1).each do |hearts|
        if @schedules.key? "#{day}_#{hearts}"
          add_possibility "#{day}_#{hearts}", "At least #{hearts} hearts with #{@person}"
        end
      end

      return add_regular day if @schedules.key? day

      add_possibility 'bus', MAIL['ccVault'] if @person == 'Pam'

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
      @possibilities.map do |possibility|
        if possibility.goto?
          season = possibility.goto == 'season' ? season : possibility.goto
          schedule = @schedules.key?(season) ? season : 'spring'
          possibility.routes = @schedules[schedule].routes
        end
      end
    end

    def increment_priorities(priority)
      @possibilities.map { |p| p.priority += 1 if p.priority >= priority }
    end

    def parse_schedule(schedule)
      schedule.split('/').map { |s| s.split ' ' }
    end

    def skip_nots_after_goto
      @possibilities.each(&:skip_nots)
    end
  end
end
