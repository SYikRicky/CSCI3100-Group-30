require "rails_helper"

RSpec.describe AlpacaService, type: :service do
  let(:ticker) { "AAPL" }
  let(:start_date) { Date.new(2011, 1, 1) }
  let(:end_date) { Date.new(2011, 1, 3) }

  subject(:service) { described_class.new }

  describe "#fetch_historical_prices" do
    it "returns parsed minute OHLCV data under the bars key" do
      stub_request(
        :get,
        %r{https://data\.alpaca\.markets/v2/stocks/#{Regexp.escape(ticker)}/bars}
      )
        .to_return(
          status: 200,
          headers: { "Content-Type" => "application/json" },
          body: {
            "bars" => [
              {
                "t" => "2011-01-02T00:01:00Z",
                "o" => "10.0",
                "h" => "11.0",
                "l" => "9.5",
                "c" => "10.5",
                "v" => "1000"
              },
              {
                "t" => "2011-01-03T00:01:00Z",
                "o" => "10.5",
                "h" => "11.5",
                "l" => "10.0",
                "c" => "11.0",
                "v" => "1500"
              }
            ]
          }.to_json
        )

      result = service.fetch_historical_prices(
        ticker: ticker,
        start_date: start_date,
        end_date: end_date
      )

      expect(result.size).to eq(2)

      first = result.first
      expect(first[:ticker]).to eq(ticker)
      expect(first[:recorded_at]).to eq(Time.zone.parse("2011-01-02T00:01:00Z"))
      expect(first[:open]).to eq(BigDecimal("10.0"))
      expect(first[:high]).to eq(BigDecimal("11.0"))
      expect(first[:low]).to eq(BigDecimal("9.5"))
      expect(first[:close]).to eq(BigDecimal("10.5"))
      expect(first[:price]).to eq(BigDecimal("10.5"))
      expect(first[:volume]).to eq(BigDecimal("1000"))
    end

    it "raises AlpacaService::Error on non-2xx responses" do
      stub_request(
        :get,
        %r{https://data\.alpaca\.markets/v2/stocks/#{Regexp.escape(ticker)}/bars}
      )
        .to_return(status: 500, body: "Internal Server Error")

      expect {
        service.fetch_historical_prices(
          ticker: ticker,
          start_date: start_date,
          end_date: end_date
        )
      }.to raise_error(AlpacaService::Error)
    end
  end
end

