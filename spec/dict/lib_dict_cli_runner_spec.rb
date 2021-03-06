# -*- coding: utf-8 -*

require_relative './vcr_setup'
require 'dict/cli/runner'
require 'slop'

describe "parameters_valid?" do
  it "should return false if ARGV is empty" do
    stub_const("ARGV", [])
    runner = Dict::CLI::Runner.new
    runner.parameters_valid?.should == false
  end

  it "should return true if ARGV is not empty" do
    stub_const("ARGV", ["słowik", "-t", "36", "-d"])
    runner = Dict::CLI::Runner.new
    runner.parameters_valid?.should == true
  end
end

describe "parse_parameters" do
  it "should return Hash for parameters słowik -t 36" do
    stub_const("ARGV", ["słowik", "-t", "36"])
    runner = Dict::CLI::Runner.new
    opts = runner.parse_parameters
    {:help=>nil, :time=>"36", :dict=>nil, :version=>nil, :clean=>nil}.should == opts.to_hash
  end

  it "should return Hash for parameters słowik" do
    stub_const("ARGV", ["słowik"])
    runner = Dict::CLI::Runner.new
    opts = runner.parse_parameters
    {:help=>nil, :time=>nil, :dict=>nil, :version=>nil, :clean=>nil}.should == opts.to_hash
  end
end


describe "get_translations" do
  it "should return results from wiktionary and glosbe for word 'słowik'" do
    VCR.use_cassette('translations_slownik_cassette', :re_record_interval => 7.days) do
      stub_const("ARGV", ["słowik"])
      runner = Dict::CLI::Runner.new
      opts = runner.parse_parameters
      runner.get_translations(opts, "słowik").should == {"wiktionary"=>{"słowik"=>["nightingale"]}, "glosbe"=>{"słowik"=>["nightingale", "thrush nightingale", "bulbul"]}}
    end
  end

  it "should return results from selected dictionary for word 'słowik'" do
    VCR.use_cassette('translations_slownik_cassette', :re_record_interval => 7.days) do
      stub_const("ARGV", ["słowik", "-d", "wiktionary"])
      runner = Dict::CLI::Runner.new
      opts = runner.parse_parameters
      runner.get_translations(opts, "słowik").should == {"słowik"=>["nightingale"]}
    end
  end

  it "should return timeout message for word słowik and -t 5" do
    stub_const("ARGV", ["słowik","-t","5"])
    runner = Dict::CLI::Runner.new
    Dict.should_receive(:get_all_dictionaries_translations).
      and_return { sleep 20 }
    runner.should_receive(:puts).with("Upłynął limit czasu żądania.");
    runner.run
  end
end

describe "CLI::Runner" do
  HELP_MSG = "Przykład użycia: dict SŁOWO [OPCJE]\nWyszukaj SŁOWO w dict, open-source'owym agregatorze słowników.\n\n    -h, --help         Wyświetl pomoc\n    -t, --time         Ustaw limit czasu żądania w sekundach. Domyślnie: 300\n    -d, --dict         Wybierz słownik. Dostępne są : wiktionary, glosbe\n    -v, --version      Informacje o gemie, autorach, licencji\n    -c, --clean        Nie wyświetlaj przykładów użycia"
  DICT_MSG = "Brakujący argument. Spodziewano: wiktionary, glosbe"
  TIME_MSG = "Brakujący argument. Spodziewano: liczba sekund"
  T_MSG = "Nieprawidłowa wartość czasu."

  it "should call abort when program is called with -h" do
    stub_const("ARGV",["-h"])
    opts = Slop.new
    runner = Dict::CLI::Runner.new
    runner.should_receive(:abort).with(HELP_MSG).and_raise(SystemExit)
    expect {
      runner.run
    }.to raise_error(SystemExit)
  end

  it "should try to display meaningful information when -d option arguments are missing" do
    stub_const("ARGV",["-d"])
    runner = Dict::CLI::Runner.new
    runner.should_receive(:abort).with(DICT_MSG).and_raise(SystemExit)
    expect {
      runner.run
    }.to raise_error(SystemExit)
  end

  it "should try to display meaningful information when -t option arguments are missing" do
    stub_const("ARGV",["-t"])
    runner = Dict::CLI::Runner.new
    runner.should_receive(:abort).with(TIME_MSG).and_raise(SystemExit)
    expect {
      runner.run
    }.to raise_error(SystemExit)
  end

  it "should raise SystemExit and print msg when for parameter -t value is dupa" do
    stub_const("ARGV",["słowik", "-t","dupa"])
    runner = Dict::CLI::Runner.new
    runner.should_receive(:abort).with(T_MSG).and_raise(SystemExit)
    expect {
      runner.run
    }.to raise_error(SystemExit)
  end

  it "should return array without duplicates when you use --clean parameter" do
    VCR.use_cassette('slowik_runner_cassette') do
      stub_const("ARGV",["słowik","--clean"])
      runner = Dict::CLI::Runner.new
      opts = runner.parse_parameters
      runner.clean_translation(runner.get_translations(opts, ARGV[0])).should == ["nightingale"]
    end
  end


end
