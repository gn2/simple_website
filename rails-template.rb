# Use like this:
# rails appname -m /path/to/rails_template.rb --database=mysql

# Set up git
git :init
git :submodule => "init"

# Install Gems
gem 'mislav-will_paginate',     :lib => 'will_paginate', :source => 'http://gems.github.com'
gem "jchupp-is_paranoid",       :lib => 'is_paranoid', :version => ">= 0.0.1", :source => 'http://gems.github.com'
gem "rubyist-aasm",             :lib => 'aasm', :version => ">= 0.0.1", :source => 'http://gems.github.com'
gem "vigetlabs-acts_as_markup", :lib => 'acts_as_markup', :source => 'http://gems.github.com'
gem 'thoughtbot-shoulda',       :lib => 'shoulda', :source => "http://gems.github.com"
gem "rdiscount"
gem "haml"

# Install Plugins
#if yes?("Do you want to install test plugins (cucumber, machinist, ...)?")
#  plugin 'cucumber',      :git => "git://github.com/aslakhellesoy/cucumber.git", :submodule => true
#end

plugin 'machinist', :git => 'git://github.com/notahat/machinist.git', :submodule => true

plugin 'acts_as_tree',        :git => 'git://github.com/rails/acts_as_tree.git', :submodule => true
plugin 'asset_packager',      :git => 'git://github.com/sbecker/asset_packager.git', :submodule => true
plugin 'authlogic',           :git => 'git://github.com/binarylogic/authlogic.git', :submodule => true
plugin 'exception_notifier',  :git => 'git://github.com/rails/exception_notification.git', :submodule => true
plugin 'facebox_render',      :git => 'git://github.com/ihower/facebox_render.git', :submodule => true
plugin 'haml',                :git => "git://github.com/nex3/haml.git", :submodule => true
plugin 'jrails',              :git => 'git://github.com/aaronchi/jrails.git', :submodule => true
plugin 'make_resourceful',    :git => "git://github.com/hcatlin/make_resourceful.git", :submodule => true
plugin 'paperclip',           :git => "git://github.com/thoughtbot/paperclip.git", :submodule => true
plugin 'permalink_fu',        :git => 'git://github.com/technoweenie/permalink_fu.git', :submodule => true

plugin 'simple_config',                 :git => 'git://github.com/gn2/simple_config.git', :submodule => true
plugin 'simple_state_machine_history',  :git => 'git://github.com/gn2/simple_state_machine_history.git', :submodule => true

# Rake stuff
#rake "gems:install", :sudo => true
rake "db:create"
rake "db:sessions:create"
rake "db:migrate"
rake "db:migrate:simple_state_machine_history"

# Jquery
# run "curl -L http://jqueryjs.googlecode.com/files/jquery-1.2.6.min.js > public/javascripts/jquery.js"
# run "curl -L http://jqueryjs.googlecode.com/svn/trunk/plugins/form/jquery.form.js > public/javascripts/jquery.form.js"

# Clean default stuff
run "rm README"
run "rm public/index.html"
run "rm public/favicon.ico"
run "rm public/images/rails.png"
run "rm public/javascripts/prototype.js"
run "rm public/javascripts/effects.js"
run "rm public/javascripts/dragdrop.js"
run "rm public/javascripts/controls.js"

file "README", 
%Q{
  ==== Gn2 Site ===

  This application helps you manage your stuff. It is a nice and simple cms with a pretty backend.

  Copyright (c) #{Time.now.year} Adrien (adrien[at]gn2[dot]fr), all rights reserved
}

file "app/helpers/application_helper.rb",
%Q{module ApplicationHelper

  # Set page title
  def page_title(page_title)  
    content_for(:page_title) { page_title }  
  end

end
}

file "config/database.yml.example", 
%Q{
  base: &base
    adapter: mysql
    username: root
    password:
    host: localhost

  development:
    database: gn2_development
    <<: *base

  test:
    database: gn2_test
    <<: *base

  staging:
    database: gn2_staging
    <<: *base

  production:
    database: gn2_production
    <<: *base
}

run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
run %{find . -type d -empty | grep -v "vendor" | grep -v ".git" | grep -v "tmp" | xargs -I xxx touch xxx/.gitignore}
file '.gitignore', <<-END
.DS_Store
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
END

git :add => ".", :commit => "-m 'Initial commit'"

#
# Installing Rails engines
#
plugin 'simple_admin',  :git => 'git@git.gn2.fr:simple_admin.git',  :submodule => true
plugin 'simple_cms',    :git => 'git@git.gn2.fr:simple_cms.git',    :submodule => true
plugin 'simple_users',  :git => 'git@git.gn2.fr:simple_users.git',  :submodule => true

# Updating environment.rb
run "sed -i '' -e 's/#.*config.plugins.*/config.plugins = [ :simple_users, :simple_admin, :simple_cms, :all ]/' config/environment.rb"
run "sed -i '' -e 's/#.*config.active_record.observers.*/config.active_record.observers = :page_observer/' config/environment.rb"

env_rb = IO.read 'config/environment.rb'
env_config = <<-END

# SimpleConfig
SimpleConfig::Site.title = "Website title"
SimpleConfig::Site.domain = "example.net"
SimpleConfig::Site.url = "http://www.\#{SimpleConfig::Site.domain}"
SimpleConfig::SimpleUsers.after_login_path = :admin_path

SimpleConfig::Google.ping_sitemap = false

# Including the helpers necessary for special formatting
include ActionView::Helpers::DateHelper

SimpleAdmin::Resources.register(
  :users,
  :class_name => 'User',
  :route => true, # Not used at the moment. Routes must be added manually in routes.rb (including any additional route added in this config)
  :tab => true,
  :order => :login, # How to order a collection (default is object.id)
  :index => [
    {:name => :login, :link => {:path => :admin_user_path}},
    :name, :state, :email,
    {:name => "Admin?", :format => lambda {|u| u.is_admin? ? "yes" : "no"}},
    {:name => :login_count, :format => lambda {|u| u.login_count || 0}},
    {:name => 'Last login', :format => lambda {|u| u.last_login_at ? eval('distance_of_time_in_words_to_now(u.last_login_at) + " ago"') : 'never'}},
    {:name => 'Created', :format => lambda {|u| eval('distance_of_time_in_words_to_now(u.created_at) + " ago"')}}
    ],
  :edit => [
    :login, :name, :email,
    {:name => :password, :virtual => true, :type => :password},
    {:name => :password_confirmation, :virtual => true, :type => :password},
    # {:name => :is_admin, :type => :boolean, :values => {:true => "yes", :false => "false"}},
     :notes
    ],
  :controller_methods => [
    {:name => :activate, :method => :put, :do => lambda {|u| u.activate!}, :flash_notice => "This user account has been activated"},
    {:name => :inactivate, :method => :put, :do => lambda {|u| u.inactivate!}, :flash_error => "This user account has been disabled"},
    {:name => :ban, :method => :put, :do => lambda {|u| u.ban!}, :flash_error => "This user has been banned"},
    {:name => :remove_ban, :method => :put, :do => lambda {|u| u.remove_ban!}, :flash_notice => "The ban has been removed for this user account"},
    {:name => :admin, :method => :put, :do => lambda {|u| u.admin!}, :flash_notice => "Admin privileges have been granted to this user"},
    {:name => :revoke_admin, :method => :put, :do => lambda {|u| u.revoke_admin!}, :flash_error => "Admin privileges have been revoked for this user"}
    ],
  :sidebar => [
    {:name => "Disable?", :intro => "is <strong>active</strong> &mdash; ", :if => lambda {|u| u.active?}, :link => {:path => :inactivate_admin_user_path, :method => :put}},
    {:name => "Activate?", :intro => "is <strong>inactive</strong> &mdash; ", :if => lambda {|u| u.inactive?}, :link => {:path => :activate_admin_user_path, :method => :put}},
    {:name => "Activate?", :intro => "is <strong>pending</strong> &mdash; ", :if => lambda {|u| u.pending?}, :link => {:path => :activate_admin_user_path, :method => :put}},
    {:name => "Revoke admin?", :intro => "is an <strong>administrator</strong> &mdash; ", :if => lambda {|u| u.is_admin?}, :link => {:path => :revoke_admin_admin_user_path, :method => :put}},
    {:name => "Remove ban?", :intro => "is <strong>banned</strong> &mdash; ",:if => lambda {|u| u.banned?}, :link => {:path => :remove_ban_admin_user_path, :method => :put}},
    {:name => "Ban", :if => lambda {|u| !u.banned?}, :link => {:path => :ban_admin_user_path, :method => :put}},
    {:name => "Make admin", :if => lambda {|u| !u.is_admin?}, :link => {:path => :admin_admin_user_path, :method => :put}},
    {:format => lambda {|u| eval('"has been created " + distance_of_time_in_words_to_now(u.created_at) + " ago"')}},
    {:format => lambda {|u| eval('"has been last updated " + distance_of_time_in_words_to_now(u.updated_at) + " ago"')}},
    {:name => "Delete this user", :link => {:path => :admin_user_path, :method => :delete, :confirm => "Are your sure?"}}
    ]
)
END
env_rb << env_config
File.open('config/environment.rb', 'w') do |environment|
  environment.write(env_rb)
end

# Manage routes
route "map.connect '*path.:format', :controller => 'sensei', :action => 'dispatch'"
route "map.root :controller => 'sensei', :action => 'home'"
route "map.resources :users, :controller => 'admin/generic', :path_prefix => 'admin', :name_prefix => 'admin_', :member => {:activate => :put, :inactivate => :put, :ban => :put, :admin => :put, :revoke_admin => :put, :remove_ban => :put}"

run "sed -i '' -e '/.*map.connect..:controller.:action.:id.*/d' config/routes.rb"

# Rake tasks
rake "db:migrate"
rake "simple_users:sync"
rake "simple_admin:sync"
rake "simple_cms:sync"
rake "db:migrate"
rake "simple_users:bootstrap:all password=password email=adrien@gn2.fr"
# rake "simple_cms:layouts"
# rake "simple_cms:sample_pages"

git :add => ".", :commit => "-m 'Adding simple_users, simple_cms and simple_admin rails engines'"
