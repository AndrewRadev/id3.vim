require 'spec_helper'

describe "opus" do
  before :each do
    skip "Backend not installed: opustags" if !command_exists?('opustags')
  end

  it "can read opus files' contents" do
    vim.edit 'fixtures/attempt_1.opus'
    buffer_contents = get_buffer_contents

    expect(buffer_contents).to match /^File:\s+fixtures\/attempt_1\.opus/
    expect(buffer_contents).to match /^Title:\s+Elevator Music Attempt #1/
    expect(buffer_contents).to match /^Artist:\s+Christiaan Bakker/
    expect(buffer_contents).to match /^Album:\s+Echoes From The Past/
  end

  it "can update opus files" do
    vim.edit 'fixtures/attempt_1.opus'

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
