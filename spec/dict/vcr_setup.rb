require 'vcr'
require 'rspec'
require 'active_support/all'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/dict/vcr_cassettes'
  c.hook_into :fakeweb
  c.allow_http_connections_when_no_cassette = true
  c.default_cassette_options = { :record => :new_episodes }
end


RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true
  c.around(:each, :vcr) do |example|
    name = example.metadata[:full_description].split(/\s+/, 2).join("/").underscore.gsub(/[^\w\/]+/, "_")
    VCR.use_cassette(name) { example.call }
  end
end

