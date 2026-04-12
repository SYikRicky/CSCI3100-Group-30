require "rails_helper"

RSpec.describe PortfoliosController, type: :routing do
  describe "routing" do
    it "routes to #show" do
      expect(get: "/portfolios/1").to route_to("portfolios#show", id: "1")
    end
  end
end
