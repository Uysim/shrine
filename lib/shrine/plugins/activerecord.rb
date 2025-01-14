# frozen_string_literal: true

require "active_record"

class Shrine
  module Plugins
    # Documentation lives in [doc/plugins/activerecord.md] on GitHub.
    #
    # [doc/plugins/activerecord.md]: https://github.com/shrinerb/shrine/blob/master/doc/plugins/activerecord.md
    module Activerecord
      def self.load_dependencies(uploader, **)
        uploader.plugin :model
        uploader.plugin :_persistence, plugin: self
      end

      def self.configure(uploader, **opts)
        uploader.opts[:activerecord] ||= { callbacks: true, validations: true }
        uploader.opts[:activerecord].merge!(opts)
      end

      module AttachmentMethods
        def included(model)
          super

          return unless model < ::ActiveRecord::Base

          name = @name

          if shrine_class.opts[:activerecord][:validations]
            # add validation plugin integration
            model.validate do
              next unless send(:"#{name}_attacher").respond_to?(:errors)

              send(:"#{name}_attacher").errors.each do |message|
                errors.add(name, *message)
              end
            end
          end

          if shrine_class.opts[:activerecord][:callbacks]
            model.before_save do
              if send(:"#{name}_attacher").changed?
                send(:"#{name}_attacher").save
              end
            end

            [:create, :update].each do |action|
              model.after_commit on: action do
                if send(:"#{name}_attacher").changed?
                  send(:"#{name}_attacher").finalize
                  send(:"#{name}_attacher").persist
                end
              end
            end

            model.after_commit on: :destroy do
              send(:"#{name}_attacher").destroy_attached
            end
          end

          # reload the attacher on record reload
          define_method :reload do |*args|
            result = super(*args)
            instance_variable_set(:"@#{name}_attacher", nil)
            result
          end
        end
      end

      # The _persistence plugin uses #activerecord_persist,
      # #activerecord_reload and #activerecord? to implement the following
      # methods:
      #
      #   * Attacher#persist
      #   * Attacher#atomic_persist
      #   * Attacher#atomic_promote
      module AttacherMethods
        private

        # Saves changes to the model instance, skipping validations. Used by
        # the _persistence plugin.
        def activerecord_persist
          record.save(validate: false)
        end

        # Locks the database row and yields the reloaded record. Used by the
        # _persistence plugin.
        def activerecord_reload
          record.transaction { yield record.clone.reload(lock: true) }
        end

        # Returns true if the data attribute represents a JSON or JSONB column.
        # Used by the _persistence plugin to determine whether serialization
        # should be skipped.
        def activerecord_hash_attribute?
          column = record.class.columns_hash[attribute.to_s]
          column && [:json, :jsonb].include?(column.type)
        end

        # Returns whether the record is an ActiveRecord model. Used by the
        # _persistence plugin.
        def activerecord?
          record.is_a?(::ActiveRecord::Base)
        end
      end
    end

    register_plugin(:activerecord, Activerecord)
  end
end
