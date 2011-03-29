# references for Rails3 template syntax: 
#  http://github.com/rails/rails/blob/master/railties/lib/rails/generators/actions.rb
#  http://rdoc.info/github/wycats/thor/master/Thor/Actions

remove_file "public/index.html"
remove_file "public/favicon.ico"
remove_file "public/images/rails.png"

gem "haml"
gem 'haml-rails'
gem "jquery-rails"
gem "validates_lengths_from_database"
gem "attribute_normalizer"
gem 'annotate',                 :group => :development
gem 'fabrication',              :group => [:development, :test]
gem 'capybara',                 :group => [:development, :test]
gem 'steak',                    :group => [:development, :test]
gem "rspec-rails"               :group => [:development, :test]
gem 'database_cleaner',         :group => :test
gem 'webmock',                  :group => :test
gem 'spork',                    :group => :test
gem 'autotest',                 :group => :test
gem 'autotest-rails-pure',      :group => :test
gem 'autotest-growl',           :group => :test
gem 'autotest-fsevent',         :group => :test
gem 'shoulda',                  :group => :test
gem 'fuubar',                   :group => :test
gem 'launchy',                  :group => :test

generators = <<-GENERATORS

    config.generators do |g|
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
  %body
    = yield
    = javascript_include_tag :defaults    
LAYOUT

remove_file "app/views/layouts/application.html.erb"
create_file "app/views/layouts/application.html.haml", layout

run "gem install bundler"
run "bundle install"

remove_file "public/javascripts/rails.js"
generate "jquery:install"

generate "rspec:install" 
append_to_file '.rspec', "--drb\n-f Fuubar"
generate "steak:install"

run "cp config/database.yml config/database.yml.example"

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