require_relative "lib/s3/version"

Gem::Specification.new do |spec|
  spec.name        = "s3"
  spec.version     = S3::VERSION
  spec.authors     = ["Jurriaan Schrofer"]
  spec.email       = ["jschrofer@gmail.com"]
  spec.homepage    = "https://eitje.app"
  spec.summary     = "Summary of S3."
  spec.description = "Description of S3."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://eitje.app"
  spec.metadata["changelog_uri"] = "https://eitje.app"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 5.2.3"
  spec.add_dependency "aws-sdk-s3"
  spec.add_dependency "figaro"
end
