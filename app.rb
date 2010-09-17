# references for Rails3 template syntax: 
#  http://github.com/rails/rails/blob/master/railties/lib/rails/generators/actions.rb
#  http://rdoc.info/github/wycats/thor/master/Thor/Actions

remove_file "public/index.html"
remove_file "public/favicon.ico"
remove_file "public/images/rails.png"

gem "haml"
gem 'haml-rails'
gem 'annotate',                         :group => :development
gem 'faker',                            :group => [:development, :test]
gem 'machinist',                        :group => [:development, :test, :cucumber]
gem "rspec-rails", ">= 2.0.0.beta.20",  :group => [:test, :cucumber]
gem 'database_cleaner',                 :group => [:test, :cucumber]
gem 'webmock',                          :group => [:test, :cucumber]
gem 'shoulda',                          :group => :test
gem 'cucumber',                         :group => :cucumber
gem 'cucumber-rails',                   :group => :cucumber 
gem 'launchy',                          :group => :cucumber
gem 'capybara',                         :group => :cucumber

generators = <<-GENERATORS

    config.generators do |g|
      g.template_engine :haml
      g.test_framework :rspec, :fixture => false, :views => false
    end
GENERATORS

application generators

get "http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js",  "public/javascripts/jquery.js"
get "http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.1/jquery-ui.min.js", "public/javascripts/jquery-ui.js"
remove_file "public/javascripts/rails.js"
get "http://github.com/rails/jquery-ujs/raw/master/src/rails.js", "public/javascripts/rails.js"

jquery = <<-JQUERY
ActionView::Helpers::AssetTagHelper.register_javascript_expansion \
  :jquery => %w(jquery jquery-ui rails)
JQUERY

initializer "jquery.rb", jquery

layout = <<-LAYOUT
!!!
%html
  %head
    %title #{app_name.humanize}
    = stylesheet_link_tag :all
    = javascript_include_tag :defaults
    = csrf_meta_tag
  %body
    = yield
LAYOUT

remove_file "app/views/layouts/application.html.erb"
create_file "app/views/layouts/application.html.haml", layout

run "gem install bundler"
run "bundle install"

generate "rspec:install" 
generate "cucumber:install" " --rspec --capybara"

remove_file "db/seeds.rb"
create_file "db/seeds.rb", "require Rails.root.join('spec').join('blueprints')"
create_file 'spec/blueprints.rb',
%q{require 'machinist/active_record'
require 'sham'  
}

inject_into_file "spec/spec_helper.rb", "require Rails.root.join('spec').join('blueprints')\n", :after => "require 'rspec/rails'\n"
inject_into_file "spec/spec_helper.rb", :after => "Rspec.configure do |config|\n" do
%q{  config.before(:all)  { Sham.reset(:before_all) }
  config.before(:each) { Sham.reset(:before_each) }  
  
}
end
inject_into_file "features/support/env.rb", :after => "if defined?(ActiveRecord::Base)\n" do
%q{  require Rails.root.join('spec').join('blueprints')
  Before { Sham.reset } # reset Shams in between scenarios
    
}  
end

run "cp config/database.yml config/database.yml.example"
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
}
git :init
git :add => "."
git :commit => "-a -m 'initial commit'"