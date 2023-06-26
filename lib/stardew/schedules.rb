# frozen_string_literal: true

# Although I'd *love* to refactor this, it should match the source code as closely as possible, so let's keep rubocop
# quiet...
# rubocop:disable Metrics/ClassLength, Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
module Stardew
  # Manage the retrieval of schedules
  class Schedules
    DAYS_OF_WEEK = %w[Sun Mon Tue Wed Thu Fri Sat].freeze
    MAIL = {
      'beachBridgeFixed' => 'Beach bridge fixed',
      'ccVault' => 'Community Centre vault completed',
      'saloonSportsRoom' => 'After Alex\'s 14 heart event',
      'shanePK' => 'After Shane\'s 14 heart event'
    }.freeze

    def self.each_person(&)
      valid_people.sort.each(&)
    end

    def self.valid_people
      Dir['data/schedules/*'].map { |f| File.basename(f, '.json') }
    end

    def initialize(person)
      @schedules = JSON.parse(File.read("data/schedules/#{person}.json"))
                       .to_h { |k, v| [k.to_s, Schedule.new(person, k, v)] }
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

      remove_duplicates

      check_for_inaccessible_locations
      fix_goto(season)

      @possibilities.sort_by(&:priority)
    end

    private

    def add_possibility(schedule, notes, rain: false, increment: true, priority: nil)
      @priority += 1 if increment && priority.nil?
      @possibilities.push SchedulePossibility.new(schedule, @schedules[schedule].routes, notes,
                                                  priority: priority || @priority, rain:)
    end

    def add_regular(schedule, priority: nil)
      add_possibility schedule, 'Regular Schedule', priority:
    end

    def check_for_inaccessible_locations
      @possibilities.map do |possibility|
        possibility.routes.each do |r|
          case r.map
          when 'JojaMart', 'Railroad'
            increment_priorities possibility.priority
            if @schedules.key? "#{r.map}_Replacement"
              alt_definition = @schedules["#{r.map}_Replacement"].routes.first.definition.join ' '
              alt_routes = possibility.routes.map do |r2|
                next r2 unless r2.map == r.map

                Route.new @person, "#{r2.time} #{alt_definition}"
              end
              @possibilities.push SchedulePossibility.new("#{possibility.name}_alt", alt_routes,
                                                          "If #{r.map} is not available",
                                                          priority: possibility.priority - 1)
            else
              new_schedule = @schedules.key?('default') ? 'default' : 'spring'
              add_possibility new_schedule, "If #{r.map} is not available", priority: possibility.priority - 1
            end
            break
          when 'CommunityCenter'
            new_schedule = @schedules.key?('default') ? 'default' : 'spring'
            increment_priorities possibility.priority
            add_possibility new_schedule, 'If Community Center is not available', priority: possibility.priority - 1
            break
          end
        end
      end
    end

    def check_for_mail
      @possibilities.map do |possibility|
        next unless possibility.first_route_word? 'MAIL'

        increment_priorities possibility.priority
        add_regular possibility.mail_alt_schedule, priority: possibility.priority
        possibility.notes = MAIL[possibility.second_route_word]
        possibility.remove_routes(2)
      end
    end

    def check_for_not
      @possibilities.map do |possibility|
        next unless possibility.first_route_word? 'NOT'
        raise 'Unknown NOT syntax' unless possibility.second_route_word == 'friendship'

        increment_priorities possibility.priority + 1
        add_regular 'spring', priority: possibility.priority + 1
        possibility.notes = possibility.friendship_notes
        possibility.remove_routes(1)
      end
    end

    def check_for_unknowns
      @possibilities.each do |possibility|
        possibility.routes.each do |r|
          raise "Unknown route: #{r}" unless r.valid?
        end
      end
    end

    def day_of_week(day)
      DAYS_OF_WEEK[day.to_i % 7]
    end

    # NPC.cs getSchedule, ~line 5189
    def find_schedules(season, day)
      return add_regular "#{season}_#{day}" if @schedules.key? "#{season}_#{day}"

      (1..13).to_a.reverse_each do |hearts|
        if @schedules.key? "#{day}_#{hearts}"
          add_possibility "#{day}_#{hearts}", "At least #{hearts} hearts with #{@person}"
        end
      end

      return add_regular day.to_s if @schedules.key? day.to_s

      add_possibility 'bus', MAIL['ccVault'] if @person == 'Pam'

      add_possibility 'rain', 'If raining', rain: true if @schedules.key? 'rain'
      add_possibility 'rain2', 'If raining', rain: true, increment: false if @schedules.key? 'rain2'

      (13..1).each do |hearts|
        if @schedules.key? "#{season}_#{day_of_week(day)}_#{hearts}"
          add_possibility "#{season}_#{day_of_week(day)}_#{hearts}", "At least #{hearts} hearts with #{@person}"
        end
      end

      return add_regular "#{season}_#{day_of_week(day)}" if @schedules.key? "#{season}_#{day_of_week(day)}"
      return add_regular day_of_week(day) if @schedules.key? day_of_week(day)
      return add_regular season.to_s if @schedules.key? season.to_s
      return add_regular "spring_#{day_of_week(day)}".to_s if @schedules.key? "spring_#{day_of_week(day)}"
      return add_regular 'spring' if @schedules.key? 'spring'

      add_regular 'noschedule'
    end

    def fix_goto(season)
      @possibilities.map do |possibility|
        next unless possibility.first_route_word? 'GOTO'

        target_season = possibility.second_route_word == 'season' ? season : possibility.second_route_word
        schedule = @schedules.key?(target_season) ? target_season : 'spring'
        possibility.routes = @schedules[schedule].routes
        possibility.name = schedule
      end
    end

    def increment_priorities(priority)
      @possibilities.map { |p| p.priority += 1 if p.priority >= priority }
    end

    def parse_schedule(schedule)
      schedule.split('/').map(&:split)
    end

    def remove_duplicates
      previous = nil
      @possibilities.each_with_index do |p, i|
        update_previous = true

        if previous && (previous.name == p.name)
          previous.notes = [previous.notes, p.notes].join ' / '
          @possibilities.delete_at i
          update_previous = false
        end

        previous = p if update_previous
      end
    end

    def skip_nots_after_goto
      @possibilities.each(&:skip_nots)
    end
  end
end
# rubocop:enable Metrics/ClassLength, Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
