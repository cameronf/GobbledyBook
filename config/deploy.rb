set :application, "gobbledybook.com"
set :user, "cameronf"
set :local_repository,  "svn+gobbledybookssh://gobbledybook.com/home/repository/gobbledybook/trunk"
set :repository,  "file:///home/repository/gobbledybook/trunk"
set :port, 10001

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"
set :deploy_to, "/home/public_html/gobbledybook"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion
set :use_sudo, false

set :location, "gobbledybook.com"

role :app, location
role :web, location
role :db,  location, :primary => true

desc "Restart Thin"
task :restart_thin do
  sudo "/etc/init.d/thin restart"
end

desc "copy over database.yml"
task :create_database_yml do
  run "cp #{deploy_to}/current/config/database.yml.example #{deploy_to}/current/config/database.yml"
end

after "deploy", "deploy:cleanup"
after "deploy:migrations", "deploy:cleanup"
after "deploy:cleanup", "create_database_yml"
after "create_database_yml", "restart_thin"

