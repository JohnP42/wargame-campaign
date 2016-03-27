class FriendshipsController < ApplicationController

	def create
		@friendship = current_user.friendships.build(:friend_id => params[:friend_id])
	  if @friendship.save
	    flash[:notice] = "Added friend."
	    redirect_to User.find(params[:friend_id])
	  else
	    flash[:notice] = "Unable to add friend."
	    redirect_to User.find(params[:friend_id])
	  end
	end

	def destroy
  	@friendship = current_user.friendships.find(params[:id])
  	@friendship.destroy
  	flash[:notice] = "Removed friendship."
  	redirect_to current_user
	end

	private

	def current_user
	  @current_user ||= User.find_by_id(session[:user])
	end

end
