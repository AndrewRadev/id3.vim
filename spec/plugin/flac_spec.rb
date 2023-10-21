require 'spec_helper'

describe "flac" do
  before :each do
    skip "Backend not installed: opustags" if !command_exists?('metaflac')
  end

  it "can read flac files' contents" do
    vim.edit 'fixtures/attempt_1.flac'
    buffer_contents = get_buffer_contents

    expect(buffer_contents).to match /^File:\s+fixtures\/attempt_1\.flac/
    expect(buffer_contents).to match /^Title:\s+Elevator Music Attempt #1/
    expect(buffer_contents).to match /^Artist:\s+Christiaan Bakker/
    expect(buffer_contents).to match /^Album:\s+Echoes From The Past/
  end

  it "can update flac files" do
    vim.edit 'fixtures/attempt_1.flac'

    vim.search('^Title:\s\+\zs\S')
    vim.normal 'CNew title'
    vim.search('^Artist:\s\+\zs\S')
    vim.normal 'CNew artist'

    vim.write

    buffer_contents = get_buffer_contents

    expect(buffer_contents).to match /^Title:\s+New title/
    expect(buffer_contents).to match /^Artist:\s+New artist/
  end
end
