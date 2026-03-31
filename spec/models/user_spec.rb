require 'rails_helper'

# Define data structure
RSpec.describe User, type: :model do
    
    describe 'validations' do
        it { should validate_presence_of(:email) }
        it { should validate_uniqueness_of(:email).case_insensitive }
        it { should validate_presence_of(:password) }
    end

    # Test key associations - user, league, porfolio
    describe 'associations' do
        it { should have_many :portfolios }
        it { should have_many :league_memberships }
        it { should have_many(:leagues).through(:league_memberships) }
        it { should have_many(:owned_leagues).with_foreign_key('owner_id').class_name('League') }
    end
end
