require 'sinatra'
require 'sinatra/content_for'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'pry'
require_relative 'timer.rb'
require_relative 'database_persistence.rb'
set :port, 9494

configure do
  use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'secret'

  set :erb, escape_html: true
end

configure(:development) do
  require "sinatra/reloader"
  also_reload "database_persistence.rb"
end



helpers do
  def convert_hours(hrs)
    hours, mins = hrs.divmod(1)
    mins = (mins * 60).round(0)

    if mins == 60
      mins = 0
      hours += 1
    end

    return "#{hours}:#{pad_num(mins, 2)}"
  end

  def pad_num(num, length)
    num_string = "#{num}"

    while (num_string.length < length)
      num_string = '0' + num_string
    end

    return num_string
  end

  def display_date(date)
    month_names = ["n/a", "January", "Febuary", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    year, month, day = date.split('-')
    return "#{month_names[month.to_i]} #{day}, #{year}"
  end
end

def get_date(time_obj)
  year = time_obj.year
  month = time_obj.month
  day = time_obj.day

  return "#{year}-#{month}-#{day}"
end

before do
  @log = LogDatabasePersistence.new(logger)
  @hours_today = session[:hours_today] || 0
  @start_time = session[:start_time]
  @current_date = get_date(Time.now)
  @force_log_day = false;
end

get "/" do
  redirect "/home"
end

get "/home" do
  if session[:today] && (session[:today] != @current_date)
    @force_log_day = true
  else
    @force_log_day = false
    @days_logged = @log.hours_worked_list
    @hours_worked_yesterday = @log.hours_worked_yesterday.to_f.round(2)
  end
  @hours_this_week = @log.hours_this_week.to_f.round(2)
  @hours_last_week = @log.get_hours_last_week.to_f.round(2)
  @hours_this_month = @log.get_hours_this_month.to_f.round(2)

  if @log.last_month_hours_not_archived
    @hours_last_month = @log.last_month_hours_not_archived.to_f.round(2);
  else
    @hours_last_month = @log.last_month_hours_from_archive.to_f.round(2);
  end

  if @log.last_month_hours_not_archived && Time.now.day > 7
    @log.archive_last_month
    @log.delete_last_month
  end
  @best_month = @log.best_month
  @best_month_hrs = @log.best_month_hrs.to_f.round(2)

  @progress_percent = (@hours_today / 10) * 100
  erb :home
  # erb :index
end

# get "/session_info" do
#   session
#   # redirect "/home"
# end

post "/start_time" do
  session[:start_time] = Time.now
  session[:today] = session[:today] || get_date(session[:start_time])
  redirect "/home"
end

post "/stop_time" do
  end_time = Time.now
  # session[:hours_today] = 1.47
  session[:hours_today] += ((end_time - @start_time) / 3600).round(3)
  session[:start_time] = nil

  redirect "/home"
end

post "/log_day" do
  @log.log_day(session[:hours_today], session[:today])
  session[:start_time] = nil
  session[:today] = nil
  session[:hours_today] = 0
  session[:success] = "Your day has been logged"

  redirect "/home"
end

post "/reset" do
  session[:start_time] = nil
  session[:today] = nil
  session[:hours_today] = 0

  redirect "/home"
end
