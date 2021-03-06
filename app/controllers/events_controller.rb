class EventsController < ApplicationController
  before_action :set_event,
      :only => [:show, :edit, :update, :destroy]

  before_action :load_filter_from_session_or_params,
      :only => [:index, :calendar]

  # GET /events
  # GET /events.json
  def index
    @event_types = EventType.all
    @sensors     = Sensor.all
    @selected_event_types = params[:filter][:event_type_id] ? @event_types.select{|s| s.id.to_s.in? params[:filter][:event_type_id]} : @event_types
    @selected_sensors     = params[:filter][:sensor_id] ? @sensors.select{|s| s.id.to_s.in? params[:filter][:sensor_id]} : @sensors

    @events = scope.includes(:sensor, :event_type, :temperature, :precipitation).all
  end

  def calendar
    @time_range = (@date.at_beginning_of_month + 12.hours)..(@date.at_end_of_month + 36.hours)
    index
  end

  def deleted
    @events = model.ignored.all

    render :index
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
    @event.ignore!
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def show_upload
  end

  def upload
    sensor = Sensor.find(params[:sensor_id])
    if request.format == Mime::CSV
      request.body.rewind
      Tempfile.new do
        f << request.body
        f.flush
        Event.from_csv f.path, sensor
      end
    elsif params[:csv_file]
      Event.from_csv params[:csv_file].tempfile, sensor
    end

    redirect_to :action => 'index'
  end

  protected

  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def event_params
    params.require(:event).permit(:species_id, :sex_id, :precipitation_id, :temperature_id, :event_type_id, :image_id)
  end

  def model
    Event
  end
end
