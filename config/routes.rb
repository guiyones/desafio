Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "projects#index"

  resources :skills, except: :show

  resources :projects do
    scope module: :projects do
      resource :results, only: :show
    end

    resources :groups, shallow: true, except: %i[ index show ] do
      resources :challenges, except: %i[ index show ]
    end
  end

  resources :challenges, only: [] do
    scope module: :challenges do
      resources :slips, only: %i[ create edit update destroy ], param: :day
    end
  end
end
