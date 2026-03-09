require 'rails_helper'

RSpec.describe MaintenanceService, type: :model do
  describe 'associations' do
    it { should belong_to(:vehicle) }
  end

  describe 'validations' do
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:cost_cents) }
    it { should validate_presence_of(:priority) }
    
    it { should validate_numericality_of(:cost_cents).only_integer.is_greater_than_or_equal_to(0) }
  end
end
