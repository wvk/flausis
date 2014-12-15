class ObservationSessionsController < ApplicationController
  before_action :set_observation_session,
      :only => [:show, :edit, :update, :destroy]

  # GET /observation_sessions
  def index
    prepare_list!

    respond_to do |format|
      format.html
      format.json
      format.csv { send_data ObservationSession.to_csv(@observation_sessions, params) }
    end
  end

  def daily
    prepare_list!
    @observation_sessions = @observation_sessions.where(:at_night => false)
    respond_to do |format|
      format.html { render :index }
      format.json { render :index }
      format.csv { send_data ObservationSession.to_csv(@observation_sessions, params) }
    end
  end

  def nightly
    prepare_list!
    @observation_sessions = @observation_sessions.where(:at_night => true)
    respond_to do |format|
      format.html { render :index }
      format.json { render :index }
      format.csv { send_data ObservationSession.to_csv(@observation_sessions, params) }
    end
  end

  # GET /observation_sessions/1
  def show
  end

  # GET /observation_sessions/new
  def new
    @observation_session = ObservationSession.new
  end

  # GET /observation_sessions/1/edit
  def edit
  end

  # POST /observation_sessions
  def create
    @observation_session = ObservationSession.new(observation_session_params)

    if @observation_session.save
      redirect_to @observation_session, notice: 'Observation session was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /observation_sessions/1
  def update
    if @observation_session.update(observation_session_params)
      redirect_to @observation_session, notice: 'Observation session was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /observation_sessions/1
  def destroy
    @observation_session.destroy
    redirect_to observation_sessions_url, notice: 'Observation session was successfully destroyed.'
  end

  protected

  # Use callbacks to share common setup or constraints between actions.
  def set_observation_session
    @observation_session = ObservationSession.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def observation_session_params
    params.require(:observation_session).permit(:start_time, :end_time, :at_night)
  end

  def model
    ObservationSession
  end

  def model_scope
    self.model
  end

  def prepare_list!
    if params[:date].present?
      session[:date] = params[:date]
    else
      params[:date] = session[:date] ||= Date.today.to_s
    end
    @date = Date.parse(session[:date]).to_date

    if params[:from_time].present?
      session[:from_time] = params[:from_time]
    else
      params[:from_time] = session[:from_time] ||= @date.at_beginning_of_month.to_s
    end

    if params[:to_time].present?
      session[:to_time] = params[:to_time]
    else
      params[:to_time] = session[:to_time] ||= @date.at_end_of_month.to_s
    end

    @from_date = Date.parse(params[:from_time]).to_date
    @to_date   = Date.parse(params[:to_time]).to_date
    @time_range = (@from_date + 12.hours)..(@to_date + 36.hours)

    @species = Species.all

    if params[:species_ids].blank? and session[:species_ids].blank?
      params[:species_ids] = session[:species_ids] = @species.map(&:id).map(&:to_s)
    elsif params[:species_ids].present?
      session[:species_ids] = params[:species_ids]
    else
      params[:species_ids] = session[:species_ids]
    end

    @selected_species     = @species.select{|s| params[:species_ids].include? s.id.to_s }
    @observation_sessions = scope.includes(:images => :species).where('start_time < ? and end_time > ?', @to_date.at_end_of_day, @from_date.at_beginning_of_day )
  end
end
