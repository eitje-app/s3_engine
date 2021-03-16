Rails.application.routes.draw do
  mount S3::Engine => "/s3"
end
