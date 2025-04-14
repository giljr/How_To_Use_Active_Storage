class EmployeeinfodetailsController < ApplicationController
  before_action :set_employee, only: [:show]

  def index
    @employees = Employeeinfo.all
  end

  def new
    @employee = Employeeinfo.new
  end

  def create
    @employee = Employeeinfo.new(employee_params)

    if @employee.save
      handle_employee_files
      @employee.update(certificate_params)
      redirect_to employeeinfodetails_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    return head :not_found unless @employee

    @folder_name = employee_folder_name(@employee)
    folder_path = employee_folder_path(@folder_name)

    @cv_file_path = public_file_path(folder_path, 'cv')
    @my_pic_file_path = public_file_path(folder_path, 'my_pic')

    certi_folder = folder_path.join('certificates')
    @certificates = Dir["#{certi_folder}/*"].map do |file|
      Pathname.new(file).relative_path_from(Rails.public_path).to_s
    end
  end

  # app/controllers/employeeinfodetails_controller.rb

  # app/controllers/employeeinfodetails_controller.rb

  def download_file
    path = Rails.root.join("public", params[:download_path])

    if File.exist?(path)
      filename = File.basename(path)
      response.headers["Content-Type"] = Mime::Type.lookup_by_extension(File.extname(filename).delete('.')).to_s
      response.headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
      response.headers["Content-Length"] = File.size(path).to_s

      File.open(path, "rb") do |file|
        response.stream.write file.read
      end
    else
      render plain: "File not found", status: :not_found
    end
  ensure
    response.stream.close
  end

  private

  def set_employee
    @employee = Employeeinfo.find_by(id: params[:id])
  end

  def employee_params
    params.require(:employeeinfo).permit(:firstname, :lastname, :pan_card)
  end

  def certificate_params
    params.require(:employee).permit(employeecertificates_attributes: [:certi])
  end

  def employee_folder_name(employee)
    "#{employee.id}_#{employee.lastname}"
  end

  def employee_folder_path(folder_name)
    Rails.public_path.join('employee_files', folder_name)
  end

  def public_file_path(folder_path, keyword)
    file = Dir["#{folder_path}/*"].find { |f| f.include?(keyword) }
    Pathname.new(file).relative_path_from(Rails.public_path).to_s if file
  end

  def handle_employee_files
    folder_name = employee_folder_name(@employee)
    folder_path = employee_folder_path(folder_name)
    FileUtils.mkdir_p(folder_path)

    upload_file(params[:cv], folder_path, "#{folder_name}_cv")
    upload_file(params[:photo], folder_path, "#{folder_name}_my_pic")

    certificate_path = folder_path.join('certificates')
    FileUtils.mkdir_p(certificate_path)

    params.dig(:employee, :employeecertificates_attributes)&.each_with_index do |certificate, index|
      upload_file(certificate[:certi], certificate_path, "certificate_#{index + 1}")
    end
  end

  def upload_file(uploaded_file, folder_path, new_name)
    return unless uploaded_file.respond_to?(:original_filename)

    ext = File.extname(uploaded_file.original_filename)
    new_filename = "#{new_name}#{ext}"
    full_path = folder_path.join(new_filename)

    File.open(full_path, 'wb') do |file|
      file.write(uploaded_file.read)
    end
  end
end
