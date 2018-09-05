require 'pg'
# require 'pry'

class LogDatabasePersistence
  def initialize(logger)
    @db = if Sinatra::Base.production?
            PG.connect(ENV['DATABASE_URL'])
          else
            PG.connect(dbname: 'timer_log')
          end
    @logger = logger
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

  def hours_worked_list()
    sql = "SELECT * FROM logged_work ORDER BY log_day;"

    result = query(sql)

    result.map do |tuple|
      create_log(tuple)
    end
  end

  def log_day(hrs, date)
    sql = "INSERT INTO logged_work (log_day, hrs_worked) values ($1, $2)"
    query(sql, date, hrs)
  end

  def hours_worked_yesterday
    sql = <<~SQL
      select hrs_worked from logged_work
        where log_day = current_date - interval '1 day';
      SQL
    result = query(sql)
    if (result.first)
      return result.first["hrs_worked"]
    else
      return 0
    end
  end

  def hours_this_week
    sql = <<~SQL
      select sum(hrs_worked) from logged_work
        where log_day >= (
          select date_trunc('week', current_date)
        );
      SQL
      result = query(sql)
      result.first["sum"]
  end


  def get_hours_last_week
    sql = <<~SQL
      select sum(hrs_worked) from logged_work
        where log_day between date_trunc('week', current_date - interval '1 week') and
        date_trunc('week', current_date) - interval '1 day';
      SQL
    result = query(sql)
    result.first["sum"]
  end

  def get_hours_this_month
    sql = <<~SQL
      select sum(hrs_worked) from logged_work
        where extract(month from log_day) =
          extract(month from current_date);
      SQL
    result = query(sql)
    result.first["sum"]
  end

  def last_month_hours_not_archived
    sql = <<~SQL
      select sum(hrs_worked) from logged_work where extract(month from log_day) =
        case
          when extract(month from current_date) = 1 then 12
          else extract(month from current_date) - 1
        end;
      SQL
    result = query(sql)
    result.first["sum"]
  end

  def last_month_hours_from_archive
    sql = <<~SQL
      select hrs_worked from archive_months
        where month =
        case when extract(month from current_date) = 1 then 12
             else extract(month from current_date) - 1
        end;
      SQL
    result = query(sql)
    result.first["hrs_worked"]
  end

  def most_productive_month
    sql = <<~SQL
      select * from archive_months where
        hrs_worked = (select max (hrs_worked) from archive_months);
      SQL
    result = query(sql).first
    # "#{months[result["month"].to_i]} #{result["year"]} (#{result["hrs_worked"]}hrs)"
  end

  def best_month
    result = most_productive_month
    months = ['n/a', 'January', 'Febuary', 'Marhc', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
    "#{months[result["month"].to_i]} #{result["year"]}"
  end

  def best_month_hrs
    most_productive_month["hrs_worked"]
  end

  def archive_last_month
    sql = <<~SQL
      insert into archive_months (month, year, hrs_worked) values
        (
          (select case
          when extract(month from current_date) = 1
            then 12
          else
            extract(month from current_date) - 1
          end),
         (select case
          when extract(month from current_date) = 1
            then extract(year from current_date) - 1
          else
            extract(year from current_date)
          end),
          (select sum(hrs_worked) from logged_work
            where extract(month from log_day) =
            case when extract(month from current_date) = 1 then 12
                 else extract(month from current_date) - 1
          end)
        );
      SQL
    query(sql)
  end

  def delete_last_month
    sql = <<~SQL
        delete from logged_work
          where extract(month from log_day) =
            case
              when extract(month from current_date) = 1 then 12
              else extract(month from current_date) - 1
            end
          and extract(year from log_day) =
            case
              when extract(month from current_date) = 1 then extract(year from current_date) - 1
              else extract(year from current_date)
            end;
        SQL
    query(sql)
  end



  private

  def create_log(tuple)
    { id: tuple["id"].to_i,
      date: tuple["log_day"],
      hours: tuple["hrs_worked"],
      memo: tuple["memo"]
    }
  end
end
