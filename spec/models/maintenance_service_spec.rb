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

    describe '#status' do
      it 'accepts valid statuses' do
        should define_enum_for(:status).with_values([:pending, :in_progress, :completed])
      end
    end

    describe '#cost_cents' do
      context 'with valid cost' do
        it 'accepts valid cost values' do
          should allow_value(0).for(:cost_cents)
          should allow_value(100).for(:cost_cents)
          should allow_value(9999).for(:cost_cents)
        end
      end

      context 'with invalid cost' do
        it 'rejects invalid cost values' do
          should_not allow_value(-1).for(:cost_cents)
          should_not allow_value(10.5).for(:cost_cents)
          should_not allow_value('one hundred').for(:cost_cents)
        end
      end
    end

    describe '#priority' do
      it 'accepts valid priority values' do
        should define_enum_for(:priority).with_values([:low, :medium, :high])
      end
    end

    describe '#date' do
      it 'accepts valid date' do
        should allow_value(Date.today).for(:date)
        should allow_value(Date.yesterday).for(:date)
        should allow_value(1.week.ago.to_date).for(:date)
      end

      it 'rejects invalid date' do
        should_not allow_value('not a date').for(:date)
        should_not allow_value(Date.tomorrow).for(:date)
        should_not allow_value(Date.today+5.days).for(:date)
        should_not allow_value(nil).for(:date)
      end
    end

    describe '#complete_at' do
      it 'Maintennance Service is invalid as completed without a completed_date' do
        service = build(:maintenance_service, status: :completed, complete_at: nil)
        expect(service).not_to be_valid
      end
    end
  end
end
