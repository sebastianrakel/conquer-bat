require "conquer/bat/version"

module Conquer
  module Bat
    class BatteryInfo
      attr_reader :name, :percentage, :time_remaining, :number
      
      def initialize(battery_path)
        energy_now = File.read(File.join(battery_path, '/energy_now')).to_f / 1_000_000
        energy_full = File.read(File.join(battery_path, '/energy_full')).to_f / 1_000_000
        power_now = File.read(File.join(battery_path, '/power_now')).to_f / 1_000_000

        @name = File.basename(battery_path)
        @number = @name[3..-1]
        @percentage = (100 * energy_now) / energy_full
        @time_remaining = calculate_remaining_time(energy_now, power_now)
      end

      def calculate_remaining_time(energy_now, power_now)
        return 'N/A' unless power_now.nonzero?

        minutes = (60 * energy_now) / power_now.round
        hours = minutes / 60
        format('%d:%02d', hours, minutes - hours * 60)
      end
    end
  end

  module Helpers
    module_function

    def battery_infos
      power_path = '/sys/class/power_supply/'
      Dir[File.join(power_path, 'BAT?')].map(&Bat::BatteryInfo.method(:new))
    end
  end
end
