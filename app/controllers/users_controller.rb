class UsersController < ApplicationController

	def index
		@users = User.all
	  if params[:search]
	    @users = User.search(params[:search]).order("username ASC")
	  else
	    @users = User.all.order('username ASC')
	  end
	end

	def new
		@user = User.new
	end

	def create
		@user = User.new(user_params)

		if @user.save
			session[:user] = @user.id
			redirect_to @user
		else
			@errors = @user.errors.full_messages
			render "new"
		end
	end

	def show
		@user = User.find(params[:id])
	end

	def edit

	end

	def update

	end

	def destroy

	end

	private

	def user_params
		params.required(:user).permit(:username, :email, :password, :password_confirmation)
	end

end
