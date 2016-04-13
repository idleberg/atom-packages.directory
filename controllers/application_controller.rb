require 'lib/environment'
require 'sprockets'
require 'sprockets-helpers'
require 'compass'

class ApplicationController < Sinatra::Base
  helpers ApplicationHelpers
  set :sprockets, Sprockets::Environment.new(root)

  # Partials support for views
  register Sinatra::Partial

  set :partial_template_engine, :erb
  set :views, File.join(File.dirname(__FILE__), '../views')

  configure do
    enable :logging
    use Rack::CommonLogger, LOG_FILE

    %w(javascripts stylesheets images).each do |type|
      sprockets.append_path File.join(root, "../assets/#{type}")
    end
    sprockets.append_path File.join(root, '../assets/javascripts/views')
    sprockets.append_path File.join(root, '../assets', 'javascripts', 'bower_components')

    Sprockets::Helpers.configure do |config|
      config.environment = sprockets
      config.prefix      = '/assets'
    end
  end

  before do
    NoBrainer.sync_schema
  end

  get '/' do
    erb :index, locals: { top_categories: Category.top }
  end

  get "#{Sprockets::Helpers.prefix}/*" do |path|
    env_sprockets = request.env.dup
    env_sprockets['PATH_INFO'] = path
    settings.sprockets.call env_sprockets
  end
end
