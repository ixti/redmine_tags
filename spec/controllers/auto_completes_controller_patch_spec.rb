require 'spec_helper'

describe AutoCompletesController, type: :controller do
  it 'is patched with RedmineTags::Patches::AutoCompletesControllerPatch' do
    patch = RedmineTags::Patches::AutoCompletesControllerPatch
    expect(AutoCompletesController.included_modules).to include(patch)
  end
end
