require "logger"
logger = Logger.new(STDOUT)

task :synchronize_ip_locations do
  Metrics::IPSynchronizer.execute
end

PERIODS = {
  daily: "day",
  weekly: "week",
  monthly: "month",
}.freeze

PERIODS.each do |adverbial, period|
  name = "publish_#{adverbial}_statistics".to_sym

  task name, [:date] do |_, args|
    args.with_defaults(date: Date.today.to_s)
    logger.info("Publishing #{adverbial} statistics with #{args[:date]}")
    performance_gateway = PerformancePlatform::Gateway::PerformanceReport.new
    active_users_gateway = PerformancePlatform::Gateway::ActiveUsers.new(period: period, date: args[:date])
    active_users_presenter = PerformancePlatform::Presenter::ActiveUsers.new(date: args[:date])

    PerformancePlatform::UseCase::SendPerformanceReport.new(
      stats_gateway: active_users_gateway,
      performance_gateway: performance_gateway,
    ).execute(presenter: active_users_presenter)

    performance_gateway = PerformancePlatform::Gateway::PerformanceReport.new
    roaming_users_gateway = PerformancePlatform::Gateway::RoamingUsers.new(period: period, date: args[:date])
    roaming_users_presenter = PerformancePlatform::Presenter::RoamingUsers.new(date: args[:date])

    PerformancePlatform::UseCase::SendPerformanceReport.new(
      stats_gateway: roaming_users_gateway,
      performance_gateway: performance_gateway,
    ).execute(presenter: roaming_users_presenter)
  end
end

PERIODS.each do |adverbial, period|
  name = "publish_#{adverbial}_metrics".to_sym

  task name, [:date] do |_, args|
    args.with_defaults(date: Date.today.to_s)

    logger.info("Creating #{adverbial} metrics for S3 with #{args[:date]}")

    metrics_list = [Metrics::ActiveUsers.new(period: period, date: args[:date]),
                    Metrics::RoamingUsers.new(period: period, date: args[:date])]

    metrics_list.each do |metrics|
      logger.info("[#{metrics.key}] Fetching and uploading metrics...")

      metrics.execute

      logger.info("[#{metrics.key}] Done.")
    end
  end
end
