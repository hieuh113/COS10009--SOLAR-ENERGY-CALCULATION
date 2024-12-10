require 'csv'

def main
  # Đọc dữ liệu năng lượng từ tệp CSV
  energy_data = CSV.read('energy_data.csv', headers: true)

  loop do
    puts "Nhập thời điểm bạn muốn tính toán (0-23) hoặc 'thoát' để kết thúc:"
    input = gets.chomp

    break if input.downcase == 'thoát'

    hour = input.to_i
    if hour >= 0 && hour <= 23
      row = energy_data.find { |row| row['hour'].to_i == hour }

      if row
        # Lấy dữ liệu từ tệp CSV
        solar_power_generated = row['solar_power_generated'].to_f
        battery_energy = row['battery_energy'].to_f
        energy_consumption = row['energy_consumption'].to_f

        # Tính toán năng lượng khả dụng
        total_energy_available = solar_power_generated + battery_energy

        # Kiểm tra và hiển thị kết quả
        if total_energy_available < energy_consumption
          puts "Cảnh báo: Năng lượng không đủ. Vui lòng giảm tải để tránh hư hại thiết bị."
        else
          if solar_power_generated > energy_consumption
            puts "Pin đang được sạc. Năng lượng đang được sử dụng từ năng lượng mặt trời."
            excess_energy = solar_power_generated - energy_consumption
            battery_energy += excess_energy # Năng lượng dư được sạc vào pin
            puts "Năng lượng dư thừa (kWh): #{excess_energy}"
            puts "Năng lượng pin sau khi sạc (kWh): #{battery_energy}"
          else
            puts "Năng lượng đang được sử dụng từ cả năng lượng mặt trời và pin."
            battery_energy -= (energy_consumption - solar_power_generated) # Năng lượng pin được sử dụng
            puts "Năng lượng pin sau khi sử dụng (kWh): #{battery_energy}"
          end
        end
      else
        puts "Không tìm thấy dữ liệu cho thời điểm này."
      end
    else
      puts "Thời điểm không hợp lệ. Vui lòng nhập số từ 0 đến 23."
    end
  end
end

main
