# encoding: utf-8
require 'serienrenamer'
require 'optparse'
require 'fileutils'
require 'hashconfig'
require 'yaml'
require "highline/system_extensions"

module Serienrenamer
  class Cli
    attr_reader :config, :options, :argv_rest, :info_storage

    CONFIG_DIR  = File.join( File.expand_path("~"), ".serienrenamer" )
    CONFIG_FILE = File.join( CONFIG_DIR, "config.yml" )
    STANDARD_CONFIG = {
      :default_directory  => File.join(File.expand_path("~"), "Downloads"),
      :store_episode_info => true,
      :store_path         => File.join(CONFIG_DIR, "information_storage.yml"),
      :byte_count_for_md5 => 2048,
      :illegal_words      => %w{ ML },
      :disabled_plugins   => %w{ NOT_REALLY_A_PLUGIN },
      :force_rename       => false,
    }

    def initialize
      @config, @options, @argv_rest = setup_program_config
      chdir

      @info_storage = Serienrenamer::InformationStore.new(
        @config[:store_path], @config[:byte_count_for_md5]
      )
    end


    def run!
      puts "Plugins loaded: #{registered_plugins.inspect}\n\n"

      Dir.entries('.').sort.each do |entry|
        next if entry.match(/^\./)
        next unless Serienrenamer::Episode.determine_video_file(entry)

        # skip files that already have the right format
        unless options[:process_all_files]
          next if entry.match(/^S\d+E\d+.-.\w+.*\.\w+$/)
        end

        handle_episode entry
      end

    rescue Interrupt
      puts
    ensure
      info_storage.write() if config[:store_episode_info]
    end


    def registered_plugins
      def get_plugins
        registered_plugins = Serienrenamer::Pluginbase.registered_plugins

        registered_plugins.reject! do |plugin|
          config[:disabled_plugins].include? plugin.to_s || ! plugin.usable
        end

        if options[:plugin]  # only leave the wanted plugin
          registered_plugins.reject! do |plugin|
            plugin.to_s !~ /#{options[:plugin]}/i
          end
        end
        registered_plugins.sort {|x,y| y.priority <=> x.priority }
      end

      @plugins ||= get_plugins
    end


    def handle_episode(entry)
      begin
        epi = Serienrenamer::Episode.new(entry, true, config[:illegal_words])
        if options[:series]
          epi.series = options[:series]
        end
      rescue => e
        return
      end

      puts "<<< #{entry}"

      # if episodename is empty than query plugins
      if epi.episodename.match(/\w+/).nil? || options[:ignore_filenamedata]

        registered_plugins.select {|p| p.type == :information}.each do |plugin|

          print "\rAsking '#{ plugin }' for episode information #{' ' * 10}"
          $stdout.flush

          epiname = plugin.generate_episode_information(epi)[0]
          next if epiname == nil

          puts "\n[#{plugin.plugin_name}] - #{epiname}"

          # configure cleanup
          clean_data, extract_seriesname = false, false
          case plugin.plugin_name
          when "Textfile"
            clean_data, extract_seriesname = true, true
          when "SerienjunkiesOrgFeed"
            clean_data = true
          end

          extract_seriesname = false if options[:series]

          epi.add_episode_information(epiname, clean_data, extract_seriesname)
          next unless epi.episodename.match(/\w+/)

          break
        end
      end

      # filter episode name
      registered_plugins.select {|p| p.type == :filter}.each do |plugin|
        epi.episodename = plugin.filter(epi.episodename)
      end

      # rename episode when the user confirms
      puts ">>> #{epi.to_s}"

      if not config[:force_rename]

        print "Filename okay ([jy]/n): "
        char = HighLine::SystemExtensions.get_character

        unless char.chr.match(/[jy\r\n]/i)
          puts "\nwill be skipped ...\n\n"
          return
        end
      end

      info_storage.store(epi) if config[:store_episode_info]

      puts "\n\n"
      epi.rename
    end


    def chdir
      episode_directory = argv_rest.pop || config[:default_directory]

      fail "'#{episode_directory}' does not exist or is not a directory" unless
        Dir.exists?(episode_directory)
      Dir.chdir(episode_directory)
    end


    def setup_program_config
      FileUtils.mkdir(CONFIG_DIR) unless File.directory?(CONFIG_DIR)
      config = STANDARD_CONFIG.merge_with_serialized(CONFIG_FILE)

      ###
      # option definition and handling
      options = {}
      opts = OptionParser.new("Usage: #{$0} [OPTIONS] DIR")
      opts.separator("")
      opts.separator("Ruby Script that brings your series into an")
      opts.separator("appropriate format like 'S01E01 - Episodename.avi'")
      opts.separator("")
      opts.separator("  Options:")

      opts.on( "-p", "--plugin STRING", String,
              "use only this plugin") do |opt|
        options[:plugin] = opt
              end

      opts.on( "-s", "--series STRING", String,
              "series name that will be set for all episodes") do |opt|
        options[:series] = opt
              end

      opts.on( "-S", "--[no-]season",
              "DIR contains episodes of one season of one series") do |opt|
        options[:is_single_season] = opt
              end

      opts.on( "-i", "--[no-]ignore-filenamedata",
              "Always ask plugins for episode information") do |opt|
        options[:ignore_filenamedata] = opt
              end

      opts.on( "-a", "--[no-]all",
              "Process all files (including right formatted files)") do |opt|
        options[:process_all_files] = opt
              end

      opts.on( "-f", "--force",
              "Force rename") do |opt|
        config[:force_rename] = opt
              end

      opts.on( "--showconfig", "Prints the current configuration.") do |opt|
        puts "loaded configuration options:"
        puts config.to_yaml
        exit(0)
      end

      opts.on( "-v", "--version",
              "Prints the version number.") do |opt|
        puts Serienrenamer::VERSION
        exit(0)
              end

      opts.separator("")
      opts.separator("  Arguments:")
      opts.separator("     DIR      The path that includes the episodes")
      opts.separator("              defaults to ~/Downloads/")
      opts.separator("")

      rest = opts.permute(ARGV)
      [ config, options, rest ]
    end
  end
end
