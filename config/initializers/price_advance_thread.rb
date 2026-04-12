Rails.application.config.after_initialize do
  next unless defined?(Rails::Server) || ENV["SOLID_QUEUE_IN_PUMA"]

  # Synchronous boot sync — runs after DB is ready, before first request is served
  begin
    AdvancePriceJob.perform_now
    Rails.logger.info "[PriceAdvance] Boot sync at #{Time.current}"
  rescue => e
    Rails.logger.error "[PriceAdvance] Boot sync error: #{e.message}"
  end

  Thread.new do
    loop do
      sleep 60
      begin
        AdvancePriceJob.perform_now
        Rails.logger.info "[PriceAdvance] Prices updated at #{Time.current}"
      rescue => e
        Rails.logger.error "[PriceAdvance] Error: #{e.message}"
      end
    end
  end
end
