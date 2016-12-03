require 'logger'

module MyLogger
  class << self
    attr_writer :logger

    def log
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = 'AOC2015/22'
        log.level = Logger::DEBUG
      end
    end
  end
end
