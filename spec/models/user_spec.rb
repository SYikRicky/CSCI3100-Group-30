require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validation" do
    it "is invald without username" do
      user_without_username = FactoryBot.build(:user, username: nil)
      expect(user_without_username).not_to be_valid
      expect(user_without_username.errors[:username]).to be_present
    end

    it "is invald without email" do
      user_without_email = FactoryBot.build(:user, email: nil)
      expect(user_without_email).not_to be_valid
      expect(user_without_email.errors[:email]).to be_present
    end

    it "is invald without password" do
      user_without_email = FactoryBot.build(:user, password: nil)
      expect(user_without_email).not_to be_valid
      expect(user_without_email.errors[:email]).to be_present
    end
  end
end
