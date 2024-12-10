require 'gosu'
require 'csv'
require 'date'

class SolarApp < Gosu::Window
  def initialize
    super(1000, 700, false)
    self.caption = "Solar Energy Calculation App"

    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @small_font = Gosu::Font.new(self, Gosu::default_font_name, 16)
    @energy_data = CSV.read('energy_data.csv', headers: true)
    @selected_hour = nil
    @history = []
    @show_settings = false
    @show_chart = false

    # System settings (default values)
    @system_capacity = 5.0 # kW
    @battery_capacity = 10.0 # kWh
  end

  def draw
    # Background
    Gosu.draw_rect(0, 0, width, height, Gosu::Color::BLACK)

    # Title
    @font.draw_text("Solar Energy Calculator", 10, 10, 0, 1.0, 1.0, Gosu::Color::BLACK)

    # Hour selection buttons
    draw_hour_buttons

    # Display energy information
    if @selected_hour
      row = @energy_data.find { |row| row['hour'].to_i == @selected_hour }
      if row
        draw_energy_info(row, 10, 200, Gosu::Color::YELLOW)
        update_history(row)
      end
    end

    # Display history
    draw_history(10, 350)

    # Settings and chart buttons
    draw_settings_button
    draw_chart_button

    # Display settings window (if enabled)
    draw_settings_window if @show_settings

    # Display chart (if enabled)
    draw_chart if @show_chart
  end

  def button_down(id)
    case id
    when Gosu::MsLeft
      handle_hour_button_click
      handle_settings_button_click
      handle_chart_button_click
    when Gosu::KB_S
      @show_settings = !@show_settings
    when Gosu::KB_C
      @show_chart = !@show_chart
    end
  end

  def draw_hour_buttons
    (0..23).each do |hour|
      x = 10 + (hour % 12) * 60 
      y = 40 + (hour / 12) * 60
      color = @selected_hour == hour ? Gosu::Color::GREEN : Gosu::Color::GRAY

      Gosu.draw_rect(x, y, 50, 50, color) 
      @font.draw_text(hour.to_s, x + 18, y + 10, 0, 1.0, 1.0, Gosu::Color::BLACK)
      @font.draw_text("h", x + 15, y + 30, 0, 1.0, 1.0, Gosu::Color::BLACK)
    end
  end

  def draw_energy_info(row, x, y, text_color)
    solar_power_generated = row['solar_power_generated'].to_f
    battery_energy = row['battery_energy'].to_f
    energy_consumption = row['energy_consumption'].to_f

    total_energy_available = solar_power_generated + battery_energy
    line_height = 25 

    @font.draw_text("Time: #{@selected_hour}:00", x, y, 0, 1.0, 1.0, text_color)
    @font.draw_text("Solar Power (kWh): #{solar_power_generated}", x, y + line_height, 0, 1.0, 1.0, text_color)
    @font.draw_text("Battery Energy (kWh): #{battery_energy}", x, y + 2 * line_height, 0, 1.0, 1.0, text_color)
    @font.draw_text("Energy Consumption (kWh): #{energy_consumption}", x, y + 3 * line_height, 0, 1.0, 1.0, text_color)

    if total_energy_available < energy_consumption
      @font.draw_text("Warning: Insufficient energy!", x, y + 4 * line_height, 0, 1.0, 1.0, Gosu::Color::RED)
    else
      status_color = solar_power_generated > energy_consumption ? Gosu::Color::GREEN : (solar_power_generated < energy_consumption ? Gosu::Color::YELLOW : Gosu::Color::WHITE)
      status_text = if solar_power_generated > energy_consumption
                     "Battery is charging."
                   elsif solar_power_generated < energy_consumption
                     "Battery is discharging."
                   else
                     "Battery is neither charging nor discharging."
                   end
      @font.draw_text(status_text, x, y + 4 * line_height, 0, 1.0, 1.0, status_color)

      if solar_power_generated != energy_consumption
        energy_difference = (solar_power_generated - energy_consumption).abs
        energy_difference_text = solar_power_generated > energy_consumption ? "Excess Energy (kWh):" : "Energy from Battery (kWh):"
        @font.draw_text("#{energy_difference_text} #{energy_difference}", x, y + 5 * line_height, 0, 1.0, 1.0, text_color)
      end

      @font.draw_text("Remaining Battery Energy (kWh): #{battery_energy}", x, y + 6 * line_height, 0, 1.0, 1.0, text_color)
    end
  end

  def update_history(row)
    @history << {
      time: DateTime.now.strftime("%Y-%m-%d %H:%M"),
      solar_power: row['solar_power_generated'].to_f,
      battery_energy: row['battery_energy'].to_f,
      energy_consumption: row['energy_consumption'].to_f
    }
    @history = @history.last(5) 
  end

  def draw_history(x, y)

    @font.draw_text("History (Last 5 Entries):", x, y, 2, 1.0, 1.0, Gosu::Color::RED)
    @history.each_with_index do |entry, index|
      @font.draw_text("#{entry[:time]} - Solar: #{entry[:solar_power]} kWh, Battery: #{entry[:battery_energy]} kWh, Consumption: #{entry[:energy_consumption]} kWh", 
                      x, y + 2 * (index + 1), 2, 1.0, 1.0, Gosu::Color::RED)
    end
  end

  def draw_settings_button
    if @show_settings
      Gosu.draw_rect(width - 110, 10, 100, 30, Gosu::Color::GRAY)
      @font.draw_text("Close Settings", width - 100, 15, 0, 1.0, 1.0, Gosu::Color::RED)
    else
      Gosu.draw_rect(width - 110, 10, 100, 30, Gosu::Color::BLUE)
      @font.draw_text("Settings", width - 90, 15, 0, 1.0, 1.0, Gosu::Color::RED)
    end
  end

  def draw_chart_button
    if @show_chart
      Gosu.draw_rect(width - 230, 10, 100, 30, Gosu::Color::GRAY)
      @font.draw_text("Close Chart", width - 220, 15, 0, 1.0, 1.0, Gosu::Color::WHITE)
    else
      Gosu.draw_rect(width - 230, 10, 100, 30, Gosu::Color::BLUE)
      @font.draw_text("Chart", width - 210, 15, 0, 1.0, 1.0, Gosu::Color::WHITE)
    end
  end

  def draw_settings_window
    Gosu.draw_rect(150, 100, 500, 300, Gosu::Color::GRAY)
    @font.draw_text("Settings Window (Under Construction)", 200, 200, 0, 1.0, 1.0, Gosu::Color::WHITE)
  end

  def draw_chart
    Gosu.draw_rect(150, 100, 500, 300, Gosu::Color::GRAY)
    @font.draw_text("Chart Window (Under Construction)", 200, 200, 0, 1.0, 1.0, Gosu::Color::WHITE)
  end

  def handle_hour_button_click
    (0..23).each do |hour|
      x = 10 + (hour % 12) * 60
      y = 40 + (hour / 12) * 60

      if mouse_x > x && mouse_x < x + 50 && mouse_y > y && mouse_y < y + 50
        @selected_hour = hour
      end
    end
  end

  def handle_settings_button_click
    if mouse_x > width - 110 && mouse_x < width - 10 && mouse_y > 10 && mouse_y < 40
      @show_settings = !@show_settings
    end
  end

  def handle_chart_button_click
    if mouse_x > width - 230 && mouse_x < width - 130 && mouse_y > 10 && mouse_y < 40
      @show_chart = !@show_chart
    end
  end
end

SolarApp.new.show
