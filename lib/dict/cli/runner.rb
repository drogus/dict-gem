# -*- coding: utf-8 -*-

# Class, which provides using application in Command Line Interface.

require 'dict/dict'
require 'dict/version'
require 'slop'
require 'timeout'

module Dict
  module CLI
    class Runner

      def parameters_valid?
        not ARGV.empty?
      end

      def parse_parameters
        opts = Slop.parse! do
          banner <<-END
Przykład użycia: dict SŁOWO [OPCJE]
Wyszukaj SŁOWO w dict, open-source'owym agregatorze słowników.
          END

          on '-h', :help=, 'Wyświetl pomoc', :argument => :optional
          on '-t', :time=, 'Ustaw limit czasu żądania w sekundach. Domyślnie: 300', :as => :int
          on '-d', :dict=, "Wybierz słownik. Dostępne są : #{Dict.available_dictionaries.join(', ')}"
          on '-v', :version=, "Informacje o gemie, autorach, licencji", :argument => :optional
          on '-c', :clean=, "Nie wyświetlaj przykładów użycia", :argument => :optional

        end
      end

      def get_translations(opts, word)
         Timeout::timeout(opts[:time].to_i || 300) do
          if opts.dict?
            Dict.get_single_dictionary_translations(word, opts[:dict])
          else
            Dict.get_all_dictionaries_translations(word)
          end
        end
      rescue Timeout::Error
        "Upłynął limit czasu żądania."
      end

      def expected_argument_description(option)
        case option
        when "dict"
          Dict.available_dictionaries.join(', ')
        when "time"
          "liczba sekund"
        else
          "?"
        end
      end

      MSG = "Przykład użycia: dict SŁOWO [OPCJE]\n `dict --help, aby uzyskać więcej informacji.\n"
      VERSION = "dict wersja #{Dict::VERSION}\nWyszukaj SŁOWO w dict, open-source'owym agregatorze słowników. \nCopyright (C) 2012 by\nZespół:\n  Jan Borwin\n  Mateusz Czerwiński\n  Kosma Dunikowski\n  Aleksander Gozdek\n  Rafał Ośko\n  Michał Podlecki\nMentorzy:\n  Grzegorz Kołodziejski\n  Michał Kwiatkowski\nLicencja: MIT\nStworzono na praktykach w : http://ragnarson.com/\nHosting: Shelly Cloud :\t http://shellycloud.com/\nStrona domowa:\t\t http://github.com/Ragnarson/dict-gem/\nSłowniki:\t\t http://wiktionary.org/\n\t\t\t http://glosbe.com/\n"

     # Returns array without duplicates
      def clean_translation(results)
        clean = []
        results.each do |_, translations_hash|
          translations_hash.each do |_, translations|
            clean.concat(translations)
          end
        end
        clean.uniq
      end

      # Prints translations from all dictionaries
      def print_all_dictionaries_translations(results)
        results.each do |dictionary, translations_hash|
          puts "Nazwa słownika - #{dictionary.upcase}"
          print_translations(translations_hash)
        end
      end

      # Prints translations for given Hash or Array
      def print_translations(results)
        if results.empty?
          puts 'Przepraszamy, ale w wybranym słowniku nie znaleziono tłumaczenia.'
        else
          if results.instance_of?(Hash)
            results.each do |_, translations|
              print_array(translations)
            end
          elsif results.instance_of?(Array)
            print_array(results)
          end
        end
      end

      # Prints array elements one by one vertically
      def print_array(arr)
        translations_string = case arr.size
          when 1 then "tłumaczenie"
          when 2..4 then "tłumaczenia"
          else "tłumaczeń"
        end

        puts "Znaleziono: #{arr.size} #{translations_string}"
        arr.each { |el| puts "- #{el}" }
      end

      def run
        begin
          opts = parse_parameters
        rescue Slop::MissingArgumentError => e
          incomplete_option = /(.*?) expects an argument/.match(e.to_s)[1]
          description = expected_argument_description(incomplete_option)
          abort("Brakujący argument. Spodziewano: #{description}")
        end

        if opts.help?
          abort(opts.to_s)
        elsif opts.version?
          abort(VERSION)
        elsif opts.time?
          if (opts[:time].to_i) == 0
            abort("Nieprawidłowa wartość czasu.")
          else
            print_all_dictionaries_translations(get_translations(opts, ARGV[0]))
          end
        else
          if !parameters_valid?
            abort(MSG)
          else
            if opts.clean? && !opts.dict?
              print_translations(clean_translation(get_translations(opts, ARGV[0])))
            else
              if opts.dict?
                print_translations(get_translations(opts, ARGV[0]))
              else
                print_all_dictionaries_translations(get_translations(opts, ARGV[0]))
              end
            end
          end
        end
      end
    end
  end
end
