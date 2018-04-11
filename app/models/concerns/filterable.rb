module Filterable
  extend ActiveSupport::Concern

  module ClassMethods

    def filter(filtering_params)
      results = nil
      filtering_params.each do |key, value|
        if results.present?
          results = results.public_send(key, value) if value.present?
        else
          results = Task.public_send(key, value) if value.present?
        end
      end
      results
    end
  end
end