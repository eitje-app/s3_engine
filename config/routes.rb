S3::Engine.routes.draw do

  get '/deleted_records', to: 'records#deleted_records'  

end
