# S3 gem

Never stops lovin AWS, yay!

## Installation

Add this line to your application's Gemfile:

```ruby

gem 's3', git: 'https://github.com/eitje-app/s3_engine', branch: 'production'

```
Create and run the required migrations:

```bash

$ rails s3:install:migrations
$ rails db:migrate

```
Add the following to your routes.rb:
```ruby

mount s3::Engine => "/s3"

```
Set the following environment variables in your application:
```ruby
```
