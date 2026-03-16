require "rails_helper"

RSpec.describe "GET /api/v1/vehicles", type: :request do
  let(:user)    { create(:user) }
  let(:token)   { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { "Authorization" => "Bearer #{token}" } }

  describe "autenticación" do
    it "retorna 401 sin token" do
      get "/api/v1/vehicles"
      expect(response).to have_http_status(:unauthorized)
    end

    it "retorna 401 con token inválido" do
      get "/api/v1/vehicles", headers: { "Authorization" => "Bearer invalid_token" }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "listado básico" do
    before { create_list(:vehicle, 3) }

    it "retorna 200" do
      get "/api/v1/vehicles", headers: headers
      expect(response).to have_http_status(:ok)
    end

    it "retorna estructura con data y meta" do
      get "/api/v1/vehicles", headers: headers
      expect(json_response).to have_key(:data)
      expect(json_response).to have_key(:meta)
    end

    it "retorna los vehículos" do
      get "/api/v1/vehicles", headers: headers
      expect(json_response[:data].length).to eq(3)
    end

    it "cada vehículo tiene los atributos esperados" do
      get "/api/v1/vehicles", headers: headers
      vehicle = json_response[:data].first
      expect(vehicle.keys).to include(:id, :vin, :plate, :brand, :model, :year, :status)
    end
  end

  describe "paginación" do
    before { create_list(:vehicle, 15) }

    it "retorna 10 por defecto" do
      get "/api/v1/vehicles", headers: headers
      expect(json_response[:data].length).to eq(10)
    end

    it "respeta el parámetro per_page" do
      get "/api/v1/vehicles", params: { per_page: 5 }, headers: headers
      expect(json_response[:data].length).to eq(5)
    end

    it "la metadata incluye total_count y total_pages" do
      get "/api/v1/vehicles", headers: headers
      meta = json_response[:meta]
      expect(meta[:total_count]).to eq(15)
      expect(meta[:total_pages]).to eq(2)
    end

    it "navega a la segunda página" do
      get "/api/v1/vehicles", params: { page: 2 }, headers: headers
      expect(json_response[:data].length).to eq(5)
    end

    it "la metadata refleja la página actual" do
      get "/api/v1/vehicles", params: { page: 2 }, headers: headers
      expect(json_response[:meta][:current_page]).to eq(2)
      expect(json_response[:meta][:prev_page]).to eq(1)
      expect(json_response[:meta][:next_page]).to be_nil
    end
  end

  describe "filtros" do
    before do
      create(:vehicle, status: :active,   brand: "Toyota")
      create(:vehicle, status: :inactive, brand: "Ford")
      create(:vehicle, status: :active,   brand: "Toyota")
    end

    it "filtra por status" do
      get "/api/v1/vehicles", params: { status: "inactive" }, headers: headers
      expect(json_response[:data].length).to eq(1)
    end

    it "filtra por brand" do
      get "/api/v1/vehicles", params: { brand: "Toyota" }, headers: headers
      expect(json_response[:data].length).to eq(2)
    end
  end

  describe "búsqueda" do
    before do
      create(:vehicle, plate: "ABC123", vin: "1HGCM82633A123456")
      create(:vehicle, plate: "XYZ999", vin: "2HGCM82633A654321")
    end

    it "busca por plate (case-insensitive)" do
      get "/api/v1/vehicles", params: { search: "abc" }, headers: headers
      expect(json_response[:data].length).to eq(1)
    end

    it "busca por vin" do
      get "/api/v1/vehicles", params: { search: "1HGCM" }, headers: headers
      expect(json_response[:data].length).to eq(1)
    end
  end
end
