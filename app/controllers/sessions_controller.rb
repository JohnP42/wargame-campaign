class SessionsController < ApplicationController

	def new
	end

	def create
		user = User.find_by(email: params[:session][:email].downcase)

		if user && user.authenticate(params[:session][:password])
			session[:user] = user.id
			redirect_to user
		else
			@errors = ["The information you've entered is not valid"]
			render "new"
		end
	end

	def destroy
		session[:user] = nil
		redirect_to root_url
	end

end
