class AllTypesObjectsController < ApplicationController
  # GET /all_types_objects
  # GET /all_types_objects.json
  def index
    @all_types_objects = AllTypesObject.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @all_types_objects }
    end
  end

  # GET /all_types_objects/1
  # GET /all_types_objects/1.json
  def show
    @all_types_object = AllTypesObject.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @all_types_object }
    end
  end

  # GET /all_types_objects/new
  # GET /all_types_objects/new.json
  def new
    @all_types_object = AllTypesObject.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @all_types_object }
    end
  end

  # GET /all_types_objects/1/edit
  def edit
    @all_types_object = AllTypesObject.find(params[:id])
  end

  # POST /all_types_objects
  # POST /all_types_objects.json
  def create
    @all_types_object = AllTypesObject.new(params[:all_types_object])

    respond_to do |format|
      if @all_types_object.save
        format.html { redirect_to @all_types_object, notice: 'All types object was successfully created.' }
        format.json { render json: @all_types_object, status: :created, location: @all_types_object }
      else
        format.html { render action: "new" }
        format.json { render json: @all_types_object.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /all_types_objects/1
  # PUT /all_types_objects/1.json
  def update
    @all_types_object = AllTypesObject.find(params[:id])

    respond_to do |format|
      if @all_types_object.update_attributes(params[:all_types_object])
        format.html { redirect_to @all_types_object, notice: 'All types object was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @all_types_object.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /all_types_objects/1
  # DELETE /all_types_objects/1.json
  def destroy
    @all_types_object = AllTypesObject.find(params[:id])
    @all_types_object.destroy

    respond_to do |format|
      format.html { redirect_to all_types_objects_url }
      format.json { head :no_content }
    end
  end
end
