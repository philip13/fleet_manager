require 'rails_helper'

RSpec.describe Vehicle, type: :model do
  subject { build(:vehicle) }

  describe 'validations' do
    it { should validate_presence_of(:vin) }
    it { should validate_presence_of(:plate) }
    it { should validate_presence_of(:year) }
    it { should validate_numericality_of(:year).only_integer }
    it { should validate_presence_of(:status) }
    it { should have_many(:maintenance_services) }
    
    describe '#year' do
      context 'with valid year' do
        it 'accepts valid years' do
          should allow_value(1990).for(:year)
          should allow_value(2020).for(:year)
          should allow_value(2050).for(:year)
        end
      end

      context 'with invalid year' do
        it 'rejects invalid years' do
          should_not allow_value(1989).for(:year)
          should_not allow_value(2051).for(:year)
          should_not allow_value('two thousand').for(:year)
          should_not allow_value(2000.5).for(:year)
        end
      end
    end
    
    describe '#status' do
      it { should define_enum_for(:status).with_values([:active, :inactive, :in_maintenance])}
    end

    describe '#vin' do
      it 'validates uniqueness of vin' do
        vehicle1 = create(:vehicle, vin: 'UNIQUEVIN123')
        vehicle2 = build(:vehicle, vin: 'UNIQUEVIN123')
        expect(vehicle2).not_to be_valid
      end
    end

    describe '#plate' do
      it 'validates uniqueness of plate' do
        vehicle1 = create(:vehicle, plate: 'UNIQUEPLATE123')
        vehicle2 = build(:vehicle, plate: 'UNIQUEPLATE123')
        expect(vehicle2).not_to be_valid
      end
    end
  end

  describe '#sync_status!' do
    let(:vehicle) { create(:vehicle) }

    context 'when there are pending or in_progress maintenance services' do
      before do
        create(:maintenance_service, vehicle: vehicle, status: :pending)
        # vehicle.sync_status!
      end

      it 'sets status to in_maintenance' do
        expect(vehicle.status).to eq('in_maintenance')
      end
    end

    context 'when there are no pending or in_progress maintenance services' do
      before do
        create(:maintenance_service, vehicle: vehicle, status: :completed, completed_at: Date.today)
        # vehicle.sync_status!
      end

      it 'sets status to active' do
        expect(vehicle.status).to eq('active')
      end
    end
  end
end
