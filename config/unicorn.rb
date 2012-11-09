# -*- encoding : utf-8 -*-
rack_env = ENV['RAILS_ENV'] || 'production'
puts "rack env: #{rack_env}"
working_directory File.expand_path("..", File.dirname(__FILE__))
pid "tmp/pids/unicorn.pid"
stderr_path "log/unicorn.log"
stdout_path "log/unicorn.log"

if rack_env=='production'
  listen "/tmp/unicorn.apposs.sock"
else
  listen 3000, :tcp_nopush => true
end
worker_processes 5
timeout 30

