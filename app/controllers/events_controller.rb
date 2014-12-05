class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  # GET /events
  # GET /events.json
  def index
    scope = Event

    if params[:filter].present?
      session[:events_filter] = params[:filter].dup.reject{|k,v| v.reject!(&:empty?).empty? }
    end

    if params[:from_time].present?
      session[:from_time] = params[:from_time]
    else
      params[:from_time] = session[:from_time] ||= Event.last.timestamp.to_s
    end

    if params[:to_time].present?
      session[:to_time] = params[:to_time]
    else
      params[:to_time] =session[:to_time] ||= Event.last.timestamp.to_s
    end

    if session[:events_filter]
      if session[:events_filter][:precipitation_amounts].present? and precipitation_amounts = session[:events_filter].delete('precipitation_amounts').reject(&:blank?)
        if precipitation_amounts.any?
          scope = scope.joins(:precipitation).where('precipitations.amount IN (?)', precipitation_amounts)
        end
      end

      scope = scope.where(session[:events_filter])
      scope = scope.where(:events => {:timestamp => (Date.parse(params[:from_time]) + 12.hours)..(Date.parse(params[:to_time]) + 36.hours)})
      @filter = OpenStruct.new(session[:events_filter])
    end

    @events = scope.includes(:species, :sex, :sensor, :event_type, :precipitation).order('events.timestamp ASC').all
  end

  # GET /events/1
  # GET /events/1.json
  def show
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(event_params)

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:species_id, :sex_id, :precipitation_id, :temperature_id, :event_type_id, :image_id)
    end
end
