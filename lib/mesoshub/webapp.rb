module Mesoshub
  class Webapp < Sinatra::Application
    set :static, true
    set :public_folder, File.dirname(__FILE__) + '/../app'
  end
end
