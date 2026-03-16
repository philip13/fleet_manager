require "rails_helper"

RSpec.describe "Api::V1::MaintenanceServices", type: :request do
  let(:user)     { create(:user) }
  let(:token)    { JsonWebToken.encode(user_id: user.id) }
  let(:headers)  { { "Authorization" => "Bearer #{token}" } }
  let!(:vehicle) { create(:vehicle) }

  describe "GET /api/v1/vehicles/:vehicle_id/maintenance_services" do
    describe "authorization" do
      it "returns 401 without token" do
        get "/api/v1/vehicles/#{vehicle.id}/maintenance_services", as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "with valid vehicle" do
      before { create_list(:maintenance_service, 3, vehicle: vehicle) }

      it "returns 200" do
        get "/api/v1/vehicles/#{vehicle.id}/maintenance_services",
            headers: headers, as: :json
        # binding.irb
        expect(response).to have_http_status(:ok)
      end

      it "returns data and meta structure" do
        get "/api/v1/vehicles/#{vehicle.id}/maintenance_services",
            headers: headers, as: :json
        expect(json_response).to have_key(:data)
        expect(json_response).to have_key(:meta)
      end

      it "returns only services belonging to the vehicle" do
        create_list(:maintenance_service, 2, vehicle: create(:vehicle))
        get "/api/v1/vehicles/#{vehicle.id}/maintenance_services",
            headers: headers, as: :json
        expect(json_response[:data].length).to eq(3)
      end

      it "returns expected attributes" do
        get "/api/v1/vehicles/#{vehicle.id}/maintenance_services",
            headers: headers, as: :json
        service = json_response[:data].first
        expect(service.keys).to include(:id, :vehicle_id, :description, :status, :date, :cost_cents, :priority)
      end
    end

    describe "pagination" do
      before { create_list(:maintenance_service, 15, vehicle: vehicle) }

      it "returns 10 by default" do
        get "/api/v1/vehicles/#{vehicle.id}/maintenance_services",
            headers: headers, as: :json
        expect(json_response[:data].length).to eq(10)
      end

      it "respects per_page param" do
        get "/api/v1/vehicles/#{vehicle.id}/maintenance_services",
            params: { per_page: 5 }, headers: headers, as: :json
        expect(json_response[:data].length).to eq(5)
      end

      it "includes pagination metadata" do
        get "/api/v1/vehicles/#{vehicle.id}/maintenance_services",
            headers: headers, as: :json
        meta = json_response[:meta]
        expect(meta[:total_count]).to eq(15)
        expect(meta[:total_pages]).to eq(2)
        expect(meta[:current_page]).to eq(1)
      end
    end

    describe "with invalid vehicle_id" do
      it "returns 404" do
        get "/api/v1/vehicles/99999/maintenance_services",
            headers: headers, as: :json
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /api/v1/vehicles/:vehicle_id/maintenance_services" do
    let(:valid_params) do
      {
        maintenance_service: {
          description: "Oil change",
          status:      "pending",
          priority:    "medium",
          date:        Date.today.to_s,
          cost_cents:  15000
        }
      }
    end

    describe "authorization" do
      it "returns 401 without token" do
        post "/api/v1/vehicles/#{vehicle.id}/maintenance_services",
            params: valid_params, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "with valid params" do
      it "returns 201" do
        post "/api/v1/vehicles/#{vehicle.id}/maintenance_services",
            params: valid_params, headers: headers, as: :json
        expect(response).to have_http_status(:created)
      end

      it "creates a new maintenance service" do
        expect {
          post "/api/v1/vehicles/#{vehicle.id}/maintenance_services",
              params: valid_params, headers: headers, as: :json
        }.to change(MaintenanceService, :count).by(1)
      end

      it "associates the service with the vehicle" do
        post "/api/v1/vehicles/#{vehicle.id}/maintenance_services",
            params: valid_params, headers: headers, as: :json
        expect(json_response[:data][:vehicle_id]).to eq(vehicle.id)
      end

      it "changes vehicle status to in_maintenance" do
        post "/api/v1/vehicles/#{vehicle.id}/maintenance_services",
            params: valid_params, headers: headers, as: :json
        expect(vehicle.reload.status).to eq("in_maintenance")
      end
    end

    describe "with invalid params" do
      it "returns 422 when description is missing" do
        post "/api/v1/vehicles/#{vehicle.id}/maintenance_services",
            params: { maintenance_service: valid_params[:maintenance_service].except(:description) },
            headers: headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error structure" do
        post "/api/v1/vehicles/#{vehicle.id}/maintenance_services",
            params: { maintenance_service: valid_params[:maintenance_service].except(:description) },
            headers: headers, as: :json
        expect(json_response[:error]).to include(:code, :message, :details)
      end

      it "returns 422 when date is in the future" do
        post "/api/v1/vehicles/#{vehicle.id}/maintenance_services",
            params: { maintenance_service: valid_params[:maintenance_service].merge(date: 1.year.from_now.to_s) },
            headers: headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns 422 when cost_cents is negative" do
        post "/api/v1/vehicles/#{vehicle.id}/maintenance_services",
            params: { maintenance_service: valid_params[:maintenance_service].merge(cost_cents: -1) },
            headers: headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not create service with invalid data" do
        expect {
          post "/api/v1/vehicles/#{vehicle.id}/maintenance_services",
              params: { maintenance_service: { description: "" } },
              headers: headers, as: :json
        }.not_to change(MaintenanceService, :count)
      end
    end

    describe "with invalid vehicle_id" do
      it "returns 404" do
        post "/api/v1/vehicles/99999/maintenance_services",
            params: valid_params, headers: headers, as: :json
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
