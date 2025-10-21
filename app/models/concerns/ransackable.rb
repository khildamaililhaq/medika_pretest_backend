module Ransackable
  extend ActiveSupport::Concern

  included do
    def self.ransackable_attributes(auth_object = nil)
      authorizable_ransackable_attributes
    end

    def self.ransackable_associations(auth_object = nil)
      authorizable_ransackable_associations
    end

    def self.authorizable_ransackable_attributes
      column_names + _ransackers.keys
    end

    def self.authorizable_ransackable_associations
      reflect_on_all_associations.map { |a| a.name.to_s }
    end
  end
end
