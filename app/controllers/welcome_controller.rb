class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :about]
  def index
    @name = "Debajyoti"
  end
  
  def about
  end
end