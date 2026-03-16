require "rails_helper"

RSpec.describe "Api::V1::Vehicles", type: :request do
  let(:user)    { create(:user) }
  let(:token)   { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { "Authorization" => "Bearer #{token}" } }

  describe "GET /api/v1/vehicles" do
    describe "authorization" do
      it "return 401 without token" do
        get "/api/v1/vehicles"
        expect(response).to have_http_status(:unauthorized)
      end

      it "return 401 with invalid token" do
        get "/api/v1/vehicles", headers: { "Authorization" => "Bearer invalid_token" }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "basic listing" do
      before { create_list(:vehicle, 3) }

      it "return 200" do
        get "/api/v1/vehicles", headers: headers
        expect(response).to have_http_status(:ok)
      end

      it "return structure with data and meta" do
        get "/api/v1/vehicles", headers: headers
        expect(json_response).to have_key(:data)
        expect(json_response).to have_key(:meta)
      end

      it "return the vehicles" do
        get "/api/v1/vehicles", headers: headers
        expect(json_response[:data].length).to eq(3)
      end

      it "each vehicle has the expected attributes" do
        get "/api/v1/vehicles", headers: headers
        vehicle = json_response[:data].first
        expect(vehicle.keys).to include(:id, :vin, :plate, :brand, :model, :year, :status)
      end
    end

    describe "pagination" do
      before { create_list(:vehicle, 15) }

      it "return 10 by default" do
        get "/api/v1/vehicles", headers: headers
        expect(json_response[:data].length).to eq(10)
      end

      it "respect the per_page parameter" do
        get "/api/v1/vehicles", params: { per_page: 5 }, headers: headers
        expect(json_response[:data].length).to eq(5)
      end

      it "the metadata includes total_count and total_pages" do
        get "/api/v1/vehicles", headers: headers
        meta = json_response[:meta]
        expect(meta[:total_count]).to eq(15)
        expect(meta[:total_pages]).to eq(2)
      end

      it "get the second page" do
        get "/api/v1/vehicles", params: { page: 2 }, headers: headers
        expect(json_response[:data].length).to eq(5)
      end

      it "current page have metadata" do
        get "/api/v1/vehicles", params: { page: 2 }, headers: headers
        expect(json_response[:meta][:current_page]).to eq(2)
        expect(json_response[:meta][:prev_page]).to eq(1)
        expect(json_response[:meta][:next_page]).to be_nil
      end
    end

    describe "filters" do
      before do
        create(:vehicle, status: :active,   brand: "Toyota")
        create(:vehicle, status: :inactive, brand: "Ford")
        create(:vehicle, status: :active,   brand: "Toyota")
      end

      it "filter by status" do
        get "/api/v1/vehicles", params: { status: "inactive" }, headers: headers
        expect(json_response[:data].length).to eq(1)
      end

      it "filter by brand" do
        get "/api/v1/vehicles", params: { brand: "Toyota" }, headers: headers
        expect(json_response[:data].length).to eq(2)
      end
    end

    describe "search" do
      before do
        create(:vehicle, plate: "ABC123", vin: "1HGCM82633A123456")
        create(:vehicle, plate: "XYZ999", vin: "2HGCM82633A654321")
      end

      it "search vehicle by plate (case-insensitive)" do
        get "/api/v1/vehicles", params: { search: "abc" }, headers: headers
        expect(json_response[:data].length).to eq(1)
      end

      it "search by vin" do
        get "/api/v1/vehicles", params: { search: "1HGCM" }, headers: headers
        expect(json_response[:data].length).to eq(1)
      end
    end
  end

  describe "GET /api/v1/vehicles/:id" do
    let(:vehicle) { create(:vehicle) }

    describe "authorization" do
      it "returns 401 without token" do
        get "/api/v1/vehicles/#{vehicle.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "with valid id" do
      before { get "/api/v1/vehicles/#{vehicle.id}", headers: headers }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the vehicle" do
        expect(json_response[:data][:id]).to eq(vehicle.id)
      end

      it "returns the expected attributes" do
        expect(json_response[:data].keys).to include(:id, :vin, :plate, :brand, :model, :year, :status)
      end

      it "returns the correct vehicle data" do
        expect(json_response[:data]).to include(
          vin:   vehicle.vin,
          plate: vehicle.plate,
          brand: vehicle.brand,
          year:  vehicle.year
        )
      end
    end

    describe "with invalid id" do
      it "returns 404" do
        get "/api/v1/vehicles/99999", headers: headers
        expect(response).to have_http_status(:not_found)
      end

      it "returns error structure" do
        get "/api/v1/vehicles/99999", headers: headers
        expect(json_response[:error]).to include(:code, :message)
      end

      it "returns not_found code" do
        get "/api/v1/vehicles/99999", headers: headers
        expect(json_response[:error][:code]).to eq("not_found")
      end
    end
  end

  describe "POST /api/v1/vehicles" do
    let(:valid_params) do
      {
        vehicle: {
          vin:    "1HGCM82633A004352",
          plate:  "ABC123",
          brand:  "Honda",
          model:  "Accord",
          year:   2020,
          status: "active"
        }
      }
    end

    describe "authorization" do
      it "returns 401 without token" do
        post "/api/v1/vehicles", params: valid_params, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "with valid params" do
      it "returns 201" do
        post "/api/v1/vehicles", params: valid_params, headers: headers, as: :json
        expect(response).to have_http_status(:created)
      end

      it "creates a new vehicle" do
        expect {
          post "/api/v1/vehicles", params: valid_params, headers: headers, as: :json
        }.to change(Vehicle, :count).by(1)
      end

      it "returns the created vehicle" do
        post "/api/v1/vehicles", params: valid_params, headers: headers, as: :json
        expect(json_response[:data]).to include(
          vin:   "1HGCM82633A004352",
          plate: "ABC123",
          brand: "Honda",
          model: "Accord",
          year:  2020
        )
      end
    end

    describe "with invalid params" do
      it "returns 422 when vin is missing" do
        post "/api/v1/vehicles", params: { vehicle: valid_params[:vehicle].except(:vin) },
             headers: headers, as: :json
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns error structure" do
        post "/api/v1/vehicles", params: { vehicle: valid_params[:vehicle].except(:vin) },
             headers: headers, as: :json
        expect(json_response[:error]).to include(:code, :message, :details)
      end

      it "returns 422 when year is out of range" do
        post "/api/v1/vehicles",
             params: { vehicle: valid_params[:vehicle].merge(year: 1980) },
             headers: headers, as: :json
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns 422 when vin is duplicated" do
        create(:vehicle, vin: "1HGCM82633A004352")
        post "/api/v1/vehicles", params: valid_params, headers: headers, as: :json
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns 422 when plate is duplicated case-insensitive" do
        create(:vehicle, plate: "abc123")
        post "/api/v1/vehicles", params: valid_params, headers: headers, as: :json
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "does not create a vehicle with invalid data" do
        expect {
          post "/api/v1/vehicles", params: { vehicle: { vin: "" } },
               headers: headers, as: :json
        }.not_to change(Vehicle, :count)
      end
    end
  end

  describe "PUT /api/v1/vehicles/:id" do
    let(:vehicle) { create(:vehicle, brand: "Honda", year: 2020) }

    describe "authorization" do
      it "returns 401 without token" do
        put "/api/v1/vehicles/#{vehicle.id}", params: { vehicle: { brand: "Toyota" } }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "with valid params" do
      it "returns 200" do
        put "/api/v1/vehicles/#{vehicle.id}",
            params: { vehicle: { brand: "Toyota" } },
            headers: headers, as: :json
        expect(response).to have_http_status(:ok)
      end

      it "updates the vehicle" do
        put "/api/v1/vehicles/#{vehicle.id}",
            params: { vehicle: { brand: "Toyota", year: 2022 } },
            headers: headers, as: :json
        expect(json_response[:data]).to include(brand: "Toyota", year: 2022)
      end

      it "persists the changes in the database" do
        put "/api/v1/vehicles/#{vehicle.id}",
            params: { vehicle: { brand: "Toyota" } },
            headers: headers, as: :json
        expect(vehicle.reload.brand).to eq("Toyota")
      end
    end

    describe "with invalid params" do
      it "returns 422 when year is out of range" do
        put "/api/v1/vehicles/#{vehicle.id}",
            params: { vehicle: { year: 1800 } },
            headers: headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error structure" do
        put "/api/v1/vehicles/#{vehicle.id}",
            params: { vehicle: { vin: "" } },
            headers: headers, as: :json
        expect(json_response[:error]).to include(:code, :message, :details)
      end

      it "returns 422 when vin is duplicated" do
        other = create(:vehicle)
        put "/api/v1/vehicles/#{vehicle.id}",
            params: { vehicle: { vin: other.vin } },
            headers: headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not persist invalid changes" do
        put "/api/v1/vehicles/#{vehicle.id}",
            params: { vehicle: { year: 1800 } },
            headers: headers, as: :json
        expect(vehicle.reload.year).to eq(2020)
      end
    end

    describe "with invalid id" do
      it "returns 404" do
        put "/api/v1/vehicles/99999",
            params: { vehicle: { brand: "Toyota" } },
            headers: headers, as: :json
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
