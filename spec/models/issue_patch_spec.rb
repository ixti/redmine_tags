require 'spec_helper'

describe Issue, type: :model do
  it 'is patched with RedmineTags::Patches::IssuePatch' do
    patch = RedmineTags::Patches::IssuePatch
    expect(Issue.included_modules).to include(patch)
  end
end
