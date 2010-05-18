# references for Rails3 template syntax: 
#  http://github.com/rails/rails/blob/master/railties/lib/rails/generators/actions.rb
#  http://rdoc.info/rdoc/wycats/thor/blob/f939a3e8a854616784cac1dcff04ef4f3ee5f7ff/Thor/Actions.html

if yes?("create rvm gemset?")
  rvmrc = <<-RVMRC
  rvm_gemset_create_on_use_flag=1
  rvm gemset use #{app_name}
  RVMRC
  
  create_file ".rvmrc", rvmrc
end

empty_directory "lib/generators"
git :clone => "--depth 0 http://github.com/Florent2/rails3-template.git lib/generators"
remove_dir "lib/generators/.git"

gem "haml", ">= 3.0.0.rc.4"
gem "rspec-rails", ">= 2.0.0.beta.8", :group => :test

generators = <<-GENERATORS

    config.generators do |g|
      g.template_engine :haml
      g.test_framework :rspec, :fixture => false, :views => false
    end
GENERATORS

application generators

get "http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js",  "public/javascripts/jquery.js"
get "http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.1/jquery-ui.min.js", "public/javascripts/jquery-ui.js"
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
    = javascript_include_tag :jquery
    = csrf_meta_tag
  %body
    = yield
LAYOUT

remove_file "app/views/layouts/application.html.erb"
create_file "app/views/layouts/application.html.haml", layout

git :init
git :add => "."

docs = <<-DOCS

Run the following commands to complete the setup of #{app_name.humanize}:

% cd #{app_name}
% gem install bundler
% bundle install
% bundle lock
% script/rails generate rspec:install

DOCS

log docs
