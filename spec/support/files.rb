module Support
  # Note the juggling of the final newline. Writing a string to a file through
  # ruby needs to be the same as writing it through Vim.
  #
  module Files
    def set_file_contents(string)
      string = normalize_string(string)
      File.open(filename, 'w') { |f| f.write(string + "\n") }
      @vim.edit! filename
    end

    def file_contents
      IO.read(filename).chop # remove trailing newline
    end

    def assert_file_contents(string)
      file_contents.should eq normalize_string(string)
    end

    private

    # Note: #scan and #chop is being used instead of #split to avoid discarding
    # empty lines.
    def normalize_string(string)
      if string.end_with?("\n")
        lines      = string.scan(/.*\n/).map(&:chop)
        whitespace = lines.grep(/\S/).first.scan(/^\s*/).first
      else
        lines      = [string]
        whitespace = string.scan(/^\s*/).first
      end

      lines.map do |line|
        line.gsub(/^#{whitespace}/, '') if line =~ /\S/
      end.join("\n")
    end
  end
end
