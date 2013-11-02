remove_file "README.rdoc"
create_file "README.md", "TODO"

gsub_file 'README.md', /rake/ do |match|
  match << " no more. Use thor!"
end

inside "app/assets/stylesheets" do
  run "mv application.css application.css.scss"
  run "gsed -i '/require_tree/d' application.css.scss"
end

inside "app/assets/javascripts" do
  run "gsed -i '/require_tree/d' application.js"
end

gem 'simple_form'

gem_group :development do
  gem 'pry'
  gem 'better_errors'
  gem 'binding_of_caller'
end

gem_group :development, :test do 
  gem 'rspec-rails' 
  gem 'factory_girl_rails' 
end 

gem_group :test do 
  gem 'faker' 
  gem 'capybara' 
  gem 'guard-rspec' 
  gem 'launchy' 
  gem 'database_cleaner',  version: '< 1.1.0'
end


run "bundle exec guard init rspec"
generate "rspec:install"

inside "config" do
  run <<-CMD
gsed -i '/class Application < Rails::Application/a\\
\t\t# Configure generators values. Many other options are available, be sure to check the documentation.\\
\t\tconfig.generators do |g|\\
\t\t\tg.test_framework :rspec, fixture: true, view_specs: false, helper_specs: false, routing_specs: false\\
\t\t\tg.fixture_replacement :factory_girl, dir: "spec/factories"\\
\t\tend' application.rb
CMD
end

inside "spec" do
  run %Q{
gsed -i '/config\\.order/a\\
\tconfig.include FactoryGirl::Syntax::Methods' spec_helper.rb
}
  run "gsed -i '/^\\s*config.fixture_path/s/config.fixture_path/#\\0/' spec_helper.rb"
end

git :init
git add: '.'
git commit: %Q{ -a -m 'Initial commit' }


