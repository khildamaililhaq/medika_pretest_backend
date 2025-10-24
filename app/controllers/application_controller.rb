class ApplicationController < ActionController::API
  include SerializerGenerator
  include ActionController::MimeResponds
end
