class PrecipitationsController < ApplicationController
  before_action :set_precipitation, only: [:show, :edit, :update, :destroy]

  # GET /precipitations
  # GET /precipitations.json
  def index
    scope = Precipitation

    params[:from_time] ||= (Precipitation.last.timestamp - 1.week).to_s
    params[:to_time]   ||= (Precipitation.last.timestamp).to_s
    scope = scope.where(:timestamp => (Date.parse(params[:from_time]) - 12.hours)..(Date.parse(params[:to_time])+ 12.hours))

    @precipitations = scope.includes(:events).order('timestamp ASC').all.to_a
    @precipitations.select!{|s|s.at_night?} if params[:at_night] == 'true'

    respond_to do |format|
      format.html
      format.json
      format.csv { send_data Precipitation.to_csv(@precipitations) }
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

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_precipitation
    @precipitation = Precipitation.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def precipitation_params
    params.require(:precipitation).permit(:date, :amount, :station_id)
  end
end
