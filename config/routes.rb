S3::Engine.routes.draw do

  get '/deleted_records',        to: 'records#deleted_records'
  get '/legacy_deleted_records', to: 'records#legacy_deleted_records'

end
