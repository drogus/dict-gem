# -*- encoding: utf-8 -*

require_relative './vcr_setup'
require 'dict/glosbe'

describe Dict::Glosbe do

  it "should raise no given word exception" do
    expect { Dict::Glosbe.new }.to raise_error ArgumentError
  end

  it "should return a Result object" do
    VCR.use_cassette('glosbe_translations_woda_cassette', :re_record_interval => 1.minute) do
      g = Dict::Glosbe.new('woda').translate
      g.should be_a(Dict::Result)
    end
  end

  it "should return empty hash with translations for word asdfff" do
    VCR.use_cassette('glosbe_translations_asdfff_cassette', :re_record_interval => 1.minute) do
      g = Dict::Glosbe.new('asdfff').translate
      g.translations.should eq({})
    end
  end

  it "should return translations of polish word 'woda' to english with its examples" do
    VCR.use_cassette('glosbe_translations_woda_cassette', :re_record_interval => 1.minute) do
      g = Dict::Glosbe.new('woda').translate
      g.translations.should == {"woda"=>["water", "aqua"]}
      g.examples.should == {}
    end
  end

  it "should return translations of english word 'atomic' to polish with its examples" do
    VCR.use_cassette('glosbe_translations_atomic_cassette',:re_record_interval => 1.minute) do
      g = Dict::Glosbe.new('atomic').translate
      g.translations.should == {"atomic"=>["atomic skis"]}
      g.examples.should == {}
    end
  end

  it "should return translations results for english word 'usage'" do
    VCR.use_cassette('glosbe_translations_usage_cassette', :re_record_interval => 1.minute) do
      g = Dict::Glosbe.new('usage').translate
      g.translations.should == {"usage"=>["użycie", "obchodzenie", "stosowanie", "stosować", "tradycje", "traktowanie", "użytkowanie", "używać", "zastosowanie", "zużycie", "zwyczaj", "zwyczaje"]}
    end
  end
 end
