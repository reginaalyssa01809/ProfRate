Rails.application.routes.draw do
  resources :professors do
    collection do
      post :add_course
      get ':id/courses/:course_id', action: :display_reviews_of_subject, as: 'reviews'
    end
  end
  resources :courses do
    collection do
      post :add_professor
    end
  end
  resources :reviews, :only => [:new, :create]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
