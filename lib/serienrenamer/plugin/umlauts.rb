# encoding: utf-8
require 'wlapi'

module Serienrenamer
  module Plugin

    class Umlauts < Serienrenamer::Pluginbase

      def self.plugin_name; "Umlauts" end
      def self.usable; true end
      def self.priority; 150 end
      def self.type; :filter end

      # This method is called from outside with the full episodename as
      # parameter and it should return the manipulated episodename
      def self.filter(episode_name)
        episode_name.split.map {|e| repair_umlauts(e) }.join(" ")
      end


      # This method tries to repair some german umlauts so that
      # the following occurs
      #
      # ae => ä ; ue => ü ; oe => ö ; Ae => Ä ; Ue => Ü ; Oe => Ö
      #
      # This method uses a webservice at:
      #   http://wortschatz.uni-leipzig.de/
      # which produces statistics about the german language and
      # e.g. frequency of words occuring in the german language
      #
      # this method convert all broken umlauts in the word and compares
      # the frequency of both version and uses the version which is more
      # common
      #
      # returns a repaired version of the word if necessary
      def self.repair_umlauts(word)

        if contains_eventual_broken_umlauts?(word)
          @@client ||= WLAPI::API.new

          repaired = word.gsub(/ae/, 'ä').gsub(/ue/, 'ü').gsub(/oe/, 'ö')
          repaired.gsub!(/^Ae/, 'Ä')
          repaired.gsub!(/^Ue/, 'Ü')
          repaired.gsub!(/^Oe/, 'Ö')

          res_broken  = @@client.frequencies(word)
          freq_broken = res_broken.nil? ? -1 : res_broken[0].to_i

          res_repaired  = @@client.frequencies(repaired)
          freq_repaired = res_repaired.nil? ? -1 : res_repaired[0].to_i

          if freq_repaired > freq_broken
            return repaired
          end
        end

        word
      end

      # checks for eventual broken umlauts
      #
      # returns true if broken umlaut if included
      def self.contains_eventual_broken_umlauts?(string)
        ! string.match(/ae|ue|oe|Ae|Ue|Oe/).nil?
      end

    end
  end
end

