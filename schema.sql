-- database timer_log

DROP TABLE IF EXISTS public.logged_work;

CREATE TABLE logged_work (
  id serial PRIMARY KEY,
  log_day date not null default CURRENT_DATE,
  hrs_worked float NOT NULL,
  memo text DEFAULT 'N/A'
);

insert into logged_work (log_day, hrs_worked) values
  ('2017-11-02', 6),
  ('2017-11-03', 7.1),
  ('2017-11-04', 1.05);

drop table archive_months;

CREATE TABLE archive_months (
  id serial PRIMARY KEY,
  month numeric not null,
  year numeric not null,
  hrs_worked float not null
);

-- Insert archive month
insert into archive_months (month, year, hrs_worked) values
  ((select case
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

-- Delete months from logged_work
delete from logged_work where extract(month from log_day) = 12 and extract(year from log_day) = 2018;
