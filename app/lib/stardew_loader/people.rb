# frozen_string_literal: true

module StardewLoader
  # Get list of people
  class People
    class << self
      def valid?(name)
        valid_people.include name
      end

      def each(&)
        valid_people.sort.each(&)
      end

      private

      def valid_people
        @valid_people ||= Stardew::Portraits.valid_portraits.intersection Schedules.valid_schedules
      end
    end
  end
end
