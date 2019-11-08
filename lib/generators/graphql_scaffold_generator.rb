# encoding : utf-8
class GraphqlScaffoldGenerator < Rails::Generators::Base
  #require_relative 'graphql_scaffold_common_methods'
  #include GraphqlScaffoldCommonMethods

  # Resources
  # Generator : http://guides.rubyonrails.org/generators.html
  # ActiveAdmin with MetaSearch : https://github.com/gregbell/active_admin/tree/master/lib/active_admin
  # MetaSearch and ransack : https://github.com/ernie/meta_search & http://erniemiller.org/projects/metasearch/#description & http://github.com/ernie/ransack
  # Generator of rails : https://github.com/rails/rails/blob/master/railties/lib/rails/generators/erb/scaffold/scaffold_generator.rb

  #include Rails::Generators::ResourceHelpers

  source_root File.expand_path('../templates', __FILE__)

  argument :model_opt, type: :string, desc: "Name of model (singular)"
  argument :myattributes, type: :array, default: [], banner: "field:type field:type"

  class_option :namespace, default: nil
  class_option :donttouchgem, default: nil
  class_option :mountable_engine, default: nil

  def install_gems
    if options[:donttouchgem].blank? then
      require_gems
    end

    #inside Rails.root do # Bug ?!
    Bundler.with_clean_env do
      run "bundle install"
    end
  end

  def generate_controller
    # copy_file  "app/controllers/master_base.rb", "app/controllers/#{engine_name}beautiful_controller.rb"
    # dirs = ['app', 'controllers', engine_name, options[:namespace]].compact
    # # Avoid to remove app/controllers directory (https://github.com/rivsc/Beautiful-Scaffold/issues/6)
    # empty_directory File.join(dirs) if not options[:namespace].blank?
    # dest_ctrl_file = File.join([dirs, "#{model_pluralize}_controller.rb"].flatten)
    # template "app/controllers/base.rb", dest_ctrl_file
  end
  
end