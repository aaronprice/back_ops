# frozen_string_literal: true

# require 'rails/generators'
require 'rails/generators/active_record'

module BackOps
  class InstallGenerator < Rails::Generators::Base
    include ActiveRecord::Generators::Migration
    source_root File.expand_path('templates', __dir__)
    desc 'Installs the BackOps migration file.'

    def create_migrations
      migration_template(
        'create_back_ops_tables.rb',
        'db/migrate/create_back_ops_tables.rb',
        migration_version: migration_version,
      )
      migration_template(
        'update_back_ops_tables_v1.rb',
        'db/migrate/update_back_ops_tables_v1.rb',
        migration_version: migration_version,
      )
    end

    private

    def migration_version
      "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
    end
  end
end