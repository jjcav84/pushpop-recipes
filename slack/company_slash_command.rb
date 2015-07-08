require 'pushpop'
require 'pushpop-slack'
require 'clearbit'
require 'json'

Clearbit.key = ENV['CLEARBIT_KEY']

# This will put the domain in the 3rd match group
domain_regexp = /^((http|https):\/\/)?([a-z0-9]*(\.?[a-z0-9]+)\.[a-z]{2,5})(:[0-9]{1,5})?(\/.)?$/ix

job do
  
  webhook 'slack/company' do
    if params[:token] == ENV['SLACK_TOKEN_COMPANY']
      uri = domain_regexp.match(params[:text])
      if uri.nil? or uri[3].nil?
        body 'You need to send a domain.'
        status 401
        false
      else
        begin
          company = Clearbit::Streaming::Company[domain: uri[3]]

          if company.nil?
            body "No data available for #{uri[3]}"
            status 404
            false
          else
            body ''
            {
              company: company,
              channel: params[:channel_name],
              user: params[:user_name]
            }
          end
        rescue
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

    company = details[:company]

    message "*#{company[:legalName]}* #{company[:site][:url]}"

    company_info = {
      fallback: company[:description],
      title: 'Company Info',
      color: '#00cfbb',
      fields: [
        {
          title: 'Description',
          value: company[:description],
          short: false
        },
        {
          title: 'Industry',
          value: "#{company[:category][:subIndustry]} (#{company[:category][:industry]})",
          short: true
        }
      ]
    }

    if company.has_key?('geo') && !company[:geo][:city].nil?
      company_info[:fields].push({
        title: 'Location',
        value: "#{company[:geo][:city]}, #{company[:geo][:state]}",
        short: true
      })
    end

    unless company[:metrics][:raised].nil?
      commafied = company[:metrics][:raised].to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
      company_info[:fields].push({
        title: 'Funding',
        value: "$#{commafied}",
        short: true
      })
    end

    unless company[:metrics][:marketCap].nil?
      commafied = company[:metrics][:marketCap].to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
      company_info[:fields].push({
        title: 'Market Cap',
        value: "$#{commafied}",
        short: true
      })
    end

    unless company[:metrics][:employees].nil?
      company_info[:fields].push({
        title: '# Employees',
        value: company[:metrics][:employees],
        short: true
      })
    end

    contact_info = {
      fallback: "Can't display contact info on this client... sorry.",
      title: "Contact/Social Info",
      color: '#00bbde',
      fields: []
    }

    unless company[:facebook][:handle].nil?
      contact_info[:fields].push({
        title: "Facebook",
        value: "https://www.facebook.com/#{company[:facebook][:handle]}",
        short: true 
      })
    end

    unless company[:twitter][:handle].nil?
      contact_info[:fields].push({
        title: "Twitter",
        value: "https://twitter.com/#{company[:twitter][:handle]}",
        short: true 
      })
    end

    unless company[:angellist][:handle].nil?
      contact_info[:fields].push({
        title: "AngelList",
        value: "https://angel.co/#{company[:angellist][:handle]}",
        short: true 
      })
    end

    unless company[:crunchbase][:handle].nil?
      contact_info[:fields].push({
        title: "Crunchbase",
        value: "https://www.crunchbase.com/organization/#{company[:crunchbase][:handle]}",
        short: true 
      })
    end

    attachment company_info

    if contact_info[:fields].length > 0
      attachment contact_info
    end
  end
end
