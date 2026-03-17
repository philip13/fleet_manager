require "faker"

puts "Cleaning database..."
MaintenanceService.destroy_all
Vehicle.destroy_all
User.destroy_all

# ── Users ────────────────────────────────────────────
puts "Creating users..."

User.create!(email: "fleet_admin@mail.com", password: "Admin123!", role: :admin)
User.create!(email: "fleet_user@mail.com",  password: "User123!",  role: :user)

# ── Vehicles ─────────────────────────────────────────
puts "Creating vehicles..."

vehicles = 5.times.map do |i|
  Vehicle.create!(
    vin:    Faker::Vehicle.vin,
    plate:  "#{Faker::Alphanumeric.alphanumeric(number: 3).upcase}-#{100 + i}",
    brand:  Faker::Vehicle.make,
    model:  Faker::Vehicle.model,
    year:   Faker::Number.between(from: 2018, to: 2023),
    status: :active
  )
end

puts "Created #{vehicles.count} vehicles"

# ── Maintenance Services ──────────────────────────────
puts "Creating maintenance services..."

maintenance_data = [
  # Vehicle 1
  {
    vehicle: vehicles[0], description: "Oil and filter change",
    status: :completed, priority: :high, cost_cents: 45000,
    date: 30.days.ago, completed_at: 29.days.ago
  },
  {
    vehicle: vehicles[0], description: "Brake pad replacement front axle",
    status: :completed, priority: :high, cost_cents: 120000,
    date: 15.days.ago, completed_at: 14.days.ago
  },
  {
    vehicle: vehicles[0], description: "Tire rotation and wheel alignment",
    status: :pending, priority: :medium, cost_cents: 35000,
    date: 2.days.ago, completed_at: nil
  },

  # Vehicle 2
  {
    vehicle: vehicles[1], description: "Full engine diagnostic scan",
    status: :completed, priority: :high, cost_cents: 80000,
    date: 45.days.ago, completed_at: 44.days.ago
  },
  {
    vehicle: vehicles[1], description: "Transmission fluid flush",
    status: :in_progress, priority: :high, cost_cents: 95000,
    date: 5.days.ago, completed_at: nil
  },
  {
    vehicle: vehicles[1], description: "Air filter and cabin filter replacement",
    status: :in_progress, priority: :low, cost_cents: 25000,
    date: 3.days.ago, completed_at: nil
  },

  # Vehicle 3
  {
    vehicle: vehicles[2], description: "Coolant system flush and refill",
    status: :completed, priority: :medium, cost_cents: 60000,
    date: 60.days.ago, completed_at: 59.days.ago
  },
  {
    vehicle: vehicles[2], description: "Spark plug replacement all cylinders",
    status: :completed, priority: :medium, cost_cents: 75000,
    date: 40.days.ago, completed_at: 39.days.ago
  },
  {
    vehicle: vehicles[2], description: "Power steering fluid top up",
    status: :completed, priority: :low, cost_cents: 15000,
    date: 20.days.ago, completed_at: 19.days.ago
  },

  # Vehicle 4
  {
    vehicle: vehicles[3], description: "Differential oil change front and rear",
    status: :completed, priority: :medium, cost_cents: 55000,
    date: 25.days.ago, completed_at: 24.days.ago
  },
  {
    vehicle: vehicles[3], description: "Suspension inspection and bushing replacement",
    status: :pending, priority: :high, cost_cents: 180000,
    date: 1.day.ago, completed_at: nil
  },

  # Vehicle 5
  {
    vehicle: vehicles[4], description: "AdBlue system service and refill",
    status: :completed, priority: :high, cost_cents: 90000,
    date: 50.days.ago, completed_at: 49.days.ago
  },
  {
    vehicle: vehicles[4], description: "Injector cleaning and fuel system service",
    status: :completed, priority: :high, cost_cents: 145000,
    date: 35.days.ago, completed_at: 34.days.ago
  },
  {
    vehicle: vehicles[4], description: "Battery load test and terminal cleaning",
    status: :pending, priority: :low, cost_cents: 20000,
    date: Date.today, completed_at: nil
  }
]

maintenance_data.each { |data| MaintenanceService.create!(data) }

puts "Created #{MaintenanceService.count} maintenance services"
puts "\nDone! Summary:"
puts "  Users:                #{User.count}"
puts "  Vehicles:             #{Vehicle.count}"
puts "  Maintenance services: #{MaintenanceService.count}"
puts "\nCredentials:"
puts "  Admin:    fleet_admin@mail.com / Admin123!"
puts "  Operator: fleet_user@mail.com  / User123!"
