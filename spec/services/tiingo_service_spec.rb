require 'rails_helper'

RSpec.describe TiingoService, type: :service do
  let(:api_key) { 'cfbe10d9bbdbd0bc7df6765394dd45616db3f591' }
  let(:ticker) { 'AAPL' }
  let(:start_date) { Date.new(2011, 1, 1) }
  let(:end_date) { Date.new(2011, 1, 3) }

  subject(:service) { described_class.new }

  describe '#fetch_historical_prices' do
    it 'returns parsed OHLCV data with recorded_at timestamps' do
      stub_request(:get, "https://api.tiingo.com/tiingo/daily/#{ticker}/prices")
        .with(query: hash_including(
          'startDate' => start_date.to_s,
          'endDate' => end_date.to_s,
          'token' => api_key
        ))
        .to_return(
          status: 200,
          body: [
            {
              'date' => '2011-01-02T00:00:00.000Z',
              'open' => 10.0,
              'high' => 11.0,
              'low' => 9.5,
              'close' => 10.5,
              'adjClose' => 10.5,
              'volume' => 1000
            },
            {
              'date' => '2011-01-03T00:00:00.000Z',
              'open' => 10.5,
              'high' => 11.5,
              'low' => 10.0,
              'close' => 11.0,
              'adjClose' => 11.0,
              'volume' => 1500
            }
          ].to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = service.fetch_historical_prices(
        ticker: ticker,
        start_date: start_date,
        end_date: end_date
      )

      expect(result.size).to eq(2)

      first = result.first
      expect(first[:ticker]).to eq(ticker)
      expect(first[:recorded_at]).to eq(Time.zone.parse('2011-01-02T00:00:00.000Z'))
      expect(first[:open]).to eq(BigDecimal('10.0'))
      expect(first[:high]).to eq(BigDecimal('11.0'))
      expect(first[:low]).to eq(BigDecimal('9.5'))
      expect(first[:close]).to eq(BigDecimal('10.5'))
      expect(first[:volume]).to eq(BigDecimal('1000'))
      expect(first[:price]).to eq(BigDecimal('10.5'))
    end

    it 'raises an error when Tiingo returns a non-200 response' do
      stub_request(:get, "https://api.tiingo.com/tiingo/daily/#{ticker}/prices")
        .with(query: hash_including(
          'startDate' => start_date.to_s,
          'endDate' => end_date.to_s,
          'token' => api_key
        ))
        .to_return(status: 500, body: 'Internal Server Error')

      expect {
        service.fetch_historical_prices(
          ticker: ticker,
          start_date: start_date,
          end_date: end_date
        )
      }.to raise_error(TiingoService::Error)
    end
  end
end
