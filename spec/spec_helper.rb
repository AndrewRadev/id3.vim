require 'tmpdir'
require 'vimrunner'
require_relative './support/vim'
require_relative './support/files'

RSpec.configure do |config|
  config.include Support::Files

  config.before(:suite) do
    VIM = Vimrunner.start
    VIM.add_plugin(File.expand_path('.'), 'plugin/whitespaste.vim')
    Support::Vim.define_vim_methods(VIM)
  end

  config.after(:suite) do
    VIM.kill
  end

  # cd into a temporary directory for every example.
  config.around do |example|
    @vim = VIM

    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        @vim.command("cd #{dir}")
        example.call
      end
    end
  end
end
