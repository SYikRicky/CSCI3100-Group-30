class StocksController < ApplicationController
  def index
    @stocks = Stock.all
  end

  def show
    @stock = Stock.find(params[:id])
    @chart_data = PriceSnapshot.where(stock_id: @stock.id)
                               .order(:recorded_at)
                               .map do |s|
                                 {
                                   time:  s.recorded_at.to_i,
                                   open:  s.open.to_f,
                                   high:  s.high.to_f,
                                   low:   s.low.to_f,
                                   close: s.close.to_f
                                 }
                               end
                               .uniq { |d| d[:time] }
                               .to_json
  end
end
