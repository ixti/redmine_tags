require 'spec_helper'

describe IssueQuery, type: :model do
  it 'is patched with RedmineTags::Patches::IssueQueryPatch' do
    patch = RedmineTags::Patches::IssueQueryPatch
    expect(IssueQuery.included_modules).to include(patch)
  end
end
