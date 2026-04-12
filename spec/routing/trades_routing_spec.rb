require "rails_helper"

RSpec.describe TradesController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(post: "/portfolios/1/trades").to route_to("trades#create", portfolio_id: "1")
    end
  end
end
