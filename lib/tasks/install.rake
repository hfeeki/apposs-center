# coding: utf-8
namespace :install do

  task :default => :data

  desc "set up configuration"
  task :config do # => :environment do
    puts "设置数据库"
    setup_file 'config/database.yml' do |content|
      db_user = get_var "用户"
      db_password = get_var "密码"
      content.
        sub(/username: apposs/, "username: #{db_user}").
        sub(/password: apposs/, "password: #{db_password}")
    end
   
    puts "设置google的oauth2认证"
    setup_file 'config/initializers/omniauth.rb' do |content|
      client_id = get_var 'Client ID'
      client_secret = get_var 'Client secret'
      content.
        sub(/<Client secret>/, client_secret).
        sub(/<Client ID>/, client_id)
    end
  end

  desc "pick up the data your want to load"
  task :data => :config do
    puts "生成初始数据"
    setup_file 'db/fixtures/02-users.rb'
    setup_file 'db/fixtures/03-agents.rb'
    setup_file 'db/fixtures/04-apps.rb'
    puts "初始数据在 db/fixtures 目录下，建议根据情况修改，然后执行 rake db:seed_fu "
  end

  private
  def setup_file filename, &block
    if File.exist? filename
      print "> 文件已存在[ #{filename} ]，是否覆盖？[y/N]"
      override = while answer=$stdin.readline.chop
                   if answer=~/^[yY](es)?/
                     break true
                   elsif answer=~/^[nN]o?/
                     break false
                   end
                   print "文件已存在[ #{filename} ]，是否覆盖？[y/N]"
                 end
      write_config filename, &block if override
    else
      write_config filename, &block
    end
  end

  def write_config filename
    File.open(filename,'w') do |f|
      if block_given?
        f.write yield(File.read("#{filename}.example"))
      else
        f.write File.read("#{filename}.example")
      end
    end
  end

  def get_var name
    print "> 请输入#{name}: "
    $stdin.readline.chop
  end
end
