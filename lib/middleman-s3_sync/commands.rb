require 'middleman-core/cli'

module Middleman
  module Cli
    class S3Sync < Thor::Group
      include Thor::Actions

      check_unknown_options!

      namespace :s3_sync

      def self.exit_on_failure?
        true
      end

      class_option :force, type: :boolean,
        desc: "Push all local files to the server",
        aliases: '-f'
      class_option :bucket, type: :string,
        desc: "Specify which bucket to use, overrides the configured bucket.",
        aliases: '-b'
      class_option :verbose, type: :boolean,
        desc: "Adds more verbosity...",
        aliases: '-v'
      class_option :dry_run, type: :boolean,
        desc: "Performs a dry run of the sync",
        aliases: '-n'

      class_option :environment,
        aliases: '-e',
        default: ENV['MM_ENV'] || ENV['RACK_ENV'] || 'production',
        desc: 'The environment Middleman will run under'
      class_option :instrument, type: :string,
        default: false,
        desc: 'Print instrument messages'

      def s3_sync
        env = options['environment'].to_sym
        verbose = options['verbose'] ? 0 : 1
        instrument = options['instrument']

        app = ::Middleman::Application.new do
          config[:mode] = :build
          config[:environment] = env
          config[:show_exceptions] = false
          ::Middleman::Logger.singleton(verbose, instrument)
        end


        s3_sync_options = ::Middleman::S3Sync.instance.options

        # Override options based on what was passed on the command line...
        s3_sync_options.force = options[:force] if options[:force]
        s3_sync_options.bucket = options[:bucket] if options[:bucket]
        s3_sync_options.verbose = options[:verbose] if options[:verbose]
        s3_sync_options.dry_run = options[:dry_run] if options[:dry_run]

        bucket = s3_sync_options.bucket rescue nil

        unless bucket
          raise Thor::Error.new 'You need to activate the s3_sync extension and at least provide the bucket name.'
        end

        synchronizer = ::Middleman::S3Sync::Synchronizer.new(app, s3_sync_options)
        synchronizer.sync
      end
    end

    Base.register(Middleman::Cli::S3Sync, 's3_sync', 's3_sync [options]', 'Deploys a middleman site to a S3 bucket')

    Base.map("sync" => "s3_sync")
  end
end
