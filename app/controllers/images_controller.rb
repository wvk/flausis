class ImagesController < ApplicationController
  before_action :set_image,
      :only => [:show, :edit, :update, :destroy]

  before_action :load_filter_from_session_or_params,
      :only => [:index, :calendar, :match_events]

  # GET /images
  # GET /images.json
  def index
    @species = Species.all
    @sexes   = Sex.all

    if params[:species_ids].blank? and session[:species_ids].blank?
      params[:species_ids] = session[:species_ids] = @species.map(&:id).map(&:to_s)
    elsif params[:species_ids].present?
      session[:species_ids] = params[:species_ids]
    else
      params[:species_ids] = session[:species_ids]
    end

    if params[:sex_ids].blank? and session[:sex_ids].blank?
      params[:sex_ids] = session[:sex_ids] = @species.map(&:id).map(&:to_s)
    elsif params[:sex_ids].present?
      session[:sex_ids] = params[:sex_ids]
    else
      params[:sex_ids] = session[:sex_ids]
    end

    @selected_species = @species.select{|s| params[:species_ids].include? s.id.to_s }
    @selected_sexes   = @sexes.select{|s| params[:sex_ids].include? s.id.to_s }
    @images = scope.includes(:temperature, :precipitation, :species, :sex).where(:species => @selected_species, :sex => @selected_sexes).all
  end

  def calendar
    @time_range = (@date.at_beginning_of_month + 12.hours)..(@date.at_end_of_month + 36.hours)
    index
  end

#   def match_events
#     index
#
#     if @time_range and not @images.all? &:event
#       events = Event.includes(:precipitation, :temperature).where(:timestamp => @time_range).order('images.timestamp ASC').to_a
#       n = 0
#       tries = 5
#       ok = false
#
#       @best_solution = nil
#
#       image_ids = @images.reject{|s| s.annotations =~ /test/i }[0 .. 4]
#       while tries >= 0 and n < [events.size - 7, events.size].max and not ok
#         event_ids = events[n .. n + 7]
#
#         solutions = []
#         event_ids.permutation do |a|
#           solution = a.zip(image_ids).reject{|s| s.last.nil? }
#           solutions << solution if solution.sort{|sa, sb| sa.last.timestamp <=> sb.last.timestamp } == solution.sort{|sa, sb| sa.first.timestamp <=> sb.first.timestamp}
#         end.uniq!
#
#         solutions.each do |solution|
#           error = solution.map {|e, i| (e.timestamp - i.timestamp).to_i}
#           if @best_solution.nil? or @best_solution.last.sum > error.sum
#             @best_solution = [solution, error]
#           end
#         end
#
#         @diff = @best_solution.last.sum.to_f / @best_solution.last.size.to_f
#         @dev  = (@best_solution.last.max - @best_solution.last.min).to_f / 2
#
#         previous_events = []
#         @images.each do |image|
#           timestamp  = image.timestamp + @diff
#           previous_events = image.possible_events = (events.select{|e| e.timestamp > (timestamp - [3, @dev].max) and e.timestamp < (timestamp + [3, @dev].max)} - previous_events)
#         end
#
#         if @images.all? {|i| i.possible_events.count == 1 }
#           @images.each {|i| i.update_attribute :event, i.possible_events.first }
#           ok = true
#         end
#         n += 1
#         tries -= 1
#       end
#     end
#
#     render :index
#   end

  # GET /images/1
  # GET /images/1.json
  def show
  end

  # GET /images/new
  def new
    @image = Image.new
  end

  # GET /images/1/edit
  def edit
  end

  # POST /images
  # POST /images.json
  def create
    @image = Image.new(image_params)

    respond_to do |format|
      if @image.save
        format.html { redirect_to @image, notice: 'Image was successfully created.' }
        format.json { render :show, status: :created, location: @image }
      else
        format.html { render :new }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /images/1
  # PATCH/PUT /images/1.json
  def update
    respond_to do |format|
      if @image.update(image_params)
        format.html { redirect_to @image, notice: 'Image was successfully updated.' }
        format.json { render :show, status: :ok, location: @image }
      else
        format.html { render :edit }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    @image.ignore!
    respond_to do |format|
      format.html { redirect_to images_url, notice: 'Image was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  protected

  # Use callbacks to share common setup or constraints between actions.
  def set_image
    @image = Image.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def image_params
    params.require(:image).permit(:filename, :date, :time, :annotations)
  end

  def model
    Image
  end
end
