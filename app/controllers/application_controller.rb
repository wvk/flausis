class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :load_filter

  protected

  def load_filter_from_session_or_params
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
  end

  def model_scope
    self.model.visible
  end

  def scope
    filter_scope = model_scope
    if params[:filter]
      if params[:filter][:precipitation_amounts].present? and precipitation_amounts = params[:filter].delete('precipitation_amounts').reject(&:blank?)
        if precipitation_amounts.any?
          filter_scope = filter_scope.joins(:precipitation).where('precipitations.amount IN (?)', precipitation_amounts)
        end
      end

      filter_scope = filter_scope.where(params[:filter].select{|k, v| model.respond_to? k })
    end

    filter_scope = filter_scope.where(:timestamp => @time_range)
    @filter = OpenStruct.new(params[:filter])

    return filter_scope
  end

  def load_filter
    if params[:filter].present?
      session[:events_filter] = params[:filter].dup.reject{|k,v| v.reject!(&:empty?).empty? }
    elsif session[:events_filter].blank?
      session[:events_filter] = {}
    end

    params[:filter] = session[:events_filter]
  end
end
