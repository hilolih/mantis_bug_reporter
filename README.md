# MantisBugReporter

NOTE: Renamed the gem from Mantis Auto Bug to Mantis Bug Reporter

TODO: Fix updating an issue

## Installation

Add this line to your application's Gemfile:

    gem 'mantis_bug_reporter'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mantis_auto_bug

## Usage

Instantiate an instace of Mantis Bug Reporter :

    MantisBugReporter::Client(username, password, wsdl, project_id, project_name)
    
File Bug method (Custom method I made for my projects)

    client.file_bug(exception_object, env_object)
    
    First checks if an issue already exists for a project. If so, it grabs the issue and then tries to update a
    custom field I have created called Reports by incrementing the count to indicate how many times the bug has
    been reporter. If not, it creates a new issue within Mantis. 
    
Available methods to hook into:
    
    client.mc_issue_exists?(issue_id)
    client.mc_issue_get(issue_id)
    client.mc_issue_note_add(issue_id, note)
    client.mc_issue_add(summary, additional_information, category, description)
    client.mc_issue_update(issue) #Currently not working :(
    client.mc_issue_get_id_from_summary(summary)
    

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
