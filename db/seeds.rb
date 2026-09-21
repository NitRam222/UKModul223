# Clear existing data in correct order
ActivityLog.delete_all
Loan.delete_all
Device.delete_all
User.delete_all

puts "== Seeding GearShare =="

# 1. Create Users
admin = User.create!(
  name: "Admin User",
  email: "admin@gearshare.ch",
  password: "password123",
  password_confirmation: "password123",
  role: "admin",
  active: true
)

max = User.create!(
  name: "Max Muster",
  email: "max@beispiel.ch",
  password: "password123",
  password_confirmation: "password123",
  role: "user",
  active: true
)

anna = User.create!(
  name: "Anna Beispiel",
  email: "anna@beispiel.ch",
  password: "password123",
  password_confirmation: "password123",
  role: "user",
  active: true
)

luca = User.create!(
  name: "Luca Muster",
  email: "luca@beispiel.ch",
  password: "password123",
  password_confirmation: "password123",
  role: "user",
  active: true
)

puts "✓ #{User.count} Benutzer erstellt (1 Administrator, 3 Benutzer)"

# 2. Create Devices
devices_data = [
  { name: "Laptop 01", category: "Laptop", inventory_code: "LAP-001", description: "Dell XPS 15 (Intel Core i7, 32GB RAM, 1TB SSD)", active: true },
  { name: "Laptop 02", category: "Laptop", inventory_code: "LAP-002", description: "Lenovo ThinkPad X1 Carbon (Intel Core i7, 16GB RAM)", active: true },
  { name: "Laptop 03", category: "Laptop", inventory_code: "LAP-003", description: "Dell Latitude 5530 Notebook (Intel Core i5, 16GB RAM)", active: true },
  { name: "MacBook Pro 16", category: "Laptop", inventory_code: "LAP-004", description: "Apple MacBook Pro M3 Pro, 18GB RAM, 512GB SSD", active: true },
  { name: "Kamera 01", category: "Kamera", inventory_code: "CAM-001", description: "Sony Alpha 7 IV Spiegellose Vollformatkamera mit FE 28-70mm Objektiv", active: true },
  { name: "Kamera 02", category: "Kamera", inventory_code: "CAM-002", description: "Canon EOS R6 Mark II inkl. RF 24-105mm IS STM", active: true },
  { name: "USB-C Adapter", category: "Zubehör", inventory_code: "ACC-001", description: "Multiport Adapter (USB-C zu HDMI, USB-A 3.0, Gigabit LAN, 100W PD)", active: true },
  { name: "USB-C Hub", category: "Zubehör", inventory_code: "ACC-002", description: "Anker PowerExpand 8-in-1 Hub mit Dual-HDMI & SD-Card Reader", active: true },
  { name: "HDMI Kabel 5m", category: "Zubehör", inventory_code: "ACC-003", description: "Ultra High Speed HDMI 2.1 Kabel 8K@60Hz geflochten", active: true },
  { name: "Røde Wireless GO II", category: "Audio", inventory_code: "AUD-001", description: "Zweikanaliges Funkmikrofonsystem für Videoaufnahmen und Interviews", active: true },
  { name: "iPad Pro 11", category: "Tablet", inventory_code: "TAB-001", description: "Apple iPad Pro 11\" M2 WiFi 256GB Space Grau inkl. Apple Pencil 2", active: true },
  { name: "Alte Kamera", category: "Kamera", inventory_code: "CAM-099", description: "Ältere Nikon D90 Spiegelreflexkamera (defekter Verschluss, nur Ersatzteil)", active: false }
]

devices = {}
devices_data.each do |data|
  dev = Device.create!(data)
  devices[dev.name] = dev
  ActivityLog.create!(
    user: admin,
    action: "device_create",
    record_type: "Device",
    record_id: dev.id,
    details: "Gerät '#{dev.name}' [#{dev.inventory_code}] im System erfasst.",
    created_at: 5.days.ago
  )
end

puts "✓ #{Device.count} Geräte erstellt"

# 3. Create Loans (Active & Historical)
# Active loan 1: Laptop 01 by Max Muster
loan1 = Loan.create!(
  user: max,
  device: devices["Laptop 01"],
  borrowed_at: 3.days.ago.change(hour: 10, min: 30),
  notes: "Für Kundenpräsentation"
)
ActivityLog.create!(
  user: max,
  action: "borrow",
  record_type: "Device",
  record_id: devices["Laptop 01"].id,
  details: "#{max.name} hat #{devices['Laptop 01'].name} [#{devices['Laptop 01'].inventory_code}] ausgeliehen.",
  created_at: loan1.borrowed_at
)

# Active loan 2: Laptop 02 by Anna Beispiel
loan2 = Loan.create!(
  user: anna,
  device: devices["Laptop 02"],
  borrowed_at: 2.days.ago.change(hour: 9, min: 15),
  notes: "Projektarbeit Modul 223"
)
ActivityLog.create!(
  user: anna,
  action: "borrow",
  record_type: "Device",
  record_id: devices["Laptop 02"].id,
  details: "#{anna.name} hat #{devices['Laptop 02'].name} [#{devices['Laptop 02'].inventory_code}] ausgeliehen.",
  created_at: loan2.borrowed_at
)

# Active loan 3: USB-C Adapter by Luca Muster
loan3 = Loan.create!(
  user: luca,
  device: devices["USB-C Adapter"],
  borrowed_at: 4.days.ago.change(hour: 14, min: 15),
  notes: "Homeoffice Ausstattung"
)
ActivityLog.create!(
  user: luca,
  action: "borrow",
  record_type: "Device",
  record_id: devices["USB-C Adapter"].id,
  details: "#{luca.name} hat #{devices['USB-C Adapter'].name} [#{devices['USB-C Adapter'].inventory_code}] ausgeliehen.",
  created_at: loan3.borrowed_at
)

# Past returned loans (for history)
past_loan1 = Loan.create!(
  user: max,
  device: devices["Kamera 01"],
  borrowed_at: 10.days.ago.change(hour: 8, min: 0),
  returned_at: 7.days.ago.change(hour: 17, min: 30),
  notes: "Fotoworkshop"
)
ActivityLog.create!(
  user: max,
  action: "borrow",
  record_type: "Device",
  record_id: devices["Kamera 01"].id,
  details: "#{max.name} hat #{devices['Kamera 01'].name} ausgeliehen.",
  created_at: past_loan1.borrowed_at
)
ActivityLog.create!(
  user: max,
  action: "return",
  record_type: "Device",
  record_id: devices["Kamera 01"].id,
  details: "#{max.name} hat #{devices['Kamera 01'].name} zurückgegeben.",
  created_at: past_loan1.returned_at
)

past_loan2 = Loan.create!(
  user: anna,
  device: devices["USB-C Hub"],
  borrowed_at: 8.days.ago.change(hour: 11, min: 0),
  returned_at: 5.days.ago.change(hour: 16, min: 0),
  notes: "Schulungstag"
)
ActivityLog.create!(
  user: anna,
  action: "borrow",
  record_type: "Device",
  record_id: devices["USB-C Hub"].id,
  details: "#{anna.name} hat #{devices['USB-C Hub'].name} ausgeliehen.",
  created_at: past_loan2.borrowed_at
)
ActivityLog.create!(
  user: anna,
  action: "return",
  record_type: "Device",
  record_id: devices["USB-C Hub"].id,
  details: "#{anna.name} hat #{devices['USB-C Hub'].name} zurückgegeben.",
  created_at: past_loan2.returned_at
)

puts "✓ #{Loan.count} Ausleihen angelegt (#{Loan.active.count} aktiv, #{Loan.returned.count} abgeschlossen)"
puts "✓ #{ActivityLog.count} Aktivitätsprotokoll-Einträge erstellt"
puts "== Seeding abgeschlossen! =="
