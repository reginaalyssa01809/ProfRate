class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :edit, :update, :destroy]

  # GET /courses
  # GET /courses.json
  def index
    @courses = Course.all
  end

  # GET /courses/1
  # GET /courses/1.json
  def show
    @professors = @course.professors
    @other_professors = Professor.all - @professors
    @course_professor_association = CourseProfessorAssociation.where(course_id: @course.id, professor_id: @professors.select(:id)).select(:average_rating)
  end

  # GET /courses/new
  def new
    @course = Course.new

    if params[:professor_id]
      if Professor.exists?(params[:professor_id])
        professor = Professor.find(params[:professor_id])
        @professor_name = professor.full_name
        @professor_id = professor.id
      else
        @course.errors[:professor] << ["Couldn't find Professor with 'id'=#{params[:professor_id]}"]
        @professor_id = -1
      end
    end
  end

  # GET /courses/1/edit
  def edit
  end

  # POST /courses
  # POST /courses.json
  def create
    @course = Course.new(course_params)

    # no professor_id given, save only Course
    if params[:course][:professor_id].nil?
      save_course = true

    # professor_id exists, save Course and create association with Professor
    elsif Professor.exists?(params[:course][:professor_id])
      save_course = true
      create_association = true

    # professor_id is invalid, return error
    else
      @course.errors[:professor] << ["Not found, submitting this form will add a new course but will not add an association with any professor"]
      return_error = true
    end

    respond_to do |format|
      if save_course
        if @course.save
          format.html { redirect_to @course, notice: 'Course was successfully created.' }
          format.json { render :show, status: :created, location: @course }
        else
          return_error = true
        end
      end

      if return_error
        format.html { render :new }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end

    if create_association
      professor = Professor.find(params[:course][:professor_id])
      @course.professors << professor
    end

  end

  # PATCH/PUT /courses/1
  # PATCH/PUT /courses/1.json
  def update
    respond_to do |format|
      if @course.update(course_params)
        format.html { redirect_to @course, notice: 'Course was successfully updated.' }
        format.json { render :show, status: :ok, location: @course }
      else
        format.html { render :edit }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /courses/1
  # DELETE /courses/1.json
  def destroy
    @course.destroy
    respond_to do |format|
      format.html { redirect_to courses_url, notice: 'Course was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # POST /add_professor
  # Add existing professor to course
  def add_professor
    professor_id = params[:add_professor][:professor_id]
    course_id = params[:add_professor][:course_id]

    if Professor.exists?(professor_id) and Course.exists?(course_id)
      professor = Professor.find(professor_id)
      @course = Course.find(course_id)
      @course.professors << professor
      create_association = true
    else
      return_error = true
    end

    if create_association
      respond_to do |format|
        if @course.save
          format.html { redirect_to @course, notice: 'Professor was successfully added to course.' }
          format.json { head :no_content }
        else
          return_error = true
        end
      end
    end

    if return_error
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course
      @course = Course.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def course_params
      params.require(:course).permit(:title, :description)
    end
end
