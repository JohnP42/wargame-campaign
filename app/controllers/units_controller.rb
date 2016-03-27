class UnitsController < ApplicationController

	def new
		@unit = Unit.new
		redirect_to new_session_path unless current_user == User.find(params[:user_id])
	end

	def create
		army = Army.find(params[:army_id])
		@unit = Unit.create(unit_params)

		if @unit.save
			army.units << @unit
			redirect_to [current_user, army]
		else
			@errors = @unit.errors.full_messages
			render "new"
		end
	end

	def show
	end

	def edit
		@unit = Unit.find(params[:id])
		redirect_to new_session_path unless current_user == User.find(params[:user_id])
	end

	def update
		@unit = Unit.find(params[:id])
		@unit.update_attributes(unit_params)

		if @unit.save 
			redirect_to [current_user, @unit.army]
		else
			@errors = @unit.errors.full_messages
			render "edit"
		end
	end

	def destroy
		Unit.find(params[:id]).destroy
		redirect_to [current_user, Army.find(params[:army_id])]
	end

	private

	def unit_params
		params.required(:unit).permit(:name, :combatType, :description, :price, :tier, :hero)
	end

	def current_user
	  @current_user ||= User.find_by_id(session[:user])
	end

end
