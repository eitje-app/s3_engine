module S3
  class Engine < ::Rails::Engine
    isolate_namespace S3
    config.generators.api_only = true
  end
end
