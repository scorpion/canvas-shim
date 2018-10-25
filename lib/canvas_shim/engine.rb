require 'delayed_job'
require 'csv'
module CanvasShim
  class Engine < ::Rails::Engine
    config.autoload_paths << File.expand_path("app/services", __dir__)
    config.autoload_paths << File.expand_path("app/deploy", __dir__)

    isolate_namespace CanvasShim

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
