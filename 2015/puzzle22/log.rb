require 'logger'

module MyLogger
  include Logger::Severity

  class << self
    attr_writer :logger

    def log
      @logger ||= Logger.new('puzzle02.log').tap do |log|
        log.progname = 'AOC2015/22'
        log.level = Logger::WARN
      end
    end
  end
end
