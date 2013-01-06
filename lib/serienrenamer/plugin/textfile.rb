#
# Class that searches for a file with
# episode information in the directory
# like "episode.txt"
#
require 'serienrenamer'

module Serienrenamer
  module Plugin

    class Textfile < Serienrenamer::Pluginbase

      def self.plugin_name; "Textfile" end
      def self.usable; true end
      def self.priority; 100 end

      # this method will be called from the main program
      # with an Serienrenamer::Episode instance or a path
      # to to a directory as parameter
      #
      # it returns an array of episode information
      def self.generate_episode_information(episode)

        sourcedir = ""
        if episode.is_a?(Serienrenamer::Episode) && episode.source_directory
          sourcedir = episode.source_directory
        elsif episode.is_a?(String) && File.directory?(episode)
          sourcedir = episode
        end

        matched_episodes = []

        if sourcedir != "" && Dir.exists?(sourcedir)

          # search for files that are smaller than 128 Bytes
          # an check if they contain episode information
          Dir.new(sourcedir).each do |e|
            file = File.join(sourcedir, e)
            next if File.size(file) > 128 || File.zero?(file)

            data = File.open(file, "rb").read

            # only files with one line with the title are interesting
            next if data.lines.to_a.size > 1

            if data != nil && data.match(/\w+/) &&
              Serienrenamer::Episode.contains_episode_information?(data)
              matched_episodes.push(data)
            end
          end
        end

        return matched_episodes
      end
    end
  end
end
