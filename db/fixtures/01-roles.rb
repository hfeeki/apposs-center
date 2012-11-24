# -*- encoding : utf-8 -*-
['Admin', 'PE', 'APPOPS'].each do |role_name|
  Role.seed(:name){|r| r.name = role_name }
end
