require 'csv'

class ThoughtWallsController < ApplicationController
  skip_authorization_check
    
  def export
    @thought_wall = ThoughtWall.find_by_code(params[:id])
    
    respond_to do |format|
      format.csv  {render layout: false}
    end
  end
  
  def show
    @render_timestamp = Time.now.utc.to_i
    
    if params[:since]
      @last_render_at = Time.at(params[:since].to_i).utc
      @thought_wall = ThoughtWall.find_by_code(params[:id])
      @thoughts = Thought.where(["thought_wall_id = ? AND updated_at >= ?", @thought_wall.id, @last_render_at]).order("manual_order_updated_at ASC").includes(:thought_histories)
      
      @update_client_title = @thought_wall.updated_at > @last_render_at
      if @update_client_title || @thoughts.count > 0
        @next_refresh = get_next_refresh(0, true)
      else
        @next_refresh = get_next_refresh(params[:next_refresh].to_i, false)
      end
    else
      @thought_wall = ThoughtWall.find_by_code(params[:id], :include => :thoughts)
      if @thought_wall.nil?
        return redirect_to :root
      end
      
      @next_refresh = get_next_refresh(0, true)
    end
    
    cookies[:page_i_was_on] = @thought_wall.code
    
    respond_to do |format|
      format.html
      format.js {render layout: false}
    end
  end
  
  def create
    new_thought_wall = ThoughtWall.new
    new_thought_wall.code = new_unique_code
    new_thought_wall.title = Date.today.strftime('%a, %d %b %Y')
    new_thought_wall.save

    redirect_to "/#{new_thought_wall.code}"
  end
  
  def update
    @thought_wall = ThoughtWall.find_by_code(params[:id].to_s) || ThoughtWall.find(params[:id])
    @thought_wall.update_attributes(params[:thought_wall])
  end
  
  # PUT
  def toggle_star
    @thought_wall = ThoughtWall.find_by_code(params[:id].to_s)
    
    if current_user
      if @thought_wall.users.include?(current_user)
        @thought_wall.users.delete(current_user)
        @show_as_starred = false
      else
        @thought_wall.users << current_user
        @show_as_starred = true
      end
    else
      @show_as_starred = false
    end
  end
  
  private
    def new_unique_code
      new_code = Digest::SHA1.hexdigest(srand.to_s)[0,8]

      while ThoughtWall.find_by_code(new_code)
        new_code = Digest::SHA1.hexdigest(srand.to_s)[0,8]
      end
      
      new_code 
    end
    
    def get_next_refresh(desired_next_refresh, reset_refresh_rate)
      min_refresh = 1500
      return min_refresh if reset_refresh_rate
      
      next_refresh = [desired_next_refresh || min_refresh, min_refresh].max

      next_refresh_in_seconds = (((next_refresh / 1000.0)**2)/30.0)
      next_refresh = [next_refresh + (next_refresh_in_seconds*1000).to_i, 60000].min
    end
  
end
