class MaintenanceServicesController < ApplicationController
  def new
    @vehicle = Vehicle.find(params[:vehicle_id])
    @maintenance_service = @vehicle.maintenance_services.new
  end

  def create
    @vehicle = Vehicle.find(params[:vehicle_id])
    @maintenance_service = @vehicle.maintenance_services.new(maintenance_service_params)
    binding.irb
    if @maintenance_service.save
      @vehicle.sync_status!
      redirect_to @vehicle, notice: "Maintenance service was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @vehicle = Vehicle.find(params[:vehicle_id])
    @maintenance_service = @vehicle.maintenance_services.find(params[:id])
  end

  def update
    @vehicle = Vehicle.find(params[:vehicle_id])
    @maintenance_service = @vehicle.maintenance_services.find(params[:id])

    if @maintenance_service.update(maintenance_service_params)
      @vehicle.sync_status!
      redirect_to @vehicle, notice: "Maintenance service was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
  def maintenance_service_params
    params.require(:maintenance_service).permit(
      :description, :status, :date, :cost_cents, :priority, :completed_at
    )
  end
end
