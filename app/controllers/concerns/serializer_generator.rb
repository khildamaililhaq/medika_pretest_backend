module SerializerGenerator
  extend ActiveSupport::Concern

  def generate_collection_serializer(resources, serializer)
    data = ActiveModel::Serializer::CollectionSerializer.new(
      resources, serializer:
    )

    render json: { meta: pagination(resources), data: }
  end

  private

  def pagination(resources)
    {
      per_page: resources.count,
      current_page: resources.current_page,
      next_page: resources.next_page,
      prev_page: resources.prev_page,
      total_page: resources.total_pages,
      total_data: resources.total_count
    }
  end
end
