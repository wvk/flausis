class PrecipitationsController < ApplicationController
  before_action :set_precipitation, only: [:show, :edit, :update, :destroy]

  before_action :load_filter_from_session_or_params,
      :only => [:index, :images, :events]

  def index
    redirect_to :action => :images
#     @precipitations = scope.to_a
#     @precipitations.select!{|s|s.at_night?} if params[:at_night] == 'true'
#
#     @species     = Species.all
#     @sensors     = Sensor.all
#     @event_types = EventType.all
#
#     respond_to do |format|
#       format.html
#       format.json
#       format.csv { send_data Precipitation.to_csv(@precipitations) }
#     end
  end

  def images
    @species = Species.all

    session[:species_ids]  = params[:species_ids] || @species.map(&:id)
    params[:species_ids] ||= session[:species_ids]

    @selected_species = @species.select{|s| params[:species_ids].include? s.id.to_s }
    @precipitations = scope.to_a
    @precipitations.select!{|s|s.at_night?} if params[:at_night] == 'true'

    respond_to do |format|
      format.html
      format.json
      format.csv { send_data Precipitation.to_csv(@precipitations, params) }
    end
  end

  def events
    @sensors     = Sensor.all
    @event_types = EventType.all

    session[:sensor_ids]  = params[:sensor_ids] || @sensors.map(&:id)
    params[:sensor_ids] ||= session[:sensor_ids]

    session[:event_type_ids]  = params[:event_type_ids] || @event_types.map(&:id)
    params[:event_type_ids] ||= session[:event_type_ids]

    @selected_sensors     = @sensors.select{|s| params[:sensor_ids].include? s.id.to_s }
    @selected_event_types = @event_types.select{|s| params[:event_type_ids].include? s.id.to_s }

    @precipitations = scope.to_a
    @precipitations.select!{|s|s.at_night?} if params[:at_night] == 'true'

    respond_to do |format|
      format.html
      format.json
      format.csv { send_data Precipitation.to_csv(@precipitations, params) }
    end

  end

  # GET /precipitations/1
  # GET /precipitations/1.json
  def show
  end

  # GET /precipitations/new
  def new
    @precipitation = Precipitation.new
  end

  # GET /precipitations/1/edit
  def edit
  end

  # POST /precipitations
  # POST /precipitations.json
  def create
    @precipitation = Precipitation.new(precipitation_params)

    respond_to do |format|
      if @precipitation.save
        format.html { redirect_to @precipitation, notice: 'Precipitation was successfully created.' }
        format.json { render :show, status: :created, location: @precipitation }
      else
        format.html { render :new }
        format.json { render json: @precipitation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /precipitations/1
  # PATCH/PUT /precipitations/1.json
  def update
    respond_to do |format|
      if @precipitation.update(precipitation_params)
        format.html { redirect_to @precipitation, notice: 'Precipitation was successfully updated.' }
        format.json { render :show, status: :ok, location: @precipitation }
      else
        format.html { render :edit }
        format.json { render json: @precipitation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /precipitations/1
  # DELETE /precipitations/1.json
  def destroy
    @precipitation.destroy
    respond_to do |format|
      format.html { redirect_to precipitations_url, notice: 'Precipitation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  protected

  # Use callbacks to share common setup or constraints between actions.
  def set_precipitation
    @precipitation = Precipitation.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def precipitation_params
    params.require(:precipitation).permit(:date, :amount, :station_id)
  end

  def model
    Precipitation
  end

  def model_scope
    self.model.includes(:images => [:species, :sex])
  end
end
