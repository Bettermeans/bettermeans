# This file is auto-generated from the current state of the database. Instead of editing this file,
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110330041648) do

  create_table "activity_stream_preferences", :force => true do |t|
    t.string   "activity"
    t.string   "location"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activity_stream_preferences", ["activity", "user_id"], :name => "activity_stream_preferences_idx"

  create_table "activity_stream_totals", :force => true do |t|
    t.string   "activity"
    t.integer  "object_id"
    t.string   "object_type"
    t.float    "total",       :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activity_stream_totals", ["activity", "object_id", "object_type"], :name => "activity_stream_totals_idx"

  create_table "activity_streams", :force => true do |t|
    t.string   "verb"
    t.string   "activity"
    t.integer  "actor_id"
    t.string   "actor_type"
    t.string   "actor_name_method"
    t.integer  "count",                       :default => 1
    t.integer  "object_id"
    t.string   "object_type"
    t.string   "object_name_method"
    t.integer  "indirect_object_id"
    t.string   "indirect_object_type"
    t.string   "indirect_object_name_method"
    t.string   "indirect_object_phrase"
    t.integer  "status",                      :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id",                  :default => 0
    t.string   "actor_name"
    t.string   "object_name"
    t.text     "object_description"
    t.string   "indirect_object_name"
    t.text     "indirect_object_description"
    t.string   "tracker_name"
    t.string   "project_name"
    t.string   "actor_email"
    t.boolean  "is_public",                   :default => false
    t.integer  "hidden_from_user_id",         :default => 0
  end

  add_index "activity_streams", ["actor_id", "actor_type"], :name => "activity_streams_by_actor"
  add_index "activity_streams", ["indirect_object_id", "indirect_object_type"], :name => "activity_streams_by_indirect_object"
  add_index "activity_streams", ["object_id", "object_type"], :name => "activity_streams_by_object"

  create_table "attachments", :force => true do |t|
    t.integer  "container_id",                 :default => 0,  :null => false
    t.string   "container_type", :limit => 30, :default => "", :null => false
    t.string   "filename",                     :default => "", :null => false
    t.string   "disk_filename",                :default => "", :null => false
    t.integer  "filesize",                     :default => 0,  :null => false
    t.string   "content_type",                 :default => ""
    t.string   "digest",         :limit => 40, :default => "", :null => false
    t.integer  "downloads",                    :default => 0,  :null => false
    t.integer  "author_id",                    :default => 0,  :null => false
    t.datetime "created_at"
    t.string   "description"
  end

  add_index "attachments", ["author_id"], :name => "index_attachments_on_author_id"
  add_index "attachments", ["container_id", "container_type"], :name => "index_attachments_on_container_id_and_container_type"
  add_index "attachments", ["created_at"], :name => "index_attachments_on_created_at"

  create_table "auth_sources", :force => true do |t|
    t.string  "type",              :limit => 30, :default => "",    :null => false
    t.string  "name",              :limit => 60, :default => "",    :null => false
    t.string  "host",              :limit => 60
    t.integer "port"
    t.string  "account"
    t.string  "account_password",  :limit => 60
    t.string  "base_dn"
    t.string  "attr_login",        :limit => 30
    t.string  "attr_firstname",    :limit => 30
    t.string  "attr_lastname",     :limit => 30
    t.string  "attr_mail",         :limit => 30
    t.boolean "onthefly_register",               :default => false, :null => false
    t.boolean "tls",                             :default => false, :null => false
  end

  add_index "auth_sources", ["id", "type"], :name => "index_auth_sources_on_id_and_type"

  create_table "boards", :force => true do |t|
    t.integer "project_id",                      :null => false
    t.string  "name",            :default => "", :null => false
    t.string  "description"
    t.integer "position",        :default => 1
    t.integer "topics_count",    :default => 0,  :null => false
    t.integer "messages_count",  :default => 0,  :null => false
    t.integer "last_message_id"
  end

  add_index "boards", ["last_message_id"], :name => "index_boards_on_last_message_id"
  add_index "boards", ["project_id"], :name => "boards_project_id"

  create_table "comments", :force => true do |t|
    t.string   "commented_type", :limit => 30, :default => "", :null => false
    t.integer  "commented_id",                 :default => 0,  :null => false
    t.integer  "author_id",                    :default => 0,  :null => false
    t.text     "comments"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
  end

  add_index "comments", ["author_id"], :name => "index_comments_on_author_id"
  add_index "comments", ["commented_id", "commented_type"], :name => "index_comments_on_commented_id_and_commented_type"

  create_table "credit_distributions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.integer  "retro_id"
    t.float    "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "credit_transfers", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.integer  "project_id"
    t.float    "amount"
    t.string   "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "credits", :force => true do |t|
    t.float    "amount",                       :null => false
    t.datetime "issued_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.integer  "project_id"
    t.datetime "settled_on"
    t.boolean  "enabled",    :default => true
  end

  add_index "credits", ["owner_id"], :name => "index_credits_on_owner_id"
  add_index "credits", ["project_id"], :name => "index_credits_on_project_id"

  create_table "daily_digests", :force => true do |t|
    t.integer  "issue_id"
    t.integer  "journal_id"
    t.string   "mail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "documents", :force => true do |t|
    t.integer  "project_id",                :default => 0,  :null => false
    t.string   "title",       :limit => 60, :default => "", :null => false
    t.text     "description"
    t.datetime "created_at"
  end

  add_index "documents", ["created_at"], :name => "index_documents_on_created_on"
  add_index "documents", ["project_id"], :name => "documents_project_id"

  create_table "email_updates", :force => true do |t|
    t.integer  "user_id"
    t.string   "mail"
    t.string   "token"
    t.boolean  "activated",  :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "enabled_modules", :force => true do |t|
    t.integer "project_id"
    t.string  "name",       :null => false
  end

  add_index "enabled_modules", ["project_id"], :name => "enabled_modules_project_id"

  create_table "enterprises", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "homepage",    :default => ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "enumerations", :force => true do |t|
    t.string  "opt",        :limit => 4,  :default => "",    :null => false
    t.string  "name",       :limit => 30, :default => "",    :null => false
    t.integer "position",                 :default => 1
    t.boolean "is_default",               :default => false, :null => false
    t.string  "type"
    t.boolean "active",                   :default => true,  :null => false
    t.integer "project_id"
    t.integer "parent_id"
  end

  add_index "enumerations", ["id", "type"], :name => "index_enumerations_on_id_and_type"
  add_index "enumerations", ["project_id"], :name => "index_enumerations_on_project_id"

  create_table "help_sections", :force => true do |t|
    t.integer  "user_id",    :default => 0,    :null => false
    t.string   "name"
    t.boolean  "show",       :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hourly_types", :force => true do |t|
    t.integer  "project_id"
    t.string   "name"
    t.decimal  "hourly_rate_per_person", :precision => 8, :scale => 2
    t.decimal  "hourly_cap",             :precision => 8, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invitations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.string   "token"
    t.integer  "status",     :default => 0
    t.integer  "role_id"
    t.string   "mail"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "new_mail"
  end

  create_table "issue_relations", :force => true do |t|
    t.integer "issue_from_id",                 :null => false
    t.integer "issue_to_id",                   :null => false
    t.string  "relation_type", :default => "", :null => false
    t.integer "delay"
  end

  add_index "issue_relations", ["issue_from_id"], :name => "index_issue_relations_on_issue_from_id"
  add_index "issue_relations", ["issue_to_id"], :name => "index_issue_relations_on_issue_to_id"

  create_table "issue_statuses", :force => true do |t|
    t.string  "name",               :limit => 30, :default => "",    :null => false
    t.boolean "is_closed",                        :default => false, :null => false
    t.boolean "is_default",                       :default => false, :null => false
    t.integer "position",                         :default => 1
    t.integer "default_done_ratio"
  end

  add_index "issue_statuses", ["is_closed"], :name => "index_issue_statuses_on_is_closed"
  add_index "issue_statuses", ["is_default"], :name => "index_issue_statuses_on_is_default"
  add_index "issue_statuses", ["position"], :name => "index_issue_statuses_on_position"

  create_table "issue_votes", :force => true do |t|
    t.float    "points",                        :null => false
    t.integer  "user_id",                       :null => false
    t.integer  "issue_id",                      :null => false
    t.integer  "vote_type",                     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "isbinding",  :default => false
  end

  add_index "issue_votes", ["issue_id"], :name => "index_issue_votes_on_issue_id"
  add_index "issue_votes", ["user_id"], :name => "index_issue_votes_on_user_id"
  add_index "issue_votes", ["vote_type"], :name => "index_issue_votes_on_vote_type"

  create_table "issues", :force => true do |t|
    t.integer  "tracker_id",           :default => 0,  :null => false
    t.integer  "project_id",           :default => 0,  :null => false
    t.string   "subject",              :default => "", :null => false
    t.text     "description"
    t.date     "due_date"
    t.integer  "status_id",            :default => 0,  :null => false
    t.integer  "assigned_to_id"
    t.integer  "author_id",            :default => 0,  :null => false
    t.integer  "lock_version",         :default => 0,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "start_date"
    t.integer  "done_ratio",           :default => 0,  :null => false
    t.float    "estimated_hours"
    t.date     "expected_date"
    t.float    "points"
    t.integer  "pri",                  :default => 0
    t.integer  "accept",               :default => 0
    t.integer  "reject",               :default => 0
    t.integer  "accept_total",         :default => 0
    t.integer  "agree",                :default => 0
    t.integer  "disagree",             :default => 0
    t.integer  "agree_total",          :default => 0
    t.integer  "retro_id"
    t.integer  "accept_nonbind",       :default => 0
    t.integer  "reject_nonbind",       :default => 0
    t.integer  "accept_total_nonbind", :default => 0
    t.integer  "agree_nonbind",        :default => 0
    t.integer  "disagree_nonbind",     :default => 0
    t.integer  "agree_total_nonbind",  :default => 0
    t.integer  "points_nonbind",       :default => 0
    t.integer  "pri_nonbind",          :default => 0
    t.integer  "hourly_type_id"
    t.integer  "num_hours",            :default => 0
    t.string   "tags_copy"
  end

  add_index "issues", ["assigned_to_id"], :name => "index_issues_on_assigned_to_id"
  add_index "issues", ["author_id"], :name => "index_issues_on_author_id"
  add_index "issues", ["created_at"], :name => "index_issues_on_created_at"
  add_index "issues", ["project_id"], :name => "issues_project_id"
  add_index "issues", ["status_id"], :name => "index_issues_on_status_id"
  add_index "issues", ["tracker_id"], :name => "index_issues_on_tracker_id"

  create_table "journal_details", :force => true do |t|
    t.integer "journal_id",               :default => 0,  :null => false
    t.string  "property",   :limit => 30, :default => "", :null => false
    t.string  "prop_key",   :limit => 30, :default => "", :null => false
    t.string  "old_value"
    t.string  "value"
  end

  add_index "journal_details", ["journal_id"], :name => "journal_details_journal_id"

  create_table "journals", :force => true do |t|
    t.integer  "journalized_id",                 :default => 0,  :null => false
    t.string   "journalized_type", :limit => 30, :default => "", :null => false
    t.integer  "user_id",                        :default => 0,  :null => false
    t.text     "notes"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at"
  end

  add_index "journals", ["created_at"], :name => "index_journals_on_created_at"
  add_index "journals", ["journalized_id", "journalized_type"], :name => "journals_journalized_id"
  add_index "journals", ["journalized_id"], :name => "index_journals_on_journalized_id"
  add_index "journals", ["user_id"], :name => "index_journals_on_user_id"

  create_table "mail_handlers", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mails", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.boolean  "sender_deleted",    :default => false
    t.boolean  "recipient_deleted", :default => false
    t.string   "subject"
    t.text     "body"
    t.datetime "read_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "member_roles", :force => true do |t|
    t.integer  "member_id"
    t.integer  "role_id"
    t.integer  "inherited_from"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "member_roles", ["member_id"], :name => "index_member_roles_on_member_id"
  add_index "member_roles", ["role_id"], :name => "index_member_roles_on_role_id"

  create_table "members", :force => true do |t|
    t.integer  "user_id",           :default => 0,     :null => false
    t.integer  "project_id",        :default => 0,     :null => false
    t.datetime "created_at"
    t.boolean  "mail_notification", :default => false, :null => false
  end

  add_index "members", ["project_id"], :name => "index_members_on_project_id"
  add_index "members", ["user_id"], :name => "index_members_on_user_id"

  create_table "messages", :force => true do |t|
    t.integer  "board_id",                         :null => false
    t.integer  "parent_id"
    t.string   "subject",       :default => "",    :null => false
    t.text     "content"
    t.integer  "author_id"
    t.integer  "replies_count", :default => 0,     :null => false
    t.integer  "last_reply_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.boolean  "locked",        :default => false
    t.integer  "sticky",        :default => 0
  end

  add_index "messages", ["author_id"], :name => "index_messages_on_author_id"
  add_index "messages", ["board_id"], :name => "messages_board_id"
  add_index "messages", ["created_at"], :name => "index_messages_on_created_at"
  add_index "messages", ["last_reply_id"], :name => "index_messages_on_last_reply_id"
  add_index "messages", ["parent_id"], :name => "messages_parent_id"

  create_table "motion_votes", :force => true do |t|
    t.integer  "motion_id"
    t.integer  "user_id"
    t.integer  "points"
    t.boolean  "isbinding",  :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "motions", :force => true do |t|
    t.integer  "project_id"
    t.string   "title"
    t.text     "description"
    t.text     "params"
    t.integer  "variation",           :default => 0
    t.integer  "motion_type",         :default => 2
    t.integer  "visibility_level",    :default => 5
    t.integer  "binding_level",       :default => 5
    t.integer  "state",               :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "ends_on"
    t.integer  "topic_id"
    t.integer  "author_id"
    t.integer  "agree",               :default => 0
    t.integer  "disagree",            :default => 0
    t.integer  "agree_total",         :default => 0
    t.integer  "agree_nonbind",       :default => 0
    t.integer  "disagree_nonbind",    :default => 0
    t.integer  "agree_total_nonbind", :default => 0
    t.integer  "concerned_user_id"
  end

  create_table "news", :force => true do |t|
    t.integer  "project_id"
    t.string   "title",          :limit => 60, :default => "", :null => false
    t.string   "summary",                      :default => ""
    t.text     "description"
    t.integer  "author_id",                    :default => 0,  :null => false
    t.datetime "created_at"
    t.integer  "comments_count",               :default => 0,  :null => false
  end

  add_index "news", ["author_id"], :name => "index_news_on_author_id"
  add_index "news", ["created_at"], :name => "index_news_on_created_at"
  add_index "news", ["project_id"], :name => "news_project_id"

  create_table "notifications", :force => true do |t|
    t.integer  "recipient_id"
    t.string   "variation"
    t.text     "params"
    t.integer  "state",        :default => 0
    t.integer  "source_id"
    t.datetime "expiration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sender_id"
    t.string   "source_type"
  end

  add_index "notifications", ["recipient_id"], :name => "index_notifications_on_recipient_id"

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :null => false
    t.string  "server_url"
    t.string  "salt",       :null => false
  end

  create_table "personal_welcomes", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
  end

  create_table "plans", :force => true do |t|
    t.string   "name"
    t.integer  "code"
    t.text     "description"
    t.float    "amount"
    t.integer  "storage_max"
    t.integer  "contributor_max"
    t.integer  "private_workstream_max"
    t.integer  "public_workstream_max"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plugin_schema_info", :id => false, :force => true do |t|
    t.string  "plugin_name"
    t.integer "version"
  end

  create_table "projects", :force => true do |t|
    t.string   "name",                     :limit => 50, :default => "",    :null => false
    t.text     "description"
    t.string   "homepage",                               :default => ""
    t.boolean  "is_public",                              :default => true,  :null => false
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "identifier",               :limit => 20
    t.integer  "status",                                 :default => 1,     :null => false
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "enterprise_id"
    t.datetime "last_item_updated_on"
    t.float    "dpp",                                    :default => 100.0
    t.text     "activity_line"
    t.boolean  "volunteer",                              :default => false
    t.integer  "owner_id"
    t.float    "storage",                                :default => 0.0
    t.integer  "issue_count",                            :default => 0
    t.integer  "activity_total"
    t.string   "invitation_token"
    t.integer  "issue_count_sub",                        :default => 0,     :null => false
    t.datetime "last_item_sub_updated_on"
  end

  add_index "projects", ["enterprise_id"], :name => "index_projects_on_enterprise_id"
  add_index "projects", ["lft"], :name => "index_projects_on_lft"
  add_index "projects", ["rgt"], :name => "index_projects_on_rgt"

  create_table "projects_trackers", :id => false, :force => true do |t|
    t.integer "project_id", :default => 0, :null => false
    t.integer "tracker_id", :default => 0, :null => false
  end

  add_index "projects_trackers", ["project_id", "tracker_id"], :name => "projects_trackers_unique", :unique => true
  add_index "projects_trackers", ["project_id"], :name => "projects_trackers_project_id"

  create_table "queries", :force => true do |t|
    t.integer "project_id"
    t.string  "name",          :default => "",    :null => false
    t.text    "filters"
    t.integer "user_id",       :default => 0,     :null => false
    t.boolean "is_public",     :default => false, :null => false
    t.text    "column_names"
    t.text    "sort_criteria"
    t.string  "group_by"
  end

  add_index "queries", ["project_id"], :name => "index_queries_on_project_id"
  add_index "queries", ["user_id"], :name => "index_queries_on_user_id"

  create_table "quotes", :force => true do |t|
    t.integer  "user_id"
    t.string   "author"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reportable_cache", :force => true do |t|
    t.string   "model_name",       :limit => 100,                  :null => false
    t.string   "report_name",      :limit => 100,                  :null => false
    t.string   "grouping",         :limit => 10,                   :null => false
    t.string   "aggregation",      :limit => 10,                   :null => false
    t.string   "conditions",       :limit => 100,                  :null => false
    t.float    "value",                           :default => 0.0, :null => false
    t.datetime "reporting_period",                                 :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reportable_cache", ["model_name", "report_name", "grouping", "aggregation", "conditions", "reporting_period"], :name => "name_model_grouping_aggregation_period", :unique => true
  add_index "reportable_cache", ["model_name", "report_name", "grouping", "aggregation", "conditions"], :name => "name_model_grouping_agregation"

  create_table "reputations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.integer  "reputation_type"
    t.float    "value"
    t.string   "params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "retro_ratings", :force => true do |t|
    t.integer  "rater_id"
    t.integer  "ratee_id"
    t.float    "score"
    t.integer  "retro_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "confidence", :default => 100
  end

  add_index "retro_ratings", ["ratee_id"], :name => "index_retro_ratings_on_ratee_id"
  add_index "retro_ratings", ["rater_id"], :name => "index_retro_ratings_on_rater_id"

  create_table "retros", :force => true do |t|
    t.integer  "status_id"
    t.integer  "project_id"
    t.datetime "from_date"
    t.datetime "to_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "total_points"
  end

  add_index "retros", ["project_id"], :name => "index_retros_on_project_id"

  create_table "roles", :force => true do |t|
    t.string  "name",        :limit => 30, :default => "",   :null => false
    t.integer "position",                  :default => 1
    t.boolean "assignable",                :default => true
    t.integer "builtin",                   :default => 0,    :null => false
    t.text    "permissions"
    t.integer "level",                     :default => 3
  end

  create_table "settings", :force => true do |t|
    t.string   "name",       :default => "", :null => false
    t.text     "value"
    t.datetime "updated_at"
  end

  add_index "settings", ["name"], :name => "index_settings_on_name"

  create_table "shares", :force => true do |t|
    t.float    "amount",                    :null => false
    t.datetime "expires"
    t.integer  "variation",  :default => 2, :null => false
    t.datetime "issued_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.integer  "owner_id"
  end

  add_index "shares", ["owner_id"], :name => "index_shares_on_owner_id"
  add_index "shares", ["project_id"], :name => "index_shares_on_project_id"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at"
    t.integer  "project_id"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "todos", :force => true do |t|
    t.string   "subject"
    t.integer  "author_id"
    t.integer  "owner_id"
    t.integer  "issue_id"
    t.datetime "completed_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "owner_login"
  end

  add_index "todos", ["author_id"], :name => "index_todos_on_author_id"
  add_index "todos", ["owner_id"], :name => "index_todos_on_owner_id"

  create_table "tokens", :force => true do |t|
    t.integer  "user_id",                  :default => 0,  :null => false
    t.string   "action",     :limit => 30, :default => "", :null => false
    t.string   "value",      :limit => 40, :default => "", :null => false
    t.datetime "created_at",                               :null => false
  end

  add_index "tokens", ["user_id"], :name => "index_tokens_on_user_id"

  create_table "trackers", :force => true do |t|
    t.string  "name",               :limit => 30, :default => "",    :null => false
    t.boolean "is_in_chlog",                      :default => false, :null => false
    t.integer "position",                         :default => 1
    t.boolean "is_in_roadmap",                    :default => true,  :null => false
    t.boolean "for_credits_module",               :default => false
  end

  create_table "tracks", :force => true do |t|
    t.integer  "user_id"
    t.integer  "code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip"
  end

  create_table "user_preferences", :force => true do |t|
    t.integer "user_id",           :default => 0,    :null => false
    t.text    "others"
    t.boolean "hide_mail",         :default => true
    t.string  "time_zone"
    t.boolean "active_only_jumps", :default => true
  end

  add_index "user_preferences", ["user_id"], :name => "index_user_preferences_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "login",                 :limit => 30, :default => "",    :null => false
    t.string   "hashed_password",       :limit => 40, :default => "",    :null => false
    t.string   "firstname",             :limit => 30, :default => "",    :null => false
    t.string   "lastname",              :limit => 30, :default => "",    :null => false
    t.string   "mail",                  :limit => 60, :default => "",    :null => false
    t.boolean  "mail_notification",                   :default => true,  :null => false
    t.boolean  "admin",                               :default => false, :null => false
    t.integer  "status",                              :default => 1,     :null => false
    t.datetime "last_login_on"
    t.string   "language",              :limit => 5,  :default => ""
    t.integer  "auth_source_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.string   "identity_url"
    t.string   "activity_stream_token"
    t.string   "identifier"
    t.integer  "plan_id",                             :default => 1
    t.string   "b_first_name"
    t.string   "b_last_name"
    t.string   "b_address1"
    t.string   "b_zip"
    t.string   "b_country"
    t.string   "b_phone"
    t.string   "b_ip_address"
    t.string   "b_cc_last_four"
    t.string   "b_cc_type"
    t.integer  "b_cc_month"
    t.integer  "b_cc_year"
    t.string   "mail_hash"
    t.datetime "trial_expires_on"
    t.boolean  "active_subscription",                 :default => false
    t.datetime "usage_over_at"
    t.datetime "trial_expired_at"
  end

  add_index "users", ["auth_source_id"], :name => "index_users_on_auth_source_id"
  add_index "users", ["id", "type"], :name => "index_users_on_id_and_type"

  create_table "votes", :force => true do |t|
    t.boolean  "vote",          :default => false
    t.integer  "voteable_id",                      :null => false
    t.string   "voteable_type",                    :null => false
    t.integer  "voter_id"
    t.string   "voter_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["voteable_id", "voteable_type", "voter_id", "voter_type"], :name => "uniq_one_vote_only", :unique => true
  add_index "votes", ["voteable_id", "voteable_type"], :name => "fk_voteables"
  add_index "votes", ["voter_id", "voter_type"], :name => "fk_voters"

  create_table "watchers", :force => true do |t|
    t.string  "watchable_type", :default => "", :null => false
    t.integer "watchable_id",   :default => 0,  :null => false
    t.integer "user_id"
  end

  add_index "watchers", ["user_id", "watchable_type"], :name => "watchers_user_id_type"
  add_index "watchers", ["user_id"], :name => "index_watchers_on_user_id"
  add_index "watchers", ["watchable_id", "watchable_type"], :name => "index_watchers_on_watchable_id_and_watchable_type"

  create_table "wiki_content_versions", :force => true do |t|
    t.integer  "wiki_content_id",                              :null => false
    t.integer  "page_id",                                      :null => false
    t.integer  "author_id"
    t.binary   "data"
    t.string   "compression",     :limit => 6, :default => ""
    t.string   "comments",                     :default => ""
    t.datetime "updated_at",                                   :null => false
    t.integer  "version",                                      :null => false
  end

  add_index "wiki_content_versions", ["updated_at"], :name => "index_wiki_content_versions_on_updated_at"
  add_index "wiki_content_versions", ["wiki_content_id"], :name => "wiki_content_versions_wcid"

  create_table "wiki_contents", :force => true do |t|
    t.integer  "page_id",                    :null => false
    t.integer  "author_id"
    t.text     "text"
    t.string   "comments",   :default => ""
    t.datetime "updated_at",                 :null => false
    t.integer  "version",                    :null => false
  end

  add_index "wiki_contents", ["author_id"], :name => "index_wiki_contents_on_author_id"
  add_index "wiki_contents", ["page_id"], :name => "wiki_contents_page_id"

  create_table "wiki_pages", :force => true do |t|
    t.integer  "wiki_id",                       :null => false
    t.string   "title",                         :null => false
    t.datetime "created_at",                    :null => false
    t.boolean  "protected",  :default => false, :null => false
    t.integer  "parent_id"
  end

  add_index "wiki_pages", ["parent_id"], :name => "index_wiki_pages_on_parent_id"
  add_index "wiki_pages", ["title", "wiki_id"], :name => "wiki_pages_wiki_id_title"
  add_index "wiki_pages", ["wiki_id"], :name => "index_wiki_pages_on_wiki_id"

  create_table "wiki_redirects", :force => true do |t|
    t.integer  "wiki_id",      :null => false
    t.string   "title"
    t.string   "redirects_to"
    t.datetime "created_at",   :null => false
  end

  add_index "wiki_redirects", ["title", "wiki_id"], :name => "wiki_redirects_wiki_id_title"
  add_index "wiki_redirects", ["wiki_id"], :name => "index_wiki_redirects_on_wiki_id"

  create_table "wikis", :force => true do |t|
    t.integer "project_id",                :null => false
    t.string  "start_page",                :null => false
    t.integer "status",     :default => 1, :null => false
  end

  add_index "wikis", ["project_id"], :name => "wikis_project_id"

  create_table "workflows", :force => true do |t|
    t.integer "tracker_id",    :default => 0, :null => false
    t.integer "old_status_id", :default => 0, :null => false
    t.integer "new_status_id", :default => 0, :null => false
    t.integer "role_id",       :default => 0, :null => false
  end

  add_index "workflows", ["new_status_id"], :name => "index_workflows_on_new_status_id"
  add_index "workflows", ["old_status_id", "role_id", "tracker_id"], :name => "wkfs_role_tracker_old_status"
  add_index "workflows", ["old_status_id"], :name => "index_workflows_on_old_status_id"
  add_index "workflows", ["role_id"], :name => "index_workflows_on_role_id"

end
