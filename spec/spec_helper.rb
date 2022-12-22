require 'vimrunner'
require 'vimrunner/rspec'
require_relative './support/vim'

Vimrunner::RSpec.configure do |config|
  config.reuse_server = true

  plugin_path = Pathname.new(File.expand_path('.'))

  config.start_vim do
    vim = Vimrunner.start_gvim
    vim.add_plugin(plugin_path, 'plugin/id3.vim')
    vim
  end
end

RSpec.configure do |config|
  tmp_dir = File.expand_path(File.dirname(__FILE__) + '/../tmp')

  config.include Support::Vim
  config.example_status_persistence_file_path = tmp_dir + '/examples.txt'

  config.around :each do |example|
    fixtures_path = File.expand_path('../support/fixtures', __FILE__)
    FileUtils.cp_r(fixtures_path, FileUtils.getwd)

    example.run

    if example.exception
      puts "Error encountered, Vim message log:\n#{vim.command(:messages)}"
    end
  end
end
