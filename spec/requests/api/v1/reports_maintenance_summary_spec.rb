require "rails_helper"

RSpec.describe "GET /api/v1/reports/maintenance_summary", type: :request do
  let(:user)    { create(:user) }
  let(:token)   { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { "Authorization" => "Bearer #{token}" } }

  let!(:vehicle_a) { create(:vehicle) }
  let!(:vehicle_b) { create(:vehicle) }
  let!(:vehicle_c) { create(:vehicle) }

  before do
    create_list(:maintenance_service, 3, vehicle: vehicle_a, status: :completed,
                completed_at: Time.current, cost_cents: 10000, date: 2.days.ago)
    create_list(:maintenance_service, 2, vehicle: vehicle_b, status: :pending,
                cost_cents: 5000, date: 1.day.ago)
    create(:maintenance_service, vehicle: vehicle_c, status: :in_progress,
           cost_cents: 20000, date: Date.today)
  end

  describe "authorization" do
    it "returns 401 without token" do
      get "/api/v1/reports/maintenance_summary", as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "response structure" do
    before { get "/api/v1/reports/maintenance_summary", headers: headers, as: :json }

    it "returns 200" do
      expect(response).to have_http_status(:ok)
    end

    it "returns data key" do
      expect(json_response).to have_key(:data)
    end

    it "data contains expected keys" do
      expect(json_response[:data].keys).to include(
        :total_orders, :total_cost_cents, :by_status, :by_vehicle, :top_3_vehicles
      )
    end
  end

  describe "totals" do
    before { get "/api/v1/reports/maintenance_summary", headers: headers, as: :json }

    it "returns correct total orders" do
      expect(json_response[:data][:total_orders]).to eq(6)
    end

    it "returns correct total cost" do
      expected = (3 * 10000) + (2 * 5000) + 20000
      expect(json_response[:data][:total_cost_cents]).to eq(expected)
    end
  end

  describe "breakdown by status" do
    before { get "/api/v1/reports/maintenance_summary", headers: headers, as: :json }

    it "includes all statuses present" do
      statuses = json_response[:data][:by_status].map { |s| s[:status] }
      expect(statuses).to include("completed", "pending", "in_progress")
    end

    it "returns correct count per status" do
      completed = json_response[:data][:by_status].find { |s| s[:status] == "completed" }
      expect(completed[:total_orders]).to eq(3)
    end

    it "returns correct cost per status" do
      pending = json_response[:data][:by_status].find { |s| s[:status] == "pending" }
      expect(pending[:total_cost_cents]).to eq(10000)
    end
  end

  describe "breakdown by vehicle" do
    before { get "/api/v1/reports/maintenance_summary", headers: headers, as: :json }

    it "includes all vehicles" do
      vehicle_ids = json_response[:data][:by_vehicle].map { |v| v[:vehicle_id] }
      expect(vehicle_ids).to include(vehicle_a.id, vehicle_b.id, vehicle_c.id)
    end

    it "returns correct count per vehicle" do
      entry = json_response[:data][:by_vehicle].find { |v| v[:vehicle_id] == vehicle_a.id }
      expect(entry[:total_orders]).to eq(3)
    end
  end

  describe "top 3 vehicles" do
    before { get "/api/v1/reports/maintenance_summary", headers: headers, as: :json }

    it "returns 3 vehicles" do
      expect(json_response[:data][:top_3_vehicles].length).to eq(3)
    end

    it "first vehicle has highest cost" do
      top = json_response[:data][:top_3_vehicles].first
      expect(top[:vehicle_id]).to eq(vehicle_a.id)
    end

    it "includes vin and plate" do
      top = json_response[:data][:top_3_vehicles].first
      expect(top.keys).to include(:vehicle_id, :vin, :plate, :total_cost_cents)
    end
  end

  describe "date filters" do
    it "filters by from and to" do
      get "/api/v1/reports/maintenance_summary",
          params: { from: 4.days.ago.to_date, to: 2.day.ago.to_date },
          headers: headers, as: :json
      expect(json_response[:data][:total_orders]).to eq(3)
    end

    it "returns all when no filters applied" do
      get "/api/v1/reports/maintenance_summary", headers: headers, as: :json
      expect(json_response[:data][:total_orders]).to eq(6)
    end
  end

  describe "CSV export" do
    it "returns csv content type" do
      get "/api/v1/reports/maintenance_summary.csv", headers: headers
      expect(response.content_type).to include("text/csv")
    end

    it "returns 200" do
      get "/api/v1/reports/maintenance_summary.csv", headers: headers
      expect(response).to have_http_status(:ok)
    end

    it "includes headers row" do
      get "/api/v1/reports/maintenance_summary.csv", headers: headers
      expect(response.body).to include("Section,Field,Value")
    end

    it "includes totals in csv" do
      get "/api/v1/reports/maintenance_summary.csv", headers: headers
      expect(response.body).to include("Totals")
      expect(response.body).to include("Total Orders")
    end

    it "includes vehicle data in csv" do
      get "/api/v1/reports/maintenance_summary.csv", headers: headers
      expect(response.body).to include(vehicle_a.vin)
    end

    it "csv respects date filters" do
      get "/api/v1/reports/maintenance_summary.csv",
          params: { from: 4.days.ago.to_date, to: 2.days.ago.to_date },
          headers: headers
      expect(response.body).to include("3")
    end
  end
end
