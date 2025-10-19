namespace :auth do
  desc "Setup OAuth application credentials"
  task setup: :environment do
    app = Doorkeeper::Application.find_or_create_by(name: 'Medika API') do |application|
      application.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
      application.scopes = 'read write'
    end

    puts "OAuth Application Setup Complete"
    puts "Client ID: #{app.uid}"
    puts "Client Secret: #{app.secret}"
  end
end