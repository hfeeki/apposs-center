# coding: utf-8
namespace :setup do

  task :default => :pluglets

  desc "装载pluglets"
  task :pluglets => :environment do
    puts "装载pluglets"
    require 'yaml'
    YAML.load(File.read 'config/pluglets.yml').each do| name, command |
      if template = DirectiveTemplate.pluglets.where(:alias => name).first
        template.update_attribute :name, command
      else
        DirectiveTemplate.make_pluglet(name,command)
      end
    end
  end

  desc '清理adsci数据'
  task :adsci_clean => :environment do
    app = App.reals.find_by_name 'adsci_sandbox'
    puts '清理指令'
    app.machines.map(&:directives).flatten.each{|x| puts x.id; x.delete}
    puts '清理机器'
    app.machines.map{|x| puts x.name; x.delete}
  end
end
