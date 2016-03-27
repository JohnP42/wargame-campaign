class MapsController < ApplicationController

	def index
	end

	def new
		@map = Map.new
		redirect_to new_session_path unless current_user == User.find(params[:user_id])
	end

	def create
		@map = Map.new(map_params)

		if @map.save
			current_user.maps << @map
			redirect_to current_user
		else
			@errors = @map.errors.full_messages
			render "new"
		end
	end

	def show
		@map = Map.find(params[:id])
	end

	def edit
		@map = Map.find(params[:id])
		redirect_to new_session_path unless current_user == User.find(params[:user_id])
	end

	def update
		@map = Map.find(params[:id])
		@map.update_attributes(map_params)

		if @map.save
			redirect_to current_user
		else
			@errors = @map.errors.full_messages
			render "edit"
		end
	end

	def destroy
		Map.find(params[:id]).destroy
		redirect_to current_user
	end

	def copy
		if current_user
      current_user.maps << Map.find(params[:id]).dup
			redirect_to current_user
		else
			redirect_to new_session_path
		end
	end

	private

	def map_params
		params.required(:map).permit(:name, :description, :tileset)
	end

	def current_user
	  @current_user ||= User.find_by_id(session[:user])
	end

end
