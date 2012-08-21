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

end
