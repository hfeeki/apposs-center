class InitTables < ActiveRecord::Migration
  def change
    create_table "agents" do |t|
      t.string   "ipaddr"
      t.string   "name"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    add_index "agents", ["ipaddr"], :name => "index_agents_on_ipaddr"
    add_index "agents", ["name"], :name => "index_agents_on_name"

    create_table "apposs_file_file_entries" do |t|
      t.integer  "app_id"
      t.string   "refer_url"
      t.string   "refer_type"
      t.string   "path"
      t.datetime "created_at",            :null => false
      t.datetime "updated_at",            :null => false
      t.integer  "operation_template_id"
      t.integer  "directive_template_id"
      t.boolean  "linkable"
    end

    create_table "apps" do |t|
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "parent_id"
      t.boolean  "virtual"
      t.string   "state"
      t.boolean  "locked"
      t.string   "outer_identity"
    end

    add_index "apps", ["outer_identity"], :name => "index_apps_on_outer_identity"

    create_table "directive_groups" do |t|
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "directive_groups", ["name"], :name => "index_directive_groups_on_name"

    create_table "directive_templates" do |t|
      t.string   "name",               :limit => 1024
      t.string   "alias"
      t.string   "arg1"
      t.string   "arg2"
      t.string   "arg3"
      t.string   "arg4"
      t.string   "arg5"
      t.integer  "directive_group_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "owner_id"
    end

    create_table "directives" do |t|
      t.integer  "operation_id"
      t.integer  "machine_id"
      t.integer  "directive_template_id"
      t.boolean  "next_when_fail"
      t.string   "state"
      t.boolean  "isok",                                  :default => false
      t.text     "response"
      t.integer  "room_id"
      t.string   "room_name"
      t.string   "machine_host"
      t.string   "command_name",          :limit => 1024
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "directives", ["machine_id"], :name => "index_directives_on_machine_id"
    add_index "directives", ["state"], :name => "index_directives_on_state"

    create_table "envs" do |t|
      t.integer  "app_id"
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "envs", ["name"], :name => "index_envs_on_name"

    create_table "keywords" do |t|
      t.string   "value"
      t.string   "type"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "machine_operations" do |t|
      t.integer  "machine_id"
      t.integer  "operation_id"
      t.integer  "operation_template_id"
      t.datetime "created_at",            :null => false
      t.datetime "updated_at",            :null => false
    end

    create_table "machines" do |t|
      t.string   "name"
      t.string   "host"
      t.integer  "room_id"
      t.integer  "app_id"
      t.integer  "port"
      t.string   "adapter",    :default => "ssh"
      t.string   "user"
      t.string   "password"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "state"
      t.integer  "env_id"
    end

    create_table "operation_restrictions" do |t|
      t.integer  "operation_template_id", :null => false
      t.integer  "env_id",                :null => false
      t.integer  "limit",                 :null => false
      t.string   "limit_cycle",           :null => false
      t.datetime "created_at",            :null => false
      t.datetime "updated_at",            :null => false
    end

    create_table "operation_templates" do |t|
      t.string   "name"
      t.integer  "app_id"
      t.string   "expression"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "begin_script"
    end

    add_index "operation_templates", ["app_id"], :name => "index_operation_templates_on_app_id"

    create_table "operations" do |t|
      t.integer  "operation_template_id"
      t.integer  "operator_id"
      t.integer  "app_id"
      t.string   "name"
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "previous_id"
    end

    add_index "operations", ["app_id"], :name => "index_operations_on_app_id"

    create_table "permissions" do |t|
      t.integer  "app_id"
      t.string   "name"
      t.string   "operation_template_str", :limit => 2048
      t.string   "machine_str",            :limit => 8192
      t.datetime "created_at",                             :null => false
      t.datetime "updated_at",                             :null => false
    end

    add_index "permissions", ["app_id"], :name => "index_permissions_on_app_id"

    create_table "properties" do |t|
      t.integer  "resource_id"
      t.string   "name"
      t.string   "value"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "resource_type"
      t.boolean  "locked"
    end

    add_index "properties", ["name"], :name => "index_envs_on_key"
    add_index "properties", ["resource_id"], :name => "index_envs_on_app_id"

    create_table "release_packs" do |t|
      t.string   "version"
      t.string   "branch"
      t.integer  "app_id"
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "roles" do |t|
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "roles", ["name"], :name => "index_roles_on_name"

    create_table "rooms" do |t|
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "settings" do |t|
      t.string   "var",                      :null => false
      t.text     "value"
      t.integer  "thing_id"
      t.string   "thing_type", :limit => 30
      t.datetime "created_at",               :null => false
      t.datetime "updated_at",               :null => false
    end

    add_index "settings", ["thing_type", "thing_id", "var"], :name => "index_settings_on_thing_type_and_thing_id_and_var", :unique => true

    create_table "softwares" do |t|
      t.string   "name"
      t.integer  "app_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "stakeholders" do |t|
      t.integer  "role_id"
      t.integer  "user_id"
      t.integer  "resource_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "resource_type"
    end

    create_table "taggings" do |t|
      t.integer  "tag_id"
      t.integer  "taggable_id"
      t.string   "taggable_type"
      t.integer  "tagger_id"
      t.string   "tagger_type"
      t.string   "context"
      t.datetime "created_at"
    end

    add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
    add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

    create_table "tags" do |t|
      t.string "name"
    end

    create_table "users" do |t|
      t.string   "email",                                 :default => "", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "users", ["email"], :name => "index_users_on_email", :unique => true

  end
end
