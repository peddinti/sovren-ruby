##
# Creates the Sovren initializer file for Rails apps.
#
# @example Invokation from terminal
#   rails generate sovren ACCOUNT_ID SERVICE_KEY
#
module Sovren
  class InstallGenerator < Rails::Generators::Base
    # Adds current directory to source paths, so we can find the template file.
    source_root File.expand_path('..', __FILE__)

    argument :account_id, required: false
    argument :service_key, required: false

    desc 'Configures the Sovren client with your account id and service key'
    def generate_layout
      template 'sovren_initializer.rb.erb', 'config/initializers/sovren.rb'
    end
  end
end