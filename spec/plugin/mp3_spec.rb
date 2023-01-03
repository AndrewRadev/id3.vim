require 'spec_helper'

describe "mp3" do
  ['id3-json', 'id3', 'id3v2'].each do |backend|
    describe "backed by #{backend}" do
      before :each do
        skip "Backend not installed: #{backend}" if !command_exists?(backend)

        vim.command("let g:id3_mp3_backends = ['#{backend}']")
      end

      it "can read mp3 files' contents" do
        vim.edit 'fixtures/attempt_1.mp3'
        buffer_contents = get_buffer_contents

        expect(buffer_contents).to match /^File:\s+fixtures\/attempt_1\.mp3/
        expect(buffer_contents).to match /^Title:\s+Elevator Music Attempt #1/
        expect(buffer_contents).to match /^Artist:\s+Christiaan Bakker/
        expect(buffer_contents).to match /^Album:\s+Echoes From The Past/
      end

      it "can update mp3 files' contents" do
        vim.edit 'fixtures/attempt_1.mp3'

        vim.search('^Title:\s\+\zs\S')
        vim.normal 'CNew title'
        vim.search('^Artist:\s\+\zs\S')
        vim.normal 'CNew artist'

        vim.write
        vim.edit 'fixtures/attempt_1.mp3'

        buffer_contents = get_buffer_contents

        expect(buffer_contents).to match /^Title:\s+New title/
        expect(buffer_contents).to match /^Artist:\s+New artist/
      end

      if backend == 'id3-json'
        it "can update a v2.4 file's date" do
          vim.edit 'fixtures/attempt_1.mp3'

          vim.search('^Date:\s\+\zs\S')
          vim.normal 'C2023-06'
          vim.write
          vim.edit 'fixtures/attempt_1.mp3'

          buffer_contents = get_buffer_contents
          expect(buffer_contents).to match /^Date:\s+2023-06/
        end
      end
    end
  end
end
