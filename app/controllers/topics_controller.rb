class TopicsController < ApplicationController

  def index
    session[:votes] = 3 if session[:votes].nil?
    @votes = session[:votes]
    session[:topics] = {} if session[:topics].nil?
    @voted = session[:topics]
    @topics = Topic.where(conference_id: params[:conference_id])
    respond_to do |format|
      format.html { render :index }
      format.json { render json: @topics.to_json }
    end
  end

  def show
    render json: Topic.find(params[:id]).to_json
  end

  def results
    @topics = Topic.where(conference_id: params[:conference_id]).sort_by{|t| -t.points}
  end

  def new
  end

  def create
    topic = Topic.create(permitted_params)
    confirm_save topic
  end

  def vote    
    if(session[:votes]) > 0
      topic = Topic.find(params[:id])
      topic.update(points: (topic.points + 1))
      topic.save
      session[:votes] = session[:votes] - 1
      session[:topics] ||= {}
      session[:topics][params[:id]] = session[:topics][params[:id]].to_i + 1
    end
    redirect_to conference_topics_url(params[:conference_id])
  end

  private

  def confirm_save topic
    if topic.save
      head :created
    else
      head :unprocessable_entity
    end
  end

  def permitted_params
    params.require(:topic).permit(:name, :type, :description, :facilitator, :points, :conference_id, :schedule_slots_id)
  end
end
