class CondosController < ApplicationController
  def index
    authorize Condo
    @condos = policy_scope(Condo)
    if params[:search].present?
      @condos = @condos.where("name ILIKE :q OR address ILIKE :q", q: "%#{params[:search]}%")
    end
  end

  def show
    @condo = Condo.find(params[:id])
    authorize @condo
  end

  def new
    @condo = Condo.new
    authorize @condo
  end

  def create
    @condo = Condo.new(condo_params)
    authorize @condo

    if @condo.save
      redirect_to @condo, notice: "Condo was successfully created."
    else
      render :new
    end
  end

  def edit
    @condo = Condo.find(params[:id])
    authorize @condo
  end

  def update
    @condo = Condo.find(params[:id])
    authorize @condo

    if @condo.update(condo_params)
      redirect_to @condo, notice: "Condo was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @condo = Condo.find(params[:id])
    authorize @condo

    @condo.destroy
    redirect_to condos_path, notice: "Condo was successfully deleted."
  end

  private

  def condo_params
    params.require(:condo).permit(:name, :address)
  end

end
