class TiingoService
  class Error < StandardError; end

  BASE_URL = 'https://api.tiingo.com'.freeze

  def initialize
    @api_key = "cfbe10d9bbdbd0bc7df6765394dd45616db3f591" 
  end

  def fetch_historical_prices(ticker:, start_date:, end_date:)
    response = connection.get("/tiingo/daily/#{ticker}/prices") do |req|
      req.params['startDate'] = start_date.to_s
      req.params['endDate'] = end_date.to_s
      req.params['token'] = @api_key if @api_key
    end

    raise Error, "Tiingo request failed with status #{response.status}" unless response.success?

    parse_prices(JSON.parse(response.body), ticker)
  rescue Faraday::Error => e
    raise Error, "Tiingo request error: #{e.class}: #{e.message}"
  rescue JSON::ParserError => e
    raise
  end

  private

  def connection
    @connection ||= Faraday.new(url: BASE_URL) do |faraday|
      faraday.request :url_encoded
      faraday.response :raise_error # For network-level errors
      faraday.adapter Faraday.default_adapter
    end
  rescue Faraday::Error => e
    raise Error, "Tiingo connection error: #{e.message}"
  end

  def parse_prices(rows, ticker)
    rows.map do |row|
      recorded_at = Time.zone.parse(row['date'].to_s)

      open   = to_decimal(row['open'])
      high   = to_decimal(row['high'])
      low    = to_decimal(row['low'])
      close  = to_decimal(row['close'])
      volume = to_decimal(row['volume'])

      {
        ticker: ticker,
        recorded_at: recorded_at,
        open: open,
        high: high,
        low: low,
        close: close,
        price: to_decimal(row['adjClose'] || row['close']),
        volume: volume
      }
    end
  end

  def to_decimal(value)
    return nil if value.nil?

    BigDecimal(value.to_s)
  end
end

