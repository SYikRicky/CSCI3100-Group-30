require 'rails_helper'

RSpec.describe HistoricalDataSeedJob, type: :job do
  let!(:stock) { Stock.create!(ticker: 'AAPL', company_name: 'Apple Inc.') }
  let(:start_date) { Date.new(2011, 1, 1) }
  let(:end_date) { Date.new(2011, 1, 3) }

  let(:service_double) { instance_double(TiingoService) }

  before do
    allow(TiingoService).to receive(:new).and_return(service_double)
    allow(service_double).to receive(:fetch_historical_prices).and_return(
      [
        {
          ticker: stock.ticker,
          recorded_at: Time.zone.parse('2011-01-02T00:00:00.000Z'),
          open: BigDecimal('10.0'),
          high: BigDecimal('11.0'),
          low: BigDecimal('9.5'),
          close: BigDecimal('10.5'),
          price: BigDecimal('10.5'),
          volume: BigDecimal('1000')
        },
        {
          ticker: stock.ticker,
          recorded_at: Time.zone.parse('2011-01-03T00:00:00.000Z'),
          open: BigDecimal('10.5'),
          high: BigDecimal('11.5'),
          low: BigDecimal('10.0'),
          close: BigDecimal('11.0'),
          price: BigDecimal('11.0'),
          volume: BigDecimal('1500')
        }
      ]
    )
  end

  it 'inserts price snapshots and updates stock last_price and last_synced_at' do
    expect {
      perform_enqueued_jobs do
        described_class.perform_later(stock.id, start_date, end_date)
      end
    }.to change { PriceSnapshot.count }.by(2)

    stock.reload

    expect(stock.price_snapshots.count).to eq(2)

    latest_snapshot = stock.price_snapshots.order(recorded_at: :desc).first
    expect(stock.last_price).to eq(latest_snapshot.close)
    expect(stock.last_synced_at).to be_present
  end
end
