# frozen_string_literal: true

require 'rails/generators'

module Hoardable
  # Generates an initializer file for {Hoardable} configuration and a migration with a PostgreSQL
  # function.
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)
    include Rails::Generators::Migration
    delegate :supports_schema_enums?, to: :class

    def create_initializer_file
      create_file(
        'config/initializers/hoardable.rb',
        <<~TEXT
          # Hoardable configuration defaults are below. Learn more at https://github.com/waymondo/hoardable#configuration
          #
          # Hoardable.enabled = true
          # Hoardable.version_updates = true
          # Hoardable.save_trash = true
        TEXT
      )
    end

    def change_schema_format_to_sql
      return if supports_schema_enums?

      application 'config.active_record.schema_format = :sql'
    end

    def create_migration_file
      migration_template 'install.rb.erb', 'db/migrate/install_hoardable.rb'
    end

    def create_functions
      Dir.glob(File.join(__dir__, 'functions', '*.sql')).each do |file_path|
        file_name = file_path.match(%r{([^/]+)\.sql})[1]
        template file_path, "db/functions/#{file_name}_v01.sql"
      end
    end

    def self.supports_schema_enums?
      ActiveRecord.version >= ::Gem::Version.new('7.0.0')
    end

    def self.next_migration_number(dir)
      ::ActiveRecord::Generators::Base.next_migration_number(dir)
    end
  end
end
