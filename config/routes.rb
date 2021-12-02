get '/issue_tags/auto_complete/:project_id', to: 'auto_completes#issue_tags',
  as: 'auto_complete_issue_tags'
get '/wiki_tags/auto_complete/:project_id', to: 'auto_completes#wiki_tags',
  as: 'auto_complete_wiki_tags'
match '/tags/context_menu', to: 'tags#context_menu', as: 'tags_context_menu',
  via: [:get, :post]
delete '/tags', controller: 'tags', action: 'destroy'
get '/tags/add_tag', to: 'tags#add_tag', as: 'tags_add'
get '/tags/delete_tag', to: 'tags#delete_tag', as: 'tags_delete'
patch '/tags/update_tag', to: 'tags#update_tag'

resources :tags, only: [:edit, :update] do
  collection do
    post :merge
    get :context_menu, :merge
  end
end
