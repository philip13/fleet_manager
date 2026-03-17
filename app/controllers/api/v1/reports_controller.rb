module Api
  module V1
    class ReportsController < BaseController
      require "csv"
      def maintenance_summary
        services = MaintenanceService.includes(:vehicle)
        services = filter_by_date(services) if params[:from].present? && params[:to].present?

        respond_to do |format|
          format.json do
            render json: {
              data: {
                total_orders:     total_orders(services),
                total_cost_cents: total_cost(services),
                by_status:        breakdown_by_status(services),
                by_vehicle:       breakdown_by_vehicle(services),
                top_3_vehicles:   top_3_vehicles(services)
              }
            }
          end

          format.csv do
            csv_data = generate_csv(services)
            send_data csv_data,
                      filename:    "maintenance_summary_#{Date.today}.csv",
                      type:        "text/csv",
                      disposition: "attachment"
          end
        end
      end

      private

      def total_orders(services)
        services.count
      end

      def total_cost(services)
        services.sum(:cost_cents)
      end

      def breakdown_by_status(services)
        services.group(:status).count.map do |status, count|
          {
            status:           status,
            total_orders:     count,
            total_cost_cents: services.where(status: status).sum(:cost_cents)
          }
        end
      end

      def breakdown_by_vehicle(services)
        services.group(:vehicle_id).count.map do |vehicle_id, count|
          vehicle = services.find { |s| s.vehicle_id == vehicle_id }&.vehicle
          {
            vehicle_id:       vehicle_id,
            vin:              vehicle&.vin,
            plate:            vehicle&.plate,
            total_orders:     count,
            total_cost_cents: services.select { |s| s.vehicle_id == vehicle_id }.sum(&:cost_cents)
          }
        end
      end

      def top_3_vehicles(services)
        totals = services.group(:vehicle_id)
                        .order("SUM(maintenance_services.cost_cents) DESC")
                        .limit(3)
                        .sum(:cost_cents)

        vehicle_ids = totals.keys
        vehicles    = Vehicle.where(id: vehicle_ids).index_by(&:id)
        totals.map do |vehicle_id, total|
          vehicle = vehicles[vehicle_id]
          {
            vehicle_id:       vehicle_id,
            vin:              vehicle&.vin,
            plate:            vehicle&.plate,
            total_cost_cents: total
          }
        end
      end

      def filter_by_date(services)
        from_date = Date.parse(params[:from])
        to_date   = Date.parse(params[:to])
        services.where(date: from_date.beginning_of_day..to_date.end_of_day)
      end

      def generate_csv(services)
        CSV.generate(headers: true) do |csv|
          csv << [ "Section", "Field", "Value" ]

          # Totals
          csv << [ "Totals", "Total Orders",     total_orders(services) ]
          csv << [ "Totals", "Total Cost Cents", total_cost(services) ]

          # By status
          breakdown_by_status(services).each do |row|
            csv << [ "By Status", row[:status], "Orders: #{row[:total_orders]} | Cost: #{row[:total_cost_cents]}" ]
          end

          # By vehicle
          breakdown_by_vehicle(services).each do |row|
            csv << [ "By Vehicle", "#{row[:vin]} - #{row[:plate]}", "Orders: #{row[:total_orders]} | Cost: #{row[:total_cost_cents]}" ]
          end

          # Top 3
          top_3_vehicles(services).each.with_index(1) do |row, i|
            csv << [ "Top 3", "##{i} #{row[:vin]} - #{row[:plate]}", "Total Cost: #{row[:total_cost_cents]}" ]
          end
        end
      end
    end
  end
end