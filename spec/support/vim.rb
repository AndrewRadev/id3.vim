module Support
  module Vim
    def set_file_contents(string)
      write_file(filename, string)
      vim.edit!(filename)
    end

    def get_buffer_contents
      vim.echo(%<join(getbufline('%', 1, '$'), "\n")>) + "\n"
    end

    def assert_file_contents(string)
      expect(IO.read(filename).strip).to eq(string.strip)
    end

    def command_exists?(command)
      system("which #{command}", [:out, :err] => '/dev/null')
    end
  end
end
