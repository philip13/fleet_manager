module Api
  module V1
    class VehiclesController < BaseController
      def index
        vehicles = Vehicle.all
        vehicles = apply_filters(vehicles)
        vehicles = apply_search(vehicles)
        vehicles = apply_sorting(vehicles)
        vehicles = vehicles.page(params[:page]).per(params[:per_page])

        render json: {
          data: ActiveModelSerializers::SerializableResource.new(vehicles),
          meta: pagination_meta(vehicles)
        }
      end

      private

      def apply_filters(scope)
        scope = scope.where(status: params[:status]) if params[:status].present?
        scope = scope.where(brand: params[:brand])   if params[:brand].present?
        scope = scope.where(year: params[:year])     if params[:year].present?
        scope
      end

      def apply_search(scope)
        return scope unless params[:search].present?
        scope.where("LOWER(vin) LIKE :q OR LOWER(plate) LIKE :q", q: "%#{params[:search].downcase}%")
      end

      def apply_sorting(scope)
        allowed   = %w[vin plate brand model year status created_at]
        column    = allowed.include?(params[:sort]) ? params[:sort] : "created_at"
        direction = params[:direction] == "asc" ? "asc" : "desc"
        scope.order("#{column} #{direction}")
      end

      def pagination_meta(collection)
        {
          current_page: collection.current_page,
          next_page:    collection.next_page,
          prev_page:    collection.prev_page,
          total_pages:  collection.total_pages,
          total_count:  collection.total_count
        }
      end
    end
  end
end