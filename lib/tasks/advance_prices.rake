desc "Advance stock prices every minute (Windows-compatible alternative to bin/jobs)"
task advance_prices: :environment do
  puts "Starting price advancement loop. Press Ctrl+C to stop."
  loop do
    begin
      AdvancePriceJob.perform_now
      puts "[#{Time.now.strftime('%H:%M:%S')}] Prices advanced."
    rescue => e
      puts "[#{Time.now.strftime('%H:%M:%S')}] Error: #{e.message}"
    end
    sleep 60
  end
end
