require 'gosu'
require 'csv'

class SolarApp < Gosu::Window
  def initialize
    super(400, 300, false)
    self.caption = "Ứng dụng tính toán năng lượng mặt trời"

    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @energy_data = CSV.read('energy_data.csv', headers: true)
    @selected_hour = nil
  end

  def draw
    @font.draw_text("Chọn thời điểm:", 10, 10, 0, 1.0, 1.0, Gosu::Color::BLACK)

    (0..23).each do |hour|
      x = 10 + (hour % 12) * 30
      y = 40 + (hour / 12) * 40
      color = @selected_hour == hour ? Gosu::Color::GREEN : Gosu::Color::GRAY

      Gosu::draw_rect(x, y, 25, 25, color)
      @font.draw_text(hour.to_s, x + 8, y + 5, 0, 1.0, 1.0, Gosu::Color::BLACK)
    end

    if @selected_hour
      row = @energy_data.find { |row| row['hour'].to_i == @selected_hour }
      if row
        draw_energy_info(row, 10, 150)
      end
    end
  end

  def button_down(id)
    if id == Gosu::MsLeft
      (0..23).each do |hour|
        x = 10 + (hour % 12) * 30
        y = 40 + (hour / 12) * 40
        if mouse_x.between?(x, x + 25) && mouse_y.between?(y, y + 25)
          @selected_hour = hour
        end
      end
    end
  end

  def draw_energy_info(row, x, y)
    solar_power_generated = row['solar_power_generated'].to_f
    battery_energy = row['battery_energy'].to_f
    energy_consumption = row['energy_consumption'].to_f

    total_energy_available = solar_power_generated + battery_energy

    @font.draw_text("Thời điểm: #{@selected_hour}:00", x, y, 0, 1.0, 1.0, Gosu::Color::BLACK)
    @font.draw_text("Năng lượng mặt trời (kWh): #{solar_power_generated}", x, y + 25, 0, 1.0, 1.0, Gosu::Color::BLACK)
    @font.draw_text("Năng lượng pin (kWh): #{battery_energy}", x, y + 50, 0, 1.0, 1.0, Gosu::Color::BLACK)
    @font.draw_text("Điện năng tiêu thụ (kWh): #{energy_consumption}", x, y + 75, 0, 1.0, 1.0, Gosu::Color::BLACK)

    if total_energy_available < energy_consumption
      @font.draw_text("Cảnh báo: Năng lượng không đủ!", x, y + 100, 0, 1.0, 1.0, Gosu::Color::RED)
    else
      if solar_power_generated > energy_consumption
        excess_energy = solar_power_generated - energy_consumption
        battery_energy += excess_energy
        @font.draw_text("Pin đang được sạc.", x, y + 100, 0, 1.0, 1.0, Gosu::Color::GREEN)
        @font.draw_text("Năng lượng dư thừa (kWh): #{excess_energy}", x, y + 125, 0, 1.0, 1.0, Gosu::Color::BLACK)
      else
        battery_energy -= (energy_consumption - solar_power_generated)
        @font.draw_text("Năng lượng đang được sử dụng từ cả năng lượng mặt trời và pin.", x, y + 100, 0, 1.0, 1.0, Gosu::Color::BLACK)
      end
      @font.draw_text("Năng lượng pin sau khi sử dụng (kWh): #{battery_energy}", x, y + 150, 0, 1.0, 1.0, Gosu::Color::BLACK)
    end
  end
end

SolarApp.new.show
