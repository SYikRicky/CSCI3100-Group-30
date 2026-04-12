require "rails_helper"

RSpec.describe AdvancePriceJob, type: :job do
  let(:stock) { create(:stock, last_price: 100.0) }

  def create_snapshots(stock, count, base_time: Time.zone.parse("2026-01-01 09:30:00"))
    count.times do |i|
      create(:price_snapshot,
        stock: stock,
        recorded_at: base_time + i.minutes,
        open: 100 + i * 0.1,
        high: 101 + i * 0.1,
        low: 99 + i * 0.1,
        close: 100.5 + i * 0.1,
        volume: 1000)
    end
  end

  describe "#perform" do
    it "creates a new price snapshot for a stock with existing snapshots" do
      create_snapshots(stock, 5)

      expect { described_class.new.perform }.to change(PriceSnapshot, :count).by(1)
    end

    it "skips stocks with no snapshots" do
      stock # ensure stock exists but no snapshots

      expect { described_class.new.perform }.not_to change(PriceSnapshot, :count)
    end

    it "does not create duplicate snapshots when run twice" do
      create_snapshots(stock, 5)

      described_class.new.perform # first run creates a snapshot
      count_after_first = PriceSnapshot.where(stock: stock).count

      described_class.new.perform # second run creates another (different minute)
      count_after_second = PriceSnapshot.where(stock: stock).count

      # Each run should create exactly one new snapshot
      expect(count_after_first).to eq(6)
      expect(count_after_second).to eq(7)
    end

    it "updates the stock last_price and last_synced_at" do
      create_snapshots(stock, 5)

      described_class.new.perform
      stock.reload

      expect(stock.last_price).to be_present
      expect(stock.last_synced_at).to be_present
    end

    it "sets recorded_at to last snapshot time + 1 minute" do
      create_snapshots(stock, 5)
      expected_time = stock.price_snapshots.order(:recorded_at).last.recorded_at + 1.minute

      described_class.new.perform

      new_snap = PriceSnapshot.where(stock: stock).order(:recorded_at).last
      expect(new_snap.recorded_at).to eq(expected_time)
    end
  end

  describe "#calibrate_gbm" do
    subject(:job) { described_class.new }

    it "returns [mu, sigma] from historical closes" do
      create_snapshots(stock, 10)
      snaps = PriceSnapshot.where(stock: stock).order(:recorded_at).to_a

      mu, sigma = job.send(:calibrate_gbm, snaps)

      expect(mu).to be_a(Float)
      expect(sigma).to be_a(Float)
      expect(sigma).to be >= 0.003
    end

    it "returns defaults when fewer than 2 snapshots" do
      snap = create(:price_snapshot, stock: stock)

      mu, sigma = job.send(:calibrate_gbm, [ snap ])

      expect(mu).to eq(0.0)
      expect(sigma).to eq(0.012)
    end

    it "clamps sigma to minimum 0.003" do
      # Create snapshots with identical closes so variance is near zero
      base_time = Time.zone.parse("2026-01-01 09:30:00")
      snaps = 5.times.map do |i|
        create(:price_snapshot, stock: stock, recorded_at: base_time + i.minutes,
               close: 100.0, open: 100.0, high: 100.0, low: 100.0)
      end

      _mu, sigma = job.send(:calibrate_gbm, snaps)

      expect(sigma).to eq(0.003)
    end
  end

  describe "#generate_candle" do
    subject(:job) { described_class.new }

    it "returns a hash with open, high, low, close, volume" do
      candle = job.send(:generate_candle, 100.0, 0.0, 0.01)

      expect(candle).to include(:open, :high, :low, :close, :volume)
    end

    it "sets open equal to prev_close" do
      candle = job.send(:generate_candle, 150.0, 0.0, 0.01)

      expect(candle[:open]).to eq(150.0)
    end

    it "maintains high >= open and high >= close" do
      candle = job.send(:generate_candle, 100.0, 0.0, 0.02)

      expect(candle[:high]).to be >= candle[:open]
      expect(candle[:high]).to be >= candle[:close]
    end

    it "maintains low <= open and low <= close" do
      candle = job.send(:generate_candle, 100.0, 0.0, 0.02)

      expect(candle[:low]).to be <= candle[:open]
      expect(candle[:low]).to be <= candle[:close]
    end

    it "produces positive volume" do
      candle = job.send(:generate_candle, 100.0, 0.0, 0.01)

      expect(candle[:volume]).to be > 0
    end
  end
end
