require 'spec_helper'

describe "opus" do
  it "can read opus files' contents" do
    vim.edit 'fixtures/attempt_1.opus'
    buffer_contents = get_buffer_contents

    expect(buffer_contents).to match /^File:\s+fixtures\/attempt_1\.opus/
    expect(buffer_contents).to match /^Title:\s+Elevator Music Attempt #1/
    expect(buffer_contents).to match /^Artist:\s+Christiaan Bakker/
    expect(buffer_contents).to match /^Album:\s+Echoes From The Past/
  end
end
