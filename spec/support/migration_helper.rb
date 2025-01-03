module Spec
  module Support
    module MigrationHelper
      module DSL
        def migration_context(direction, &block)
          context "##{direction}", :migrations => direction do
            before(:all) do
              prepare_migrate
            end

            around do |example|
              Rails.logger.debug("============================================================")
              clearing_caches(&example)
            end

            it("with empty tables") { migrate }

            it "STI is disabled for all involved ActiveRecord::Base descendants" do
              classes = described_class.constants.collect do |symbol|
                const = described_class.const_get(symbol)
                const if const.kind_of?(Class) && const < ActiveRecord::Base
              end.compact

              classes_with_type_column_before = classes.select { |klass| DatabaseHelper.table_has_type_column?(klass.table_name) }

              migrate

              classes_with_type_column_after = classes.select { |klass| DatabaseHelper.table_has_type_column?(klass.table_name) }
              (classes_with_type_column_before | classes_with_type_column_after).each do |klass|
                expect(klass.inheritance_column.to_s).to eq("_type_disabled"), "The line `self.inheritance_column = :_type_disabled` is missing from the definition of: #{klass.name}"
              end
            end

            instance_eval(&block)
          end
        end
      end

      def prepare_migrate
        case migration_direction
        when :up then   migrate_to previous_migration_version
        when :down then migrate_to this_migration_version
        end
      end

      def migrate(options = {})
        clearing_caches do
          if options[:verbose] || ENV['VERBOSE_MIGRATION_TESTS']
            migrate_under_test
          else
            suppress_migration_messages { migrate_under_test }
          end
        end
      end

      def migration_stub(klass)
        stub = ar_stubs.detect { |stub| stub.name.split("::").last == klass.to_s }
        raise NameError, "uninitialized constant #{klass} under #{described_class}" if stub.nil?
        stub
      end

      def new_migration_stub(table_name)
        Class.new(ActiveRecord::Base) { self.table_name = table_name.to_s }
      end

      private

      # Clears any cached column information on stubs, since the migrations
      # themselves will not expect anything to be cached.
      def clear_caches
        ar_stubs.each(&:reset_column_information)
        ActiveRecord::Base.connection.schema_cache.clear!
      end

      def clearing_caches
        clear_caches
        yield
      ensure
        clear_caches
      end

      def ar_stubs
        described_class
          .constants
          .collect { |c| described_class.const_get(c) }
          .select  { |c| c.respond_to?(:ancestors) && c.ancestors.include?(ActiveRecord::Base) }
      end

      def migrate_under_test
        Rails.logger.debug("========= migrate start ====================================")
        run_migrate
        Rails.logger.debug("========= migrate complete =================================")
      end

      def migration_direction
        direction = self.class.metadata[:migrations]
        raise "Example must be tagged with :migrations => :up or :migrations => :down" unless direction.in?([:up, :down])
        direction
      end

      def suppress_migration_messages
        save, ActiveRecord::Migration.verbose = ActiveRecord::Migration.verbose, false
        yield
      ensure
        ActiveRecord::Migration.verbose = save
      end

      def migrate_to(version)
        suppress_migration_messages do
          migration_dir  = Rails.application.config.paths["db/migrate"]
          ActiveRecord::MigrationContext.new(migration_dir, schema_migration).migrate(version)
        end
      end

      def this_migration_version
        migrations, i = migrations_and_index
        migrations[i].version
      end

      def previous_migration_version
        migrations, i = migrations_and_index
        return 0 if i == 0
        migrations[i - 1].version
      end

      def run_migrate
        migration_dir  = Rails.application.config.paths["db/migrate"]
        context        = ActiveRecord::MigrationContext.new(migration_dir, schema_migration)

        context.run(migration_direction, this_migration_version)
      end

      def schema_migration
        # Rails 7.2 refactored the schema_migration metadata and context to the pool
        # https://www.github.com/rails/rails/pull/51162
        if Rails.version >= "7.2"
          ::ActiveRecord::Base.connection.pool.schema_migration
        else
          ::ActiveRecord::Base.connection.schema_migration
        end
      end

      def schema_migrations
        migration_dir  = Rails.application.config.paths["db/migrate"]
        ActiveRecord::MigrationContext.new(migration_dir, schema_migration).migrations
      end

      def migrations_and_index
        name = described_class.name.underscore
        migrations = schema_migrations
        i = migrations.index { |m| m.filename.ends_with? "#{name}.rb" }
        raise "Unknown migration for #{described_class}" if i.nil?
        return migrations, i
      end
    end
  end
end
