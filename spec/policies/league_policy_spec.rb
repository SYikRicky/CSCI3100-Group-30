require 'rails_helper'

RSpec.describe LeaguePolicy, type: :policy do
    subject { described_class }

    permissions :index?, :show? do
        it "denies access if user is not logged in" do
        expect(subject).not_to permit(nil, League.new)
        end

        it "allows access if user is logged in" do
        user = User.new
        expect(subject).to permit(user, League.new)
        end
    end
end
