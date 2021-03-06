#
# Borrowed from: https://github.com/webficient/capistrano-recipes
#
#
# Copyright (c) 2009-2011 Webficient LLC, Phil Misiowiec
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# =========================================================================
# These are helper methods that will be available to your recipes.
# =========================================================================

# automatically sets the environment based on presence of 
# :stage (multistage gem), :rails_env, or RAILS_ENV variable; otherwise defaults to 'production'
def environment  
  #if exists?(:stage)
  #  stage
  #elsif exists?(:rails_env)
  if exists?(:rails_env)
    rails_env  
  elsif(ENV['RAILS_ENV'])
    ENV['RAILS_ENV']
  else
    "production"  
  end
end

def is_using_nginx
  is_using('nginx',:web_server)
end

def is_using_passenger
  is_using('passenger',:app_server)
end

def is_using_unicorn
  is_using('unicorn',:app_server)
end

def is_app_monitored?
  is_using('bluepill', :monitorer) || is_using('god', :monitorer)
end

def is_using(something, with_some_var)
 exists?(with_some_var.to_sym) && fetch(with_some_var.to_sym).to_s.downcase == something
end

# Path to where the generators live
#def templates_path
#  expanded_path_for('../generators')
#end

#def docs_path
#  expanded_path_for('../doc')
#end

#def expanded_path_for(path)
#  e = File.join(File.dirname(__FILE__),path)
#  File.expand_path(e)
#end

def parse_config(file)
  require 'erb'  #render not available in Capistrano 2
  template=File.read(file)          # read it
  return ERB.new(template).result(binding)   # parse it
end

# =========================================================================
# Prompts the user for a message to agree/decline
# =========================================================================
def ask(message, default=true)
  Capistrano::CLI.ui.agree(message)
end

# Generates a configuration file parsing through ERB
# Fetches local file and uploads it to remote_file
# Make sure your user has the right permissions.
def generate_config(local_file,remote_file)
  temp_file = '/tmp/' + File.basename(local_file)
  buffer    = parse_config(local_file)
  File.open(temp_file, 'w+') { |f| f << buffer }
  upload temp_file, remote_file, :via => :scp
  `rm #{temp_file}`
end 

# =========================================================================
# Executes a basic rake task. 
# Example: run_rake log:clear
# =========================================================================
def run_rake(task)
  run "cd #{current_path} && bundle exec rake #{task} RAILS_ENV=#{environment}"
end


#########################################################################
# Newscloud Helper Methods
#########################################################################

def skin_dir_exists?
  dir_exists? "#{skin_dir}/#{application}"
end

def skin_file_exists?
  file_exists? "#{skin_dir}/#{application}/app/stylesheets/skin.sass"
end

def dir_exists? path
  'yes' == capture("if [ -d #{path} ]; then echo 'yes'; fi").strip
end

def file_exists? path
  'yes' == capture("if [ -e #{path} ]; then echo 'yes'; fi").strip
end

def read_remote_file file
  out = ''
  run "cat #{file}" do |ch, st, data|
    out += data
  end
  out
end

def with_user(new_user, new_pass, &block)
  old_user, old_pass = user, password
  set :user, new_user
  set :password, new_pass
  close_sessions
  yield
  set :user, old_user
  set :password, old_pass
  close_sessions
end

def close_sessions
  sessions.values.each { |session| session.close }
  sessions.clear
end