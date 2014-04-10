require "mantis_bug_reporter/version"
require "savon"

module MantisBugReporter
  class Client
    def initialize(username, password, wsdl, project_id, project_name)
      Savon.configure do |config|
        config.log = false
      end

      @username = username
      @password = password
      @wsdl     = wsdl
      @project_id = project_id
      @project_name = project_name
    end

    def mc_issue_exists?(issue_id)
      client = Savon.client(@wsdl)
      response = client.request(:mc_issue_exists) do
        soap.body = {
          username: username,
          password: password,
          "issue_id" => issue_id
        }
      end
      if response.success?
        return response.body[:mc_issue_exists_response][:return]
      end
    end

    def mc_issue_note_add(issue_id, note)
      client = Savon.client(@wsdl)
      response = client.request(:mc_issue_note_add) do
        soap.body = {
          :username => username,
          :password => password,
          "issue_id" => issue_id,
          :note => { text: note }
        }
      end
      if response.success?
        return note_id = response.body[:mc_issue_note_add_response][:return]
      end
    end

    # Creates an issue in Mantis
    def mc_issue_add(summary, additional_information, category, description)
      client = Savon.client(@wsdl)
      response = client.request(:mc_issue_add) do
        soap.body = {
          :username => username,
          :password => password,
          :issue => {
            :summary => removeUniqueIdentifier(summary),
            :project =>  { :id => @project_id, :name => project_name }, # For some reason Mantis wants the id and the name
            :category => category,
            :description => description + "<br /> <br />" + additional_information
          }
        }
      end
    end

    def mc_issue_get(issue_id)
      client = Savon.client(@wsdl)
      response = client.request(:mc_issue_get) do
        soap.body = {
          :username => username,
          :password => password,
          "issue_id" => issue_id
        }
      end
      if response.success?
        return response.body[:mc_issue_get_response][:return]
      end
    end

    def mc_issue_update(issue)
      client = Savon.client(@wsdl)
      response = client.request(:mc_issue_update) do
        soap.body = {
          :username => username,
          :password => password,
          "issue_id" => issue[:id],
          :issue => issue
        }
      end
    end

    # Checks if an issue already exists in Mantis by the summary
    def mc_issue_get_id_from_summary(summary)
      client = Savon.client(@wsdl)
      response = client.request(:mc_issue_get_id_from_summary) do
        soap.body = {
          :username => username,
          :password => password,
          :summary => { text: removeUniqueIdentifier(summary[0..127]) } #Summary character max is 128
        }
      end
      if response.success?
        return response.body[:mc_issue_get_id_from_summary_response][:return]
      end
    end

    def file_bug(exception, env)
      summary = env["action_dispatch.request.path_parameters"][:controller] + "_controller - " + exception.to_s
      category = "2. Development (Implementation) - Bug"
      description = "The controller " + env["action_dispatch.request.path_parameters"][:controller] + " experienced an exception of " + exception.to_s
      additional_information = exception.backtrace.to_s.delete("[" "]").gsub(",","<br />")
      
      issue_id = self.mc_issue_get_id_from_summary(removeUniqueIdentifier(summary))
      if issue_id.to_i == 0
        self.mc_issue_add(summary, additional_information, category, description)
      else
        issue = self.mc_issue_get(issue_id.to_i)
        begin
          self.mc_issue_update(increment_mantis_reports_field(issue))
        rescue Savon::Error => error
          logger.debug error.to_s
          puts error.to_s
        end
      end
    end

    # We need these because Savon uses instance_eval for the request method
    # which means that we do not have access to our MantisConnect::Client's
    # instance variables within that block.
    private
    def username
      @username
    end

    def password
      @password
    end

    def project_id
      @project_id
    end

    def project_name
      @project_name
    end

    # Removes unique identifer if it exists
    # Example <ReportViewsController:0x0000000865a240> to <ReportViewsController>
    def removeUniqueIdentifier(exception) 
      if exception.index(':0x') != nil
        return exception[0..(exception.index(':0x')-1)] + exception[(exception.index(':0x')+17)..-1]
      else
        return exception
      end
    end

    def increment_mantis_reports_field(issue)
      issue[:custom_fields][:item].each do |item|
        if item[:field][:name] == "Reports"
          binding.pry
          if item[:value].class == Hash
            item.merge!(:value => "1")
          else
            item[:value] = (item[:value].to_i + 1).to_s
          end
        end
      end
      return issue
    end
  end
end
