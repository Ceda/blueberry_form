require 'rubygems/specification'
require 'rails/generators/named_base'
require 'rails/generators/resource_helpers'
require 'rails/generators/migration'
require 'rails/generators/active_record'

module Blueberry
  module Generators
    class FormGenerator < Rails::Generators::NamedBase
      include Rails::Generators::ResourceHelpers
      include Rails::Generators::Migration

      source_root File.expand_path('../templates', __FILE__)

      check_class_collision suffix: "Controller"

      check_class_collision suffix: "Helper"

      class_option :orm, banner: "NAME", type: :string, required: true,
                   desc: "ORM to generate the controller for"

      class_option :parent_controller, banner: "admin", type: :string, default: "application",
                   desc: "Define the parent controller"

      argument :attributes, type: :array, default: [], banner: "field:type field:type"

      def initialize(args, *options)
        super
      end

      def generate_model
        invoke "active_record:model", [name, *attributes.map { |c| "#{c.name}:#{c.type}" }], migration: true
      end

      def create_controller_files
        template "controllers/railties/controller.rb.erb", File.join('app/controllers', class_path, "#{controller_file_name}_controller.rb")
      end

      def create_root_folder
        empty_directory File.join("app/views", controller_file_path)
      end

      def copy_view_files
        available_views.each do |view|
          filename = filename_with_extensions(view)
          template_path = "views/#{handler}/#{filename}"
          template template_path, File.join("app/views", controller_file_path, filename)
        end

        template "views/#{handler}/create.js.erb", File.join("app/views", controller_file_path, "create.js.erb")

        render_info_banner
      end

      hook_for :helper, in: :rails do |helper|
        invoke helper, [controller_class_name]
      end

      hook_for :resource_route, in: :rails do |resource_route|
        invoke resource_route, [class_name]
      end

      protected

      def render_info_banner
        puts ' ' * 80
        puts '-' * 80
        puts "| Render form in your view | ".center(80)
        puts '-' * 80
        puts ' ' * 80
        puts ".#{singular_table_name}-box = render '#{controller_file_path}/form'"
        puts ".#{singular_table_name}-state"
        puts ' ' * 80
        puts '-' * 80
      end

      def parent_controller_class_name
        options[:parent_controller].capitalize
      end

      def available_views
        %w(_thanks _state _form)
      end

      def format
        :html
      end

      def handler
        :slim
      end

      def migration_attributes
        attributes.collect { |c| "'#{c.name}:#{c.type}'" }.join(',')
      end

      def filename_with_extensions(name)
        [name, format, handler].compact.join(".")
      end

      def self.check_class_collision(options={})
        define_method :check_class_collision do
          name = if self.respond_to?(:controller_class_name)
            controller_class_name
          elsif self.respond_to?(:controller_class_name)
            controller_class_name
          else
            class_name
          end

          class_collisions "#{name}#{options[:suffix]}"
        end
      end
    end
  end
end
