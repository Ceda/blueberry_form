module InheritedResourcesController
  extend ActiveSupport::Concern

  included do
    inherit_resources

    def create
      create! { collection_url }
    end

    def update
      update! { collection_url }
    end

  end

end
