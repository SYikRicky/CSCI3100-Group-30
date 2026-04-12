require 'rails_helper'

RSpec.describe FillPendingOrdersService, type: :service do
  let(:portfolio) { create(:portfolio, cash_balance: 10_000) }
  let(:stock) { create(:stock, last_price: 150) }

  describe "#call" do
    context "limit buy" do
      let!(:order) do
        create(:trade, portfolio: portfolio, stock: stock,
               action: "buy", quantity: 10, order_type: "limit",
               limit_price: 145, status: "pending",
               price_at_trade: nil, executed_at: nil)
      end

      it "fills when price drops to limit price" do
        stock.update!(last_price: 145)
        result = described_class.new(stock: stock).call

        expect(result.size).to eq(1)
        order.reload
        expect(order.status).to eq("filled")
        expect(order.price_at_trade.to_f).to eq(145.0)

        portfolio.reload
        holding = portfolio.holdings.find_by(stock: stock)
        expect(holding.direction).to eq("long")
        expect(holding.quantity.to_d).to eq(10)
        expect(portfolio.cash_balance.to_d).to eq(BigDecimal("8550.0"))
      end

      it "fills when price drops below limit price" do
        stock.update!(last_price: 140)
        result = described_class.new(stock: stock).call

        expect(result.size).to eq(1)
        order.reload
        expect(order.status).to eq("filled")
        # Fills at the limit price, not the lower market price
        expect(order.price_at_trade.to_f).to eq(145.0)
      end

      it "does not fill when price is above limit" do
        stock.update!(last_price: 148)
        result = described_class.new(stock: stock).call

        expect(result).to be_empty
        expect(order.reload.status).to eq("pending")
      end
    end

    context "limit sell" do
      before do
        create(:holding, portfolio: portfolio, stock: stock,
               quantity: 10, average_cost: 140, direction: "long")
      end

      let!(:order) do
        create(:trade, portfolio: portfolio, stock: stock,
               action: "sell", quantity: 10, order_type: "limit",
               limit_price: 155, status: "pending",
               price_at_trade: nil, executed_at: nil)
      end

      it "fills when price rises to limit price" do
        stock.update!(last_price: 155)
        result = described_class.new(stock: stock).call

        expect(result.size).to eq(1)
        order.reload
        expect(order.status).to eq("filled")
        expect(order.price_at_trade.to_f).to eq(155.0)

        portfolio.reload
        expect(portfolio.holdings.find_by(stock: stock)).to be_nil
        expect(portfolio.cash_balance.to_d).to eq(BigDecimal("11550.0"))
      end

      it "does not fill when price is below limit" do
        stock.update!(last_price: 152)
        result = described_class.new(stock: stock).call

        expect(result).to be_empty
        expect(order.reload.status).to eq("pending")
      end
    end

    context "stop buy" do
      let!(:order) do
        create(:trade, portfolio: portfolio, stock: stock,
               action: "buy", quantity: 10, order_type: "stop",
               stop_price: 160, status: "pending",
               price_at_trade: nil, executed_at: nil)
      end

      it "fills when price rises to stop price" do
        stock.update!(last_price: 160)
        result = described_class.new(stock: stock).call

        expect(result.size).to eq(1)
        order.reload
        expect(order.status).to eq("filled")
        expect(order.price_at_trade.to_f).to eq(160.0)

        portfolio.reload
        holding = portfolio.holdings.find_by(stock: stock)
        expect(holding.direction).to eq("long")
        expect(holding.quantity.to_d).to eq(10)
      end

      it "does not fill when price is below stop" do
        stock.update!(last_price: 158)
        result = described_class.new(stock: stock).call

        expect(result).to be_empty
      end
    end

    context "stop sell (short)" do
      let!(:order) do
        create(:trade, portfolio: portfolio, stock: stock,
               action: "sell", quantity: 10, order_type: "stop",
               stop_price: 140, status: "pending",
               price_at_trade: nil, executed_at: nil)
      end

      it "fills when price drops to stop price" do
        stock.update!(last_price: 140)
        result = described_class.new(stock: stock).call

        expect(result.size).to eq(1)
        order.reload
        expect(order.status).to eq("filled")
        expect(order.price_at_trade.to_f).to eq(140.0)

        portfolio.reload
        holding = portfolio.holdings.find_by(stock: stock)
        expect(holding.direction).to eq("short")
        expect(holding.quantity.to_d).to eq(10)
      end
    end

    context "with custom current_price" do
      let!(:order) do
        create(:trade, portfolio: portfolio, stock: stock,
               action: "buy", quantity: 5, order_type: "limit",
               limit_price: 145, status: "pending",
               price_at_trade: nil, executed_at: nil)
      end

      it "uses the provided price instead of stock.last_price" do
        # stock.last_price is 150 (no fill), but we pass 144
        result = described_class.new(stock: stock, current_price: 144).call
        expect(result.size).to eq(1)
        expect(order.reload.status).to eq("filled")
      end
    end
  end
end
