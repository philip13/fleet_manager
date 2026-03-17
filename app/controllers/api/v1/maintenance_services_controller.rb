module Api
  module V1
    class MaintenanceServicesController < BaseController
      before_action :set_vehicle, only: [ :index, :create ]
      before_action :set_service, only: [ :update ]

      def index
        services = @vehicle.maintenance_services
                           .includes(:vehicle)
                           .order(date: :desc)
                           .page(params[:page])
                           .per(params[:per_page])

        render json: {
          data: ActiveModelSerializers::SerializableResource.new(services),
          meta: pagination_meta(services)
        }
      end

    def create
      service = @vehicle.maintenance_services.new(maintenance_service_params)

      if service.save
        render json: { data: MaintenanceServiceSerializer.new(service) }, status: :created
      else
        render_error(
          code:    "validation_error",
          message: "Maintenance service could not be created",
          status:  :unprocessable_entity,
          details: service.errors.as_json
        )
      end
    end

    def update
      if @service.update(maintenance_service_params)
        render json: { data: MaintenanceServiceSerializer.new(@service) }
      else
        render_error(
          code:    "validation_error",
          message: "Maintenance service could not be updated",
          status:  :unprocessable_entity,
          details: @service.errors.as_json
        )
      end
    end

      private

      def maintenance_service_params
        params.require(:maintenance_service).permit(:description, :status, :date, :cost_cents, :priority, :completed_at)
      end

      def set_vehicle
        @vehicle = Vehicle.find(params[:vehicle_id])
      end

      def set_service
        @service = MaintenanceService.find(params[:id])
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
