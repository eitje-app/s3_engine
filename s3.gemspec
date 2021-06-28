require_relative "lib/s3/version"

Gem::Specification.new do |spec|
  
  spec.name        = "eitje_s3"
  spec.version     = S3::VERSION

  spec.authors     = ["Jurriaan Schrofer"]
  spec.email       = ["jschrofer@gmail.com"]

  spec.summary     = "S3"
  spec.description = "S3"

  spec.license     = "MIT"

  spec.homepage                    = "https://github.com/eitje-app/s3_engine"
  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/eitje-app/s3_engine"
  spec.metadata["changelog_uri"]   = "https://github.com/eitje-app/s3_engine"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 5.2.3"
  spec.add_dependency "aws-sdk-s3"
  spec.add_dependency "figaro"
  
end
