require 'gosu'
require 'csv'

class SolarApp < Gosu::Window
  def initialize
    super(1000, 500, false) 
    self.caption = "Solar Energy Calculation App (CUSTOM PROGRAM HUYNH QUOC HIEU)"

    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @energy_data = CSV.read('energy_data.csv', headers: true)
    @selected_hour = nil
  end

  def draw
    @font.draw_text("Select Time:  _ TEST DEMO ( CASE 1: 3h CASE 2: 4h CASE 3: 9h CASE 4: 12h)", 10, 10, 0, 1.0, 1.0, Gosu::Color::WHITE)
    (0..23).each do |hour|
      x = 10 + (hour % 12) * 60 
      y = 40 + (hour / 12) * 60
      color = @selected_hour == hour ? Gosu::Color::WHITE : Gosu::Color::YELLOW

      Gosu::draw_rect(x, y, 50, 50, color)
      @font.draw_text(hour.to_s, x + 18, y + 10, 0, 1.0, 1.0, Gosu::Color::RED)
      @font.draw_text("h", x + 15, y + 30, 0, 1.0, 1.0, Gosu::Color::RED) 
    end

    
    if @selected_hour
      row = @energy_data.find { |row| row['hour'].to_i == @selected_hour }
      if row
        draw_energy_info(row, 10, 250)
      end
    end
  end

  def button_down(id)
    if id == Gosu::MsLeft
      (0..23).each do |hour|
        x = 10 + (hour % 12) * 60
        y = 40 + (hour / 12) * 60
        if mouse_x.between?(x, x + 50) && mouse_y.between?(y, y + 50)
          @selected_hour = hour
        end
      end
    end
  end

  def draw_energy_info(row, x, y, text_color = Gosu::Color::GREEN) 
    solar_power_generated = row['solar_power_generated'].to_f
    battery_energy = row['battery_energy'].to_f
    energy_consumption = row['energy_consumption'].to_f

    total_energy_available = solar_power_generated + battery_energy
    line_height = 25 

    @font.draw_text("Time: #{@selected_hour}:00", x, y - 3 * line_height, 0, 2.0, 2.0, Gosu::Color::WHITE)
    @font.draw_text("Solar Power Generated (kWh): #{solar_power_generated}", x, y, 0, 2.5, 2.5, Gosu::Color::AQUA)
    @font.draw_text("Energy Consumption (kWh): #{energy_consumption}", x, y + 5 * line_height, 0, 1.0, 1.0, text_color)

    if total_energy_available < energy_consumption
      @font.draw_text("Warning: Insufficient energy!", x, y + 2 * line_height, 0, 1.6, 1.6, Gosu::Color::RED)
      @font.draw_text("AUTOMATIC DISCONECT POWER ON ", x, y + 4 * line_height, 0, 1.2, 1.2, Gosu::Color::RED)
    else
      status_color = solar_power_generated > energy_consumption ? Gosu::Color::FUCHSIA : (solar_power_generated < energy_consumption ? Gosu::Color::FUCHSIA : Gosu::Color::FUCHSIA)
      status_text = if solar_power_generated > energy_consumption
                     "ENERGY USED FROM SOLAR (BATTERY CHARGE ON)"
                   elsif solar_power_generated < energy_consumption
                     "ENERGY USED FROM BATTERY+SOLAR (BATTERY CHARGE OFF)"
                   else
                     "ENERGY USED FROM SOLAR (BATTERY CHARGE OFF)"
                   end
      @font.draw_text(status_text, x, y + 3 * line_height, 0, 1.5, 1.5, status_color)

      if solar_power_generated != energy_consumption
        energy_difference = (solar_power_generated - energy_consumption).abs
        energy_difference_text = solar_power_generated > energy_consumption ? "Energy charging for battery (kWh):" : "Energy from Battery (kWh):"
        @font.draw_text("#{energy_difference_text} #{energy_difference}", x, y + 6 * line_height, 0, 1.0, 1.0, text_color)
      end

      @font.draw_text("Remaining Battery Energy (kWh): #{battery_energy}", x, y + 7 * line_height, 0, 1.0, 1.0, text_color)
    end
  end
end

SolarApp.new.show
