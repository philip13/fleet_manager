require 'rails_helper'

RSpec.describe Vehicle, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:vin) }
    it { should validate_presence_of(:plate) }
    it { should validate_presence_of(:year)}
    it { should validate_presence_of(:status) }
    
    describe '#year' do
      context 'with valid year' do
        it 'accepts valid yeas' do
          should allow_value(1990).for(:year)
          should allow_value(2020).for(:year)
          should allow_value(2050).for(:year)
        end
      end

      context 'with invalid year' do
        it 'rejects invalid years' do
          should_not allow_value(1989).for(:year)
          should_not allow_value(2051).for(:year)
        end
      end
    end
    
    describe '#status' do
      it { should define_enum_for(:status).with_values([:active, :inactive, :in_maintenance])}
    end
  end
end
