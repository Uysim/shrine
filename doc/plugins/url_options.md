# URL Options

The [`url_options`][url_options] plugin allows you to specify
URL options that will be applied by default for uploaded files of specified
storages.

```rb
plugin :url_options, store: { expires_in: 24*60*60 }
```

You can also generate the default URL options dynamically by using a block,
which will receive the UploadedFile object along with any options that were
passed to `UploadedFile#url`.

```rb
plugin :url_options, store: -> (io, options) do
  { response_content_disposition: ContentDisposition.attachment(io.original_filename) }
end
```

In both cases the default options are merged with options passed to
`UploadedFile#url`, and the latter will always have precedence over default
options.

[url_options]: /lib/shrine/plugins/url_options.rb
