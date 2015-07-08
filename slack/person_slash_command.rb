require 'pushpop'
require 'pushpop-slack'
require 'clearbit'
require 'json'

Clearbit.key = ENV['CLEARBIT_KEY']

job do
  
  webhook 'slack/person' do
    if params[:token] == ENV['SLACK_TOKEN_PERSON']

      # Fuzzy email validation
      if !params[:text].include?('@')
        body 'You need to send an email address.'
        status 401
        false
      else
        begin
          person = Clearbit::Streaming::Person.find(email: params[:text])

          if person.nil?
            body "No data available for #{params[:text]}"
            status 404
            false
          else
            body ''
            {
              person: person,
              channel: params[:channel_name],
              user: params[:user_name]
            }
          end
        rescue Exception => e
          puts e.message

          body 'Something weird happened... maybe try again?'
          status 500
          false
        end
      end  
    else
      body "Invalid token"
      status 403
      false
    end
  end

  slack do |details|
    channel details[:channel]
    username 'Pushpop'

    person = details[:person]

    message "*#{person[:name][:fullName]}* -- #{person[:email]}"

    person_info = {
      fallback: person[:description],
      title: 'Personal Info',
      color: '#00cfbb',
      fields: []
    }

    unless person[:bio].nil?
      person_info[:fields].push({
        title: "Bio",
        value: person[:bio],
        short: false
      })
    end

    unless person[:site].nil?
      person_info[:fields].push({
        title: "Website",
        value: person[:site],
        short: true
      })
    end

    if person.has_key?('geo') && !person[:geo][:city].nil?
      person_info[:fields].push({
        title: 'Location',
        value: "#{person[:geo][:city]}, #{person[:geo][:state]}",
        short: true
      })
    end

    unless person[:employment].nil? || person[:employment][:name].nil? || person[:employment][:domain].nil?
      person_info[:fields].push({
        title: "Employer",
        value: "#{person[:employment][:name]} -- #{person[:employment][:domain]}",
        short: true
      })
    end

    unless person[:twitter][:handle].nil?
      person_info[:fields].push({
        title: "Twitter",
        value: "https://twitter.com/#{person[:twitter][:handle]}",
        short: true
      })
    end

    unless person[:linkedin][:handle].nil?
      person_info[:fields].push({
        title: "Linkedin",
        value: "https://www.linkedin.com/#{person[:linkedin][:handle]}",
        short: true
      })
    end

    if person_info[:fields].length > 0
      attachment person_info
    end
  end
end
