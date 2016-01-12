require 'spec_helper'

describe WikiController, type: :controller do
  it 'is patched with RedmineTags::Patches::WikiControllerPatch' do
    patch = RedmineTags::Patches::WikiControllerPatch
    expect(WikiController.included_modules).to include(patch)
  end
end
