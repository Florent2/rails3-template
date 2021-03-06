# references for Rails3 template syntax: 
#  http://github.com/rails/rails/blob/master/railties/lib/rails/generators/actions.rb
#  http://rdoc.info/github/wycats/thor/master/Thor/Actions

remove_file "public/index.html"
remove_file "public/favicon.ico"
remove_file "public/images/rails.png"

gems = <<-GEMS

gem "haml"
gem 'haml-rails'
gem "jquery-rails"
gem "validates_lengths_from_database"
gem "attribute_normalizer"
gem "message_block"
gem "active_sanity"

group :development do
  gem 'annotate'
  gem 'migrate-well'
  gem 'autorefresh'
  gem "rspec-rails"  
  gem 'fabrication'
  gem 'capybara', :git => "git://github.com/Florent2/capybara"
  gem "rails-dev-boost", :git => "git://github.com/thedarkone/rails-dev-boost.git", :require => "rails_development_boost"  
end

group :test do
  gem "rspec-rails"               
  gem 'fabrication'             
  gem 'capybara', :git => "git://github.com/Florent2/capybara"
  gem 'database_cleaner'
  gem 'webmock'         
  gem 'spork'                  
  gem 'autotest'
  gem 'autotest-rails-pure'
  gem 'autotest-growl'      
  gem 'autotest-fsevent'
  gem 'shoulda'         
  gem 'fuubar'                  
  gem 'launchy'
end
GEMS

gsub_file "Gemfile", /#.+/, ""
gsub_file "Gemfile", /^\W/, ""
append_to_file "Gemfile", gems


generators = <<-GENERATORS

    config.generators do |g|
      g.stylesheets false      
      g.template_engine :haml
      g.test_framework :rspec, :fixture => true, :views => false
      g.integration_tool :rspec, :fixture => true, :views => true      
      g.helper false
    end
GENERATORS
application generators

gsub_file 'config/application.rb', 'config.filter_parameters += [:password]', 'config.filter_parameters += [:password, :password_confirmation]'

layout = <<-LAYOUT
!!!
%html
  %head
    %title #{app_name.humanize}
    = stylesheet_link_tag :all
    = csrf_meta_tag
    - if Rails.env.development?
      :erb
        <%= AutoRefresh.channel '#{app_name.humanize}' %>
  %body
    = message_block  
    = yield
    = javascript_include_tag :defaults    
LAYOUT

remove_file "app/views/layouts/application.html.erb"
create_file "app/views/layouts/application.html.haml", layout

watchr = <<-WATCHR
  watch( 'public/stylesheets/.*\.css' ) { |m| system('autorefresh #{app_name.humanize}') }
WATCHR
create_file ".watchr", watchr

run "gem install bundler"
run "bundle install"

remove_file "public/javascripts/rails.js"
generate "jquery:install"

generate "rspec:install" 
create_file 'spec/spec.opts', "--drb\n-f Fuubar"

run "cp config/database.yml config/database.yml.example"

rake "message_block:install"

rake "db:create"

append_file '.gitignore',
%q{config/database.yml
spec/views
spec/controllers
spec/requests"
log/
tmp/
db/schema.rb
.iterm-rails.config
.rvmrc
.DS_Store
spec/helpers
spec/routing
spec/requests
}
git :init
git :add => "."
git :commit => "-a -m 'initial commit'"
