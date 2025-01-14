# frozen_string_literal: true

class Shrine
  module Plugins
    # Documentation lives in [doc/plugins/refresh_metadata.md] on GitHub.
    #
    # [doc/plugins/refresh_metadata.md]: https://github.com/shrinerb/shrine/blob/master/doc/plugins/refresh_metadata.md
    module RefreshMetadata
      module AttacherMethods
        def refresh_metadata!(**options)
          file.refresh_metadata!(**context, **options)
          set(file)
        end
      end

      module FileMethods
        def refresh_metadata!(**options)
          return open { refresh_metadata!(**options) } unless opened?

          refreshed_metadata = uploader.send(:get_metadata, self, metadata: true, **options)

          @metadata = @metadata.merge(refreshed_metadata)
        end
      end
    end

    register_plugin(:refresh_metadata, RefreshMetadata)
  end
end
