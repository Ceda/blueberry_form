require 'pry'
require 'rails/generators/resource_helpers'
require 'rails/generators/active_record'


class InheritedResourcesViewsGenerator < Rails::Generators::NamedBase
  include Rails::Generators::ResourceHelpers
  desc "Generates inherited_resource_views templates."

  source_root File.expand_path('../../templates', __FILE__)

  argument :attributes, type: :array, default: [], banner: ":field :field"

  class_option :parent_controller, banner: "admin", type: :string, default: "base",
               desc: "Define the parent controller"


  def create_root_folder
    empty_directory File.join(base_directory, controller_file_path)
  end

  def copy_views
      available_views.each do |file|
        filename = filename_with_extensions(file)
        template_path = "views/#{handler}/#{filename}"

        filename = "_#{singular_table_name}.html.slim" if filename == '_model.html.slim'
        template template_path, File.join(base_directory, controller_file_path, filename)
      end
  end

  def create_controller_files
    template "controllers/controller.rb.erb", File.join('app/controllers/admin', class_path, "#{controller_file_name}_controller.rb")
    template "controllers/inherited_resources_controller.rb", File.join('app/controllers/concerns', 'inherited_resources_controller.rb')
  end

  def copy_translation_files
    template "config/translation.yml.erb", File.join('config/locales/', "#{controller_file_name}.yml")
  end

  protected

  def parent_controller_class_name
    options[:parent_controller].capitalize
  end

  def available_views
    %w(index edit new _form _empty _model)
  end

  def format
    :html
  end

  def handler
    :slim
  end

  def base_directory
    "app/views/admin"
  end

  def filename_with_extensions(name)
    [name, format, handler].compact.join(".")
  end

end
