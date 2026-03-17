require 'rails_helper'

RSpec.describe "Api::V1::Auth", type: :request do
  describe "POST /api/v1/auth/login" do
    let(:password) { "SecurePass123!" }
    let(:user) { create(:user, password: password) }

    context "Valid credentials" do
      it "return status 200" do
        post "/api/v1/auth/login", params: { email: user.email, password: password }, as: :json
        expect(response).to have_http_status(:ok)
      end

      it "returns a JWT token" do
        post "/api/v1/auth/login", params: { email: user.email, password: password }, as: :json
        expect(json_response[:token]).to be_present
      end

      it "returns the basic user data" do
        post "/api/v1/auth/login", params: { email: user.email, password: password }, as: :json
        expect(json_response[:user]).to include(
          id:    user.id,
          email: user.email
        )
      end

      it "the token returned have the user_id" do
        post "/api/v1/auth/login", params: { email: user.email, password: password }, as: :json
        token   = json_response[:token]
        payload = JsonWebToken.decode(token)

        expect(payload[:user_id]).to eq(user.id)
      end
    end

    context "Incorrect email" do
      it "return status 401" do
        post "/api/v1/auth/login", params: { email: "wrong@email.com", password: password }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it "return invalid_credentials error" do
        post "/api/v1/auth/login", params: { email: "wrong@email.com", password: password }, as: :json
        expect(json_response[:error][:code]).to eq("invalid_credentials")
      end

      it "do not return token" do
        post "/api/v1/auth/login", params: { email: "wrong@email.com", password: password }, as: :json
        expect(json_response[:token]).to be_nil
      end
    end

    context "incorrect password" do
      it "return status 401" do
        post "/api/v1/auth/login", params: { email: user.email, password: "WrongPass!" }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it "return invalid_credentials error message" do
        post "/api/v1/auth/login", params: { email: user.email, password: "WrongPass!" }, as: :json
        expect(json_response[:error][:code]).to eq("invalid_credentials")
      end
    end

    context "with empty fields" do
      it "return code 401 if email is empty" do
        post "/api/v1/auth/login", params: { email: "", password: password }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it "return code 401 if password is empty" do
        post "/api/v1/auth/login", params: { email: user.email, password: "" }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
