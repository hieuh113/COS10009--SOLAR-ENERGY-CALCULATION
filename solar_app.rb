require 'green_shoes'
require 'csv'

# Đọc dữ liệu năng lượng từ tệp CSV
energy_data = CSV.read('energy_data.csv', headers: true)

Shoes.app(title: "Ứng dụng tính toán năng lượng mặt trời", width: 400, height: 300) do
  background "#EEE"
  
  stack(margin: 20) do
    title "Chọn thời điểm:", align: "center"
    flow do
      (0..23).each do |hour|
        button hour.to_s, width: 35, height: 35 do
          row = energy_data.find { |row| row['hour'].to_i == hour }
          if row
            solar_power_generated = row['solar_power_generated'].to_f
            battery_energy = row['battery_energy'].to_f
            energy_consumption = row['energy_consumption'].to_f

            total_energy_available = solar_power_generated + battery_energy

            stack do
              para "Thời điểm: #{hour}:00", align: "center"
              para "Năng lượng mặt trời (kWh): #{solar_power_generated}", align: "center"
              para "Năng lượng pin (kWh): #{battery_energy}", align: "center"
              para "Điện năng tiêu thụ (kWh): #{energy_consumption}", align: "center"
              para "---", align: "center"

              if total_energy_available < energy_consumption
                para strong("Cảnh báo: Năng lượng không đủ!"), align: "center"
                para "Vui lòng giảm tải để tránh hư hại thiết bị.", align: "center"
              else
                if solar_power_generated > energy_consumption
                  excess_energy = solar_power_generated - energy_consumption
                  battery_energy += excess_energy
                  para "Pin đang được sạc.", align: "center"
                  para "Năng lượng dư thừa (kWh): #{excess_energy}", align: "center"
                  para "Năng lượng pin sau khi sạc (kWh): #{battery_energy}", align: "center"
                else
                  battery_energy -= (energy_consumption - solar_power_generated)
                  para "Năng lượng đang được sử dụng từ cả năng lượng mặt trời và pin.", align: "center"
                  para "Năng lượng pin sau khi sử dụng (kWh): #{battery_energy}", align: "center"
                end
              end
            end
          else
            alert "Không tìm thấy dữ liệu cho thời điểm này."
          end
        end
      end
    end
  end
end

