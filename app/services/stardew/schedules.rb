# Although I'd *love* to refactor this, it should match the source code as closely as possible
module Stardew
  # Manage the retrieval of schedules
  class Schedules
    DIR = Rails.root.join 'data', 'schedules'
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
      @valid_people ||= Dir[DIR.join("*")].map { |f| File.basename f, '.json' }
    end

    def self.file_path_for(person)
      DIR.join "#{person}.json"
    end

    def initialize(person)
      @schedules = JSON.parse(File.read(self.class.file_path_for(person)))
                       .to_h { |k, v| [k.to_s, BareSchedule.new(person, k, v)] }
      @person = person
    end

    def check(season, day)
      schedule season, day
      check_for_unknowns
    end

    def group_schedules(season, day)
      Rails.cache.fetch "#{@person}-#{season}-#{day}" do
        Stardew::ScheduleGroup.group schedule season, day
      end
    end

    private

    def schedule(season, day)
      @possibilities = []
      @priority = 0
      find_schedules season, day
      fix_goto season
      check_for_not
      check_for_mail
      fix_goto season
      skip_nots_after_goto

      remove_duplicates

      check_for_inaccessible_locations
      fix_goto season

      @possibilities.sort_by(&:priority)
    end

    def add_possibility(schedule, notes, rain: false, increment: true, priority: nil)
      @priority += 1 if increment && priority.nil?
      @possibilities.push Schedule.new schedule, @schedules[schedule].steps, notes,
                                       priority: priority || @priority, rain:
    end

    def add_regular(schedule, priority: nil)
      add_possibility schedule, 'Regular Schedule', priority:
    end

    def check_for_inaccessible_locations
      @possibilities.map do |possibility|
        possibility.steps.each do |r|
          case r.map
          when 'JojaMart', 'Railroad'
            increment_priorities possibility.priority
            if @schedules.key? "#{r.map}_Replacement"
              alt_definition = @schedules["#{r.map}_Replacement"].steps.first.definition.join ' '
              alt_steps = possibility.steps.map do |r2|
                next r2 unless r2.map == r.map

                Step.new @person, "#{r2.time} #{alt_definition}"
              end
              @possibilities.push Schedule.new "#{possibility.name}_alt", alt_steps,
                                               "If #{r.map} is not available",
                                               priority: possibility.priority - 1
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
        next unless possibility.first_step_word? 'MAIL'

        increment_priorities possibility.priority
        add_regular possibility.mail_alt_schedule, priority: possibility.priority
        possibility.notes = MAIL[possibility.second_step_word]
        possibility.remove_steps 2
      end
    end

    def check_for_not
      @possibilities.map do |possibility|
        next unless possibility.first_step_word? 'NOT'
        raise 'Unknown NOT syntax' unless possibility.second_step_word == 'friendship'

        increment_priorities possibility.priority + 1
        add_regular 'spring', priority: possibility.priority + 1
        possibility.notes = possibility.friendship_notes
        possibility.remove_steps 1
      end
    end

    def check_for_unknowns
      @possibilities.each do |possibility|
        possibility.steps.each do |step|
          raise "Unknown step: #{step}" unless step.valid?
        end
      end
    end

    def day_of_week(day)
      DAYS_OF_WEEK[day.to_i % 7]
    end

    # NPC.cs getSchedule, ~line 5189
    def find_schedules(season, day)
      return add_regular "#{season}_#{day}" if @schedules.key? "#{season}_#{day}"

      (1..13).reverse_each do |hearts|
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
        next unless possibility.first_step_word? 'GOTO'

        season = possibility.second_step_word == 'season' ? season : possibility.second_step_word
        schedule = @schedules.key?(season) ? season : 'spring'
        possibility.steps = @schedules[schedule].steps
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
