require 'keen'
require 'mail'
require 'time'
require 'pushpop'
require 'pushpop-keen'
require 'date'
require 'json'

def calcPercentage(a,b)
    if b == 0 then return 0 end
    return (Float(a - b)/b * 100).round
end

# Used for converting 2-step funnels into array of conversions per interval.
def zip_and_percent(zip)
    raise "Need both daily_wins and daily_attempts. Provided: #{zip.keys}" unless zip.keys.include?(:daily_wins) and zip.keys.include?(:daily_attempts)
    raise "Unmatched Zipper Length" if zip[:daily_wins].length != zip[:daily_attempts].length

    r = []

    (0..(zip[:daily_wins].length-1)).each do |i|
        # puts "TRY", zip[:daily_attempts][i]
        # puts "WIN", zip[:daily_wins][i]

        a = zip[:daily_attempts][i]["value"]
        w = zip[:daily_wins][i]["value"].to_f

        todays_perc = (a==0) ? 0 : (w / a * 100).round

        r << { "value" => todays_perc }
    end

    r
end

# Padding methods
class Array
  def rjust(n, x); Array.new([0, n-length].max, x)+self end
  def ljust(n, x); dup.fill(x, length...n) end
end

def chart_src(data)
    url = 'https://chart.googleapis.com/chart?cht=ls&chs=200x50&chxr=1,0,28&chg=25,25,3,3&chd=t:'

    max = data.max || 0
    scaled_data = data.map { |d| (max==0) ? 0 : (100.0 * d/max).round }

    url += scaled_data.ljust(28, '0').join(',')

    url += '&raw_data=' + data.ljust(28, '0').join(',')
end

# HACK appends % to visible value of steps whose name ends in % (Trailing % removed from name later on)
def todays_value(set_name, data)
    data.last.round.to_s + (set_name.chars.last == '%' ? '%' : '')
end

# Trailing 28 day period (starts yesterday so metrics are complete)
metrics_timeframe = {
    "start" => 29.days.ago.beginning_of_day.iso8601,
    "end"   =>  1.days.ago.end_of_day.iso8601
}


puts "TIMEFRAME", metrics_timeframe

job do
    every 24.hours, at: "13:00" #based in europe, so this is 6 am PST

    # The stats to be emailed:
    keen "New Registrations" do
        #puts "signups"
        event_collection    "Sign Up Completed"
        analysis_type       "count"
        timeframe           metrics_timeframe
        interval            "daily"
    end

    # ... more stats ...

    # Example stat using a 2-step funnel and zip_and_percent to show daily conversion rate
    step "Percent of Users Who Complete Registration After Starting%" do
        #puts "complete_reg"
        sign_up_starts      = Keen.count('Sign Up Started',
                                            timeframe:          'last_28_days',
                                            interval:           'daily'
                                            )

        sign_up_completes   = Keen.count('Sign Up Completed',
                                            timeframe:          'last_28_days',
                                            interval:           'daily'
                                            )

        # puts "STARTS", JSON.pretty_generate(sign_up_starts)
        # puts "COMPLETES", JSON.pretty_generate(sign_up_completes)

        zip_and_percent daily_wins: sign_up_completes, daily_attempts: sign_up_starts
    end

    step "deliver" do |_, results|
        Mail.defaults do
            delivery_method :smtp, { :address              => "smtp.sendgrid.net",
                                     :port                 => 587,
                                     :domain               => "###########",
                                     :user_name            => "###########",
                                     :password             => "###########",
                                     :authentication       => 'plain',
                                     :enable_starttls_auto => true }
        end
        mail = Mail.deliver do
            to ENV['TRENDING_TO']
            from "###########"
            subject "Trending Metrics Report"
            text_part do
                body "This email must be viewed as HTML."
            end
            html_part do
                content_type "text/html; charset=UTF-8"
                body results.map { |set_name, data|
                    data.map! {|d| (d['value'] || 0).round }

                    html = ''
                    html += "<div><b>#{set_name.gsub(/\%$/,'')}:</b></div>"
                    html += "<div><img src=\"#{chart_src(data)}\" /><span style=\"font-size: 200%;\">#{todays_value(set_name, data)}</span></div><br>"
                    html
                }.join('')
            end
        end
    end
end
