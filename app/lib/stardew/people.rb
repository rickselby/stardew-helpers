class Stardew
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
        @valid_people ||= Stardew::Portraits.valid_portraits.intersection Stardew::Schedules.valid_schedules
      end
    end
  end
end
