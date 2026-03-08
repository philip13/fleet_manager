require 'rails_helper'

RSpec.describe Vehicle, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:vin) }
    it { should validate_presence_of(:plate) }
    it { should validate_presence_of(:year) }
  end
end
