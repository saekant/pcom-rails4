Lowtempdev::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  get 'proteins/top'
  get 'proteins/overview'
  get 'proteins/resources'
  get 'proteins/aboutus'
  get 'proteins/key_protein'
  get 'proteins/key_proteins'
  get 'proteins/list_protein'
  get 'proteins/search_list_protein_by_gene_id'
  get 'proteins/search_list_protein_by_symbols_or_description'
  get 'proteins/search_protein'
  get 'proteins/help_geneId'
  post 'proteins/search_list_protein_by_symbols_or_description'
  post 'proteins/search_list_protein_by_gene_id'
  post 'proteins/getchartslist'
  post 'proteins/search_material_protein'
  post 'proteins/search_gene_list'
  post 'proteins/search_protein'

  get 'proteins/getchart'
  get 'proteins/lazy_test'

  #root 'proteins#top'
end
