class ArmiesController < ApplicationController

	def index
	end

	def new
		@army = Army.new
		redirect_to new_session_path unless current_user == User.find(params[:user_id])
	end

	def create
		@army = Army.create(army_params)

		if @army.save
			current_user.clear_current if params[:army][:is_current]
			current_user.armies << @army
			redirect_to [current_user, @army]
		else
			@errors = @army.errors.full_messages
			render "new"
		end
	end

	def show
		@army = Army.find(params[:id])
	end

	def edit
		@army = Army.find(params[:id])
		redirect_to new_session_path unless current_user == User.find(params[:user_id])
	end

	def update
		current_user.clear_current if params[:army][:is_current]
		@army = Army.find(params[:id])
		@army.update_attributes(army_params)

		if @army.save
			redirect_to current_user
		else
			@errors = @army.errors.full_messages
			render "new"
		end
	end

	def destroy
		Army.find(params[:id]).destroy
		redirect_to current_user
	end

	def copy
		if current_user
			army = Army.find(params[:id])
			new_army = army.dup

			army.units.each { |unit| new_army.units << unit.dup}

      current_user.armies << new_army
			redirect_to current_user
		else
			redirect_to new_session_path
		end
	end

	private

	def army_params
		params.required(:army).permit(:name, :description, :is_current)
	end

	def current_user
	  @current_user ||= User.find_by_id(session[:user])
	end

end
