require 'spec_helper'

describe WikiPage, type: :model do
  it 'is patched with RedmineTags::Patches::WikiPagePatch' do
    patch = RedmineTags::Patches::WikiPagePatch
    expect(WikiPage.included_modules).to include(patch)
  end
end
