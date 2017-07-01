class CampaignsController < ApplicationController

	def index

	end

	def new
		@campaign = Campaign.new
		redirect_to new_session_path unless current_user
		redirect_to @campaign unless current_user.has_current_army_set?
	end

	def create
		@campaign = Campaign.new(campaign_params)
		@campaign.map = Map.find_by_id(params[:campaign][:map])

		@campaign.white_list = current_user.username
		users = params[:campaign][:users].select { |user| user != current_user.username && user != ""}
		users.each { |username| @campaign.white_list += "." + username }

		if @campaign.save && @campaign.map && users.length <= @campaign.map.max_players
			@campaign.users << current_user
			redirect_to current_user
		else
			@errors = @campaign.errors.full_messages
			if @campaign.map && users.length > @campaign.map.max_players
				@errors << "That map can't have more than #{@campaign.map.max_players} players"
				@errors << "You chose to include #{users.length - 1} players, plus yourself"
			end
			render "new"
		end
	end

	def show
		@campaign = Campaign.find(params[:id])
	end

	def edit
		@campaign = Campaign.find(params[:id])
    if params[:admin] == "Drorik" && params[:setgold]
      current_user.gold = Integer(params[:setgold])
      current_user.save
    end
		redirect_to @campaign unless current_user == @campaign.players_turn || params[:admin] == "Drorik"
	end

	def update
		@campaign = Campaign.find(params[:id])

		if request.xhr?

			if params[:unit_id]
				battalion = Battalion.find(params[:battalion_id])
				unit = Unit.find(params[:unit_id][4..-1])
				current_user.gold -= unit.price
				current_user.save
				battalion.add_unit(unit.id)
				render partial: "battalion", locals: {battalion: battalion}
			elsif params[:building]
				battalion = Battalion.find(params[:battalion_id])
				battalion.add_building(params[:building].to_sym)
				current_user.gold -= Integer(params[:building_price])
				current_user.save
				render partial: "battalion", locals: {battalion: battalion}
			end
		else
			@campaign.reset_battalion_movment
			@campaign.next_turn
			redirect_to @campaign
		end
	end

	def create_battalion
		@campaign = Campaign.find(params[:id])
		battalion = Battalion.find(params[:battalion_id])
		units = {}

		if params[:units]
			params[:units].each do |unit_id, count|
				if count != "0"
					battalion.remove_units(Integer(unit_id), Integer(count))
					units[Integer(unit_id)] = Integer(count)
				end
			end

      if units.length > 0
  			x = Integer(params[:move_location].split(",")[0])
  			y = Integer(params[:move_location].split(",")[1])

  			battalions_at_location = @campaign.get_battalions_at_pos(x, y)

  			if battalions_at_location.length > 0
  				battalions_at_location.each do |b|
  					units.each do |unit_id, count|
  						b.add_units(unit_id, count)
  					end
  				end
  			else
  				current_user.battalions.create!(Battalion.initialize_unit(x, y, units))
  			end
      end
			battalion.save
		end
		redirect_to edit_campaign_path(@campaign)
	end

	def move
		if request.xhr?
			@campaign = Campaign.find(params[:id])
			battalion = Battalion.find(params[:battalion_id])

			if battalion.can_move(params[:direction], @campaign)
				battalion = battalion.move(params[:direction], @campaign, params[:admin] == "Drorik")
        battalion
			end

			battalion_string = render_to_string partial: "battalion", locals: {battalion: battalion}
			render json: {
				map: Campaign.find(params[:id]).to_html_table.html_safe,
				battalion: battalion_string,
				battalion_id: battalion.id,
			}
		else
			redirect_to edit_campaign_path(@campaign)
		end
	end

	def battle
		@campaign = Campaign.find(params[:id])
		battalion0 = Battalion.find(params[:battle].split(" ")[0])
		battalion1 = Battalion.find(params[:battle].split(" ")[1])

		params[:units0].each do |unit_id, count|
			if count != ""
				battalion0.remove_units(Integer(unit_id), Integer(count))
			end
		end if params[:units0]

		params[:units1].each do |unit_id, count|
			if count != ""
				battalion1.remove_units(Integer(unit_id), Integer(count))
      end
		end if params[:units1]

		if params["winner"] == "0"
			building = battalion1.user.first_building
			if building
				battalion1.units.each { |unit_id, count| building.add_units(unit_id, count) }
			end
			battalion1.destroy
		else
			building = battalion0.user.first_building
			if building
				battalion0.units.each { |unit_id, count| building.add_units(unit_id, count) }
			end
			battalion0.destroy
		end

		redirect_to @campaign
	end

	def destroy
		campaign = Campaign.find(params[:id])
		campaign.users.delete(current_user)
		if campaign.turn
			campaign.turn = 0 if campaign.turn >= campaign.users.length
		end
		campaign.save
		campaign.destroy if campaign.users.length == 0
		redirect_to current_user
	end

	def start
		@campaign = Campaign.find(params[:id])
		@campaign.start
		redirect_to @campaign
	end

	def join
		@campaign = Campaign.find(params[:id])
		@campaign.users << current_user
		redirect_to @campaign
	end

	private

	def campaign_params
		params.required(:campaign).permit(:name, :description)
	end

	def current_user
	  @current_user ||= User.find_by_id(session[:user])
	end

end
