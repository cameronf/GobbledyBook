$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require 'rvm/capistrano'
require 'bundler/capistrano'

set :application, "gobbledybook"
 
# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/sites/gobbledybook.com"
 
# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git
set :repository, "gitosis@67.207.128.103:gobbledybook.git"
set :branch, "master"
set :deploy_via, :remote_cache
set :copy_exclude, ["*.sql", "*.mysql"]
 
set :user, 'deploy'
set :ssh_options, { :forward_agent => true }
 
role :app, "67.207.128.103"
role :web, "67.207.128.103"
role :db,  "67.207.128.103", :primary => true
 
namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
 
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end

desc "copy over database.yml"
task :copy_database_yml do
  run "cp #{deploy_to}/current/config/database.yml.example #{deploy_to}/current/config/database.yml"
end
  
desc "run cleanup after each successful deploy"
task :deploy_cleanup do
  cleanup
end

after "deploy:update_code", :copy_database_yml
after :default, :deploy_cleanup
