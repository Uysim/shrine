Issue Guidelines
================

1. Issues should only be created for things that are definitely bugs.  If you
   are not sure that the behavior is a bug, ask about it on the [forum].

2. If you are sure it is a bug, then post a complete description of the issue,
   the simplest possible self-contained example showing the problem (see
   Sequel/ActiveRecord templates below), and the full backtrace of any
   exception.

Pull Request Guidelines
=======================

1. Try to include tests for all new features and substantial bug
   fixes.

2. Try to include documentation for all new features.  In most cases
   this should include RDoc method documentation, but updates to the
   README is also appropriate in some cases.

3. Follow the style conventions of the surrounding code.  In most
   cases, this is standard ruby style.

Understanding the codebase
==========================

* The [Design of Shrine] guide gives a general overview of Shrine's core
classes.

* The [Creating a New Plugin] guide and the [Plugin system of Sequel and Roda]
  article explain how Shrine's plugin system works.

* The [Notes on study of shrine implementation] article gives an in-depth
  walkthrough through the Shrine codebase.

Running tests
=============

The test suite requires that you have the following installed:

* [libmagic]
* [SQLite]

If you're using Homebrew, you can just run `brew bundle`. The test suite is
best run using Rake:

```sh
$ rake test
```

Code of Conduct
===============

Everyone interacting in the Shrine project’s codebases, issue trackers, chat
rooms, and mailing lists is expected to follow the [Shrine code of conduct].

Appendix A: Sequel template
============================

```rb
require "sequel"
require "shrine"
require "shrine/storage/file_system"
require "tmpdir"
require "down"

Shrine.storages = {
  cache: Shrine::Storage::FileSystem.new(File.join(Dir.tmpdir, "shrine")),
  store: Shrine::Storage::FileSystem.new(File.join(Dir.tmpdir, "shrine")),
}

Shrine.plugin :sequel

class MyUploader < Shrine
  # plugins and uploading logic
end

DB = Sequel.sqlite # SQLite memory database
DB.create_table :posts do
  primary_key :id
  column :image_data, :text
end

class Post < Sequel::Model
  include MyUploader::Attachment.new(:image)
end

post = Post.create(image: Down.download("https://example.com/image-from-internet.jpg"))

# Your code for reproducing
```

Appendix B: ActiveRecord template
=================================

```rb
require "active_record"
require "shrine"
require "shrine/storage/file_system"
require "tmpdir"
require "down"

Shrine.storages = {
  cache: Shrine::Storage::FileSystem.new(File.join(Dir.tmpdir, "shrine")),
  store: Shrine::Storage::FileSystem.new(File.join(Dir.tmpdir, "shrine")),
}

Shrine.plugin :activerecord

class MyUploader < Shrine
  # plugins and uploading logic
end

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.connection.create_table(:posts) { |t| t.text :image_data }

class Post < ActiveRecord::Base
  include MyUploader::Attachment.new(:image)
end

post = Post.create(image: Down.download("https://example.com/image-from-internet.jpg"))

# Your code for reproducing
```

[forum]: https://discourse.shrinerb.com
[Shrine code of conduct]: https://github.com/shrinerb/shrine/blob/master/CODE_OF_CONDUCT.md
[libmagic]: https://github.com/threatstack/libmagic
[SQLite]: https://www.sqlite.org
[Design of Shrine]: /doc/design.md#readme
[Creating a New Plugin]: /doc/creating_plugins.md#readme
[Plugin system of Sequel and Roda]: https://twin.github.io/the-plugin-system-of-sequel-and-roda/
[Notes on study of shrine implementation]: https://bibwild.wordpress.com/2018/09/12/notes-on-study-of-shrine-implementation/
