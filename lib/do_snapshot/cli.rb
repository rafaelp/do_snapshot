require 'do_snapshot'
require 'do_snapshot/command'
require 'thor'

module DoSnapshot
  # CLI is here
  #
  class CLI < Thor
    default_task :create

    def initialize(*args)
      super
      if options.include? 'log'
        Log.logger       = Logger.new(options['log'])
        Log.thor_log     = Thor::Shell::Color.new
        Log.logger.level = options.include?('trace') ? Logger::DEBUG : Logger::INFO
      end
      try_keys_first
    end

    desc 'create', 'create and cleanup snapshot\'s'
    long_desc <<-LONGDESC
    `do_snapshot create` will create and cleanup snapshots on your droplets.

    You can optionally specify parameters to select or exclude some droplets.

    Advanced options example for MAIL feature:

    --mail to:mail@somehost.com from:from@host.com --smtp address:smtp.gmail.com user_name:someuser password:somepassword

    For more details look here: https://github.com/benprew/pony

    Example:

    > $ do_snapshot --keep 5

    > $ do_snapshot --only 123456 1234567 --store 3

    > $ do_snapshot --exclude 123456 123457

    > $ do_snapshot --keep 10 --stop true --mail to:yourmail@example.com
    LONGDESC
    option :only, type: :array, default: [], aliases: ['-o'], banner: '123456 123456 123456', desc: 'Use only selected droplets.'
    option :exclude, type: :array, default: [], aliases: ['-e'], banner: '123456 123456 123456', desc: 'Except some droplets.'
    option :keep, type: :numeric, default: 10, aliases: ['-k'], banner: '5', desc: 'How much snapshots you want to keep?'
    option :stop, type: :boolean, aliases: ['-s'], banner: 'true', desc: 'Stop creating snapshots if maximum is reached.'
    option :mail, type: :hash, default: {}, aliases: ['-m'], banner: 'to:yourmail@example.com', desc: 'Receive mail if maximum is reached.'
    option :smtp, type: :hash, default: {}, aliases: ['-t'], banner: 'user_name:yourmail@example.com password:password', desc: 'SMTP options.'
    option :log, type: :string, aliases: ['-l'], banner: '/Users/someone/.do_snapshot/main.log', desc: 'Log file path. By default logging is disabled.'
    option :trace, type: :boolean, aliases: ['-d'], desc: 'Debug mode. Not implented now. Switched only log mode.'
    def create
      DoSnapshot::Command.execute options, %w( log trace )
    rescue => e
      Log.error e.message
      backtrace(e) if options.include? 'trace'
    end

    protected

    def backtrace(e)
      e.backtrace.each do |t|
        Log.error t
      end
    end

    # Check DigitalOcean API keys
    def try_keys_first
      Log.debug 'Checking DigitalOcean Id\'s.'
      fail Thor::Error, 'You must have DIGITAL_OCEAN_CLIENT_ID in environment.' if !ENV['DIGITAL_OCEAN_CLIENT_ID'] || ENV['DIGITAL_OCEAN_CLIENT_ID'].empty?
      fail Thor::Error, 'You must have DIGITAL_OCEAN_API_KEY in environment.' if !ENV['DIGITAL_OCEAN_API_KEY'] || ENV['DIGITAL_OCEAN_API_KEY'].empty?
    end
  end
end