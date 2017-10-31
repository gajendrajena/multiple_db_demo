# README

This application is to demonstrate how to connect to multiple databases from a rails application.

Steps
1. create a rails application

2. along with database.yml add the database config through a secondary yml file
ex:

#database_sec.yml

  development:
    adapter: postgresql
    encoding: unicode
    pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
    database: multiple_db_demo_development_sec

3. add an initializer to load the database configuration
  config/initializers/db_sec.rb
    DB_SEC = YAML::load(ERB.new(File.read(Rails.root.join("config","database_sec.yml"))).result)[Rails.env]

4. Add folder structure for managing migrations, schema.rb, seeds.rb and schema_migrations
  multiple_db_demo
    - db
      - migrate
      - schema.rb
    - db_sec
      - migrate
      - schema.rb

6. create tasks and namespaces to manage db_sec specific tasks

  #lib/tasks/db_sec.rake
  task spec: ["sec:db:test:prepare"]

  namespace :sec do

    namespace :db do |ns|

      task :drop do
        Rake::Task["db:drop"].invoke
      end

      task :create do
        Rake::Task["db:create"].invoke
      end

      task :setup do
        Rake::Task["db:setup"].invoke
      end

      task :migrate do
        Rake::Task["db:migrate"].invoke
      end

      task :rollback do
        Rake::Task["db:rollback"].invoke
      end

      task :seed do
        Rake::Task["db:seed"].invoke
      end

      task :version do
        Rake::Task["db:version"].invoke
      end

      namespace :schema do
        task :load do
          Rake::Task["db:schema:load"].invoke
        end

        task :dump do
          Rake::Task["db:schema:dump"].invoke
        end
      end

      namespace :test do
        task :prepare do
          Rake::Task["db:test:prepare"].invoke
        end
      end

      # append and prepend proper tasks to all the tasks defined here above
      ns.tasks.each do |task|
        task.enhance ["sec:set_custom_config"] do
          Rake::Task["sec:revert_to_original_config"].invoke
        end
      end
    end

    task :set_custom_config do
      # save current vars
      @original_config = {
        env_schema: ENV['SCHEMA'],
        config: Rails.application.config.dup
      }

      # set config variables for custom database
      ENV['SCHEMA'] = "db_sec/schema.rb"
      Rails.application.config.paths['db'] = ["db_sec"]
      Rails.application.config.paths['db/migrate'] = ["db_sec/migrate"]
      Rails.application.config.paths['db/seeds'] = ["db_sec/seeds.rb"]
      Rails.application.config.paths['config/database'] = ["config/database_sec.yml"]
    end

    task :revert_to_original_config do
      # reset config variables to original values
      ENV['SCHEMA'] = @original_config[:env_schema]
      Rails.application.config = @original_config[:config]
    end
  end


5. Add generator to handle the rails generators

  class SecMigrationGenerator < ActiveRecord::Generators::MigrationGenerator
    source_root File.join(File.dirname(ActiveRecord::Generators::MigrationGenerator.instance_method(:create_migration_file).source_location.first), "templates")

    def create_migration_file
      set_local_assigns!
      validate_file_name!
      migration_template @migration_template, "db_sec/migrate/#{file_name}.rb"
    end
  end