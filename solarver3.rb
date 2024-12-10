require 'gosu'
require 'csv'

class SolarApp < Gosu::Window
  def initialize
    super(800, 400, false)
    self.caption = "Ứng dụng tính toán năng lượng mặt trời"

    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @energy_data = CSV.read('energy_data.csv', headers: true)
    @selected_hour = nil
  end

  def draw
    
    @font.draw_text("Chọn thời điểm:  (CASE 1 : 6h CASE 2 : 12h CASE 3 : 19h) ", 10, 10, 0, 1.0, 1.0, Gosu::Color::WHITE)
    
    (0..23).each do |hour|
      x = 10 + (hour % 12) * 60
      y = 40 + (hour / 12) * 60
      color = @selected_hour == hour ? Gosu::Color::GREEN : Gosu::Color::GREEN

      Gosu::draw_rect(x, y, 50, 50, color)
      @font.draw_text(hour.to_s, x + 18, y + 10, 0, 1.0, 1.0, Gosu::Color::BLACK)
      @font.draw_text("giờ", x + 15, y + 30, 0, 1.0, 1.0, Gosu::Color::BLACK)
    end

    
    if @selected_hour
      row = @energy_data.find { |row| row['hour'].to_i == @selected_hour }
      if row
        draw_energy_info(row, 10, 250, Gosu::Color::YELLOW) 
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

  def draw_energy_info(row, x, y, text_color)
    solar_power_generated = row['solar_power_generated'].to_f
    battery_energy = row['battery_energy'].to_f
    energy_consumption = row['energy_consumption'].to_f

    total_energy_available = solar_power_generated + battery_energy
    line_height = 25 

   
    @font.draw_text("Thời điểm: #{@selected_hour}:00", x, y, 0, 1.0, 1.0, text_color)
    @font.draw_text("Năng lượng mặt trời (kWh): #{solar_power_generated}", x, y + line_height, 0, 1.0, 1.0, text_color)
    @font.draw_text("Năng lượng pin (kWh): #{battery_energy}", x, y + 2 * line_height, 0, 1.0, 1.0, text_color)
    @font.draw_text("Điện năng tiêu thụ (kWh): #{energy_consumption}", x, y + 3 * line_height, 0, 1.0, 1.0, text_color)

    if total_energy_available < energy_consumption
      @font.draw_text("Cảnh báo: Năng lượng không đủ!", x, y + 4 * line_height, 0, 1.0, 1.0, Gosu::Color::RED)
    else
      status_color = solar_power_generated > energy_consumption ? Gosu::Color::GREEN : (solar_power_generated < energy_consumption ? Gosu::Color::YELLOW : Gosu::Color::WHITE)
      status_text = if solar_power_generated > energy_consumption
                     "Pin đang được sạc."
                   elsif solar_power_generated < energy_consumption
                     "Pin đang được xả."
                   else
                     "Pin không được sạc cũng không được xả."
                   end
      @font.draw_text(status_text, x, y + 4 * line_height, 0, 1.0, 1.0, status_color)

      if solar_power_generated != energy_consumption
        energy_difference = (solar_power_generated - energy_consumption).abs
        energy_difference_text = solar_power_generated > energy_consumption ? " : "Năng lượng lấy từ pin (kWh):"
        @font.draw_text("#{energy_difference_text} #{energy_difference}", x, y + 5 * line_height, 0, 1.0, 1.0, text_color)
      end

      @font.draw_text("Năng lượng pin còn lại (kWh): #{battery_energy}", x, y + 6 * line_height, 0, 1.0, 1.0, text_color)
    end
  end
end

SolarApp.new.show




