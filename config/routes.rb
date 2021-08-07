Rails.application.routes.draw do
  devise_for :users
  root to: "homes#about"
  resources :users, only: [:show, :edit, :update] do
    get "read" => "users#read"
    get "unread" => "users#unread"
    get "follows" => "users#follows"
    get "followers" => "users#followers"
    get "welcome" => "users#welcome"
    resource :relationships, only: [:create, :destroy]
  end
  get "mypage/cancel" => "users#cancel"
  patch "mypage" => "users#cancel"

  resources :books, only: [:index, :show, :create] do
    resources :book_reads,  only: [:create, :destroy]
    resources :book_unreads,  only: [:create, :destroy]
    resources :book_comments,  only: [:create, :destroy]
  end

  resources :tags, only: [:index, :create, :destroy, :edit, :update]
end
