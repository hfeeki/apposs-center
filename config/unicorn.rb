# -*- encoding : utf-8 -*-
rack_env = ENV['RAILS_ENV'] || 'production'
workers = ENV['WORKERS'] || '10'
puts "rack env: #{rack_env}, workers: #{workers}"
working_directory File.expand_path("..", File.dirname(__FILE__))
pid "tmp/pids/unicorn.pid"
preload_app false
stderr_path "log/unicorn.log"
stdout_path "log/unicorn.log"

if rack_env=='production'
  listen "/tmp/apposs.sock"
else
  listen 3000, :tcp_nopush => true
end
worker_processes workers.to_i
timeout 30

