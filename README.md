# S3 gem

Never stops lovin AWS, yay!

## Installation

Add this line to your application's Gemfile:

```ruby

gem 's3', git: 'https://github.com/eitje-app/s3_engine', branch: 'production'

```

Or, for development purposes, add instead:

```ruby

local_paths = %w$ /Users/jurriaanschrofer/Documents/s3 $
if ENV['IS_LOCAL_ENGINE'] && ( path = local_paths.find {|path| Dir.glob(path).any?} )
  gem 's3', path: path
else
  gem 's3', git: 'https://github.com/eitje-app/s3_engine', branch: 'production'
end

```

Create and run the required migrations:

```bash

$ rails s3:install:migrations
$ rails db:migrate

```
Add the following to your routes.rb:
```ruby

mount S3::Engine => "/s3"

```
Set the following environment variables in your application:
```ruby
```
