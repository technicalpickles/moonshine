require 'rbconfig'

class MoonshineGenerator < Rails::Generators::Base
  argument :name, :optional => true, :default => 'application'

  def manifest
    directory 'app/manifests'
    directory 'app/manifests/templates'
    template  'moonshine.rb', "app/manifests/#{file_name}.rb"
    directory 'app/manifests/templates'
    template  'readme.templates', 'app/manifests/templates/README'
    directory 'config'
    template  'moonshine.yml', "config/moonshine.yml"
    template  'gems.yml', "config/gems.yml", :assigns => { :gems => gems }
    
    intro = <<-INTRO
    
After the Moonshine generator finishes don't forget to:

- Edit config/moonshine.yml
Use this file to manage configuration related to deploying and running the app: 
domain name, git repos, package dependencies for gems, and more.

- Edit app/manifests/#{file_name}.rb
Use this to manage the configuration of everything else on the server:
define the server 'stack', cron jobs, mail aliases, configuration files 

    INTRO
    puts intro if File.basename($0) == 'generate'
  end

protected
  def file_name
    @file_name ||= name.downcase.underscore + "_manifest"
  end

  def klass_name
    @klass_name ||= @file_name.classify
  end

  def gems
    gem_array = returning Array.new do |hash|
      Rails.configuration.gems.map do |gem|
        hash = { :name => gem.name }
        hash.merge!(:source => gem.source) if gem.source
        hash.merge!(:version => gem.requirement.to_s) if gem.requirement
        hash
      end if Rails.respond_to?( 'configuration' )
    end
    if (RAILS_GEM_VERSION rescue false)
      gem_array << {:name => 'rails', :version => RAILS_GEM_VERSION }
    else
      gem_array << {:name => 'rails'}
    end
    gem_array
  end

  
end
