# Make Active Storage resilient to job enqueue failures.
# When Solid Queue tables don't exist (e.g. first deploy), AnalyzeJob and
# PurgeJob enqueue raises, crashing the entire request. This patches
# those jobs to log the error instead of raising.

Rails.application.config.after_initialize do
  ActiveStorage::Blob.class_eval do
    def analyze_later
      if analyzer_class.analyze_later?
        ActiveStorage::AnalyzeJob.perform_later(self)
      else
        analyze
      end
    rescue StandardError => e
      Rails.logger.warn("Failed to enqueue ActiveStorage::AnalyzeJob: #{e.message}")
    end
  end

  ActiveStorage::Blob.class_eval do
    original_purge_later = instance_method(:purge_later)
    define_method(:purge_later) do
      original_purge_later.bind_call(self)
    rescue StandardError => e
      Rails.logger.warn("Failed to enqueue ActiveStorage::PurgeJob: #{e.message}")
    end
  end
end
