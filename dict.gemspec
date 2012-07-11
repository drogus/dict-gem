Gem::Specification.new do |s|
  s.add_dependency 'slop', '~> 3.3.2'
  s.add_dependency 'nokogiri', '~>1.5.5'
  s.add_development_dependency "rspec", "~> 2.11"
  s.add_development_dependency "rake"

  s.name = %q{dict}
  s.version = "0.2.0"
  s.authors = ['Aleksander Gozdek', 'Mateusz Czerwinski', 'Michał Podlecki','Rafał Ośko']
  s.email = ['mtczerwinski@gmail.com']
  s.date = Time.now.strftime('%Y-%m-%d')
  s.summary = %q{Gem made for dictionary application}
  s.files = [
    "lib/dict.rb",
    "lib/dictionary.rb",
    "lib/wiktionary.rb",
    "lib/dictpl.rb",
    "lib/module_main.rb"
  ]
  s.require_paths = ["lib"]
  s.executable = 'dict'
  s.description = <<-END
    Dict is an open source dictionary aggregator.
  END
  s.homepage = 'https://github.com/Ragnarson/dict-gem'

end
