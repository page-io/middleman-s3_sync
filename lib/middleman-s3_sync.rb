require 'middleman-core'
require 'middleman-s3_sync/commands'

::Middleman::Extensions.register(:s3_sync) do
  require 'middleman-s3_sync/extension'
  ::Middleman::S3Sync::Extension
end
