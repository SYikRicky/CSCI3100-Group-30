class AlpacaService
  class Error < StandardError; end

  BASE_URL = "https://data.alpaca.markets".freeze

  # Temporary hardcoded keys for TAs (per project requirements).
  # Replace with real keys when running locally if needed.
  APCA_API_KEY_ID = "PKXHKV7BZ2E3G2RUIKY35ZBLSV".freeze
  APCA_API_SECRET_KEY = "ENYc6UwN5LsJBvZbWW383zUJdcnEuGKhfnHmnAjLh7Mm".freeze

  def initialize
    @api_key_id = APCA_API_KEY_ID
    @api_secret_key = APCA_API_SECRET_KEY
  end

  # Fetch minute-level OHLCV data for a symbol between two dates.
  # Returns an array of hashes with keys:
  #   :ticker, :recorded_at, :open, :high, :low, :close, :price, :volume
  def fetch_historical_prices(ticker:, start_date:, end_date:)
    all_bars = []
    page_token = nil

    loop do
      response = connection.get("/v2/stocks/#{ticker}/bars") do |req|
        req.headers["APCA-API-KEY-ID"] = @api_key_id
        req.headers["APCA-API-SECRET-KEY"] = @api_secret_key

        req.params["timeframe"] = "1Min"
        req.params["feed"] = "iex"
        req.params["limit"] = 10000 # Increased limit to speed up fetching
        req.params["start"] = normalize_rfc3339(start_date)
        req.params["end"] = normalize_rfc3339(end_date)
        
        # Pass the pagination token if we have one from the previous loop
        req.params["page_token"] = page_token if page_token
      end

      raise Error, "Alpaca request failed with status #{response.status}" unless response.success?

      parsed = JSON.parse(response.body)
      bars = extract_bars(parsed)
      
      # Add this page's bars to our master list
      all_bars.concat(bars)

      # Check for the next page token
      page_token = parsed["next_page_token"]
      
      # Stop looping if there are no more pages
      break if page_token.nil? || page_token.empty?
    end

    # Map all accumulated bars instead of just the last page
    all_bars.map do |bar|
      {
        ticker: ticker,
        recorded_at: Time.zone.parse(bar["t"].to_s),
        open: to_decimal(bar["o"]),
        high: to_decimal(bar["h"]),
        low: to_decimal(bar["l"]),
        close: to_decimal(bar["c"]),
        price: to_decimal(bar["c"]),
        volume: to_decimal(bar["v"])
      }
    end
  rescue Faraday::Error => e
    raise Error, "Alpaca request error: #{e.class}: #{e.message}"
  rescue JSON::ParserError => e
    raise Error, "Alpaca response parse error: #{e.class}: #{e.message}"
  end

  private

  def connection
    @connection ||= Faraday.new(url: BASE_URL) do |faraday|
      faraday.request :url_encoded
      # Alpaca returns HTTP errors; wrap all Faraday errors in AlpacaService::Error.
      faraday.response :raise_error
      faraday.adapter Faraday.default_adapter
    end
  end

  def extract_bars(parsed)
    bars = parsed["bars"] || parsed[:bars]
    bars = bars.values.first if bars.is_a?(Hash)
    bars || []
  end

  def normalize_rfc3339(value)
    time =
      case value
      when Date
        Time.utc(value.year, value.month, value.day, 0, 0, 0)
      when Time
        value.utc
      when DateTime
        value.to_time.utc
      when String
       # Time.iso8601(value).utc
        Time.zone.parse(value).utc
      else
        raise ArgumentError, "Unsupported date type for Alpaca: #{value.class}"
      end

    time.strftime("%Y-%m-%dT%H:%M:%SZ")
  end

  def to_decimal(value)
    return nil if value.nil?

    BigDecimal(value.to_s)
  end
end