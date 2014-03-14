# encoding: utf-8
require File.dirname(__FILE__) + '/test_helper.rb'

class TestPluginUmlauts < Test::Unit::TestCase

  def test_repairing_umlauts
    VCR.use_cassette("episode_#{method_name}") do
      assert_equal("Duell für Änderung",
            Serienrenamer::Plugin::Umlauts.filter("Duell fuer Aenderung"))

      assert_equal("Zaubersprüche",
                   Serienrenamer::Plugin::Umlauts.filter("Zaubersprueche"))
      assert_equal("Ungeheuerlich",
                   Serienrenamer::Plugin::Umlauts.filter("Ungeheuerlich"))
      assert_equal("Frauen",
                   Serienrenamer::Plugin::Umlauts.filter("Frauen"))
      assert_equal("Abführmittel",
                   Serienrenamer::Plugin::Umlauts.filter("Abfuehrmittel"))
      assert_equal("tödlich",
                   Serienrenamer::Plugin::Umlauts.filter("toedlich"))
      assert_equal("König",
                   Serienrenamer::Plugin::Umlauts.filter("Koenig"))
      assert_equal("Öko",
                   Serienrenamer::Plugin::Umlauts.filter("Oeko"))
      assert_equal("Männer",
                   Serienrenamer::Plugin::Umlauts.filter("Maenner"))
      assert_equal("Draufgänger",
                   Serienrenamer::Plugin::Umlauts.filter("Draufgaenger"))
      assert_equal("Unglücksvögel",
                   Serienrenamer::Plugin::Umlauts.filter("Ungluecksvoegel"))
      assert_equal("Jäger",
                   Serienrenamer::Plugin::Umlauts.filter("Jaeger"))
      assert_equal("Loyalität",
                   Serienrenamer::Plugin::Umlauts.filter("Loyalitaet"))
      # both forms do not exist
      assert_equal("Moeback",
                   Serienrenamer::Plugin::Umlauts.filter("Moeback"))
    end
  end
end
