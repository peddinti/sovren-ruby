module Sovren
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :account_id, :service_key

    def initialize
      @account_id = 'donotreply@example.com'
      @service_key = 'donotreply@example.com'
    end
  end
end