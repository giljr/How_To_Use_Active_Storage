class EmployeeinfodetailsController < ApplicationController


    def index
          @employees = Employeeinfo.all
      end
  
      def new
      @employee = Employeeinfo.new
      end
  
      def create
          @employee = Employeeinfo.new(employee_params)
          if @employee.save
              folder_name = "#{@employee.id}_#{@employee.lastname}"
              folder_path = Rails.public_path.join('employee_files', folder_name)
              FileUtils.mkdir_p(folder_path) unless File.directory?(folder_path)
  
              upload_file(params[:cv], folder_path, "#{folder_name}_cv")
              upload_file(params[:photo], folder_path, "#{folder_name}_my_pic")
  
              certificate_path = Rails.public_path.join('employee_files', folder_name, 'certificates')
              FileUtils.mkdir_p(certificate_path) unless File.directory?(certificate_path)
  
              params[:employee][:employeecertificates_attributes].each_with_index do |certificate, index|
                  upload_file(certificate[:certi], certificate_path, "certificate_#{index+1}")
              end
  
              @employee.update(certificate_params)
              redirect_to employeeinfodetails_path
  
          end
          end
  
      def show
          @employee = Employeeinfo.find_by id: params[:id]
  
          if @employee.present?
              @folder_name = "#{@employee.id}_#{@employee.lastname}"
              folder_path = Rails.public_path.join('employee_files', @folder_name)
              file_list = Dir["#{folder_path.to_s}/*"]
  
              cv_file_name = file_list.find { |file| file.include?('cv') }.split("/").last
              my_pic_file_name = file_list.find { |file| file.include?('my_pic') }.split("/").last
              @cv_file_path = "employee_files/#{@folder_name}/#{cv_file_name}"
              @my_pic_file_path = "employee_files/#{@folder_name}/#{my_pic_file_name}"
  
              certi_folder_path = Rails.public_path.join('employee_files', @folder_name, 'certificates')
              certi_files = Dir["#{certi_folder_path.to_s}/*"]
              @certificates = certi_files.map { |certi| certi[certi.index("employee_files")..(certi.length)] }
  
          end
      end
  
  
      def download_file
          send_file("#{Rails.root}/public/#{params[:download_path]}")
      end
  
  
      private
      def employee_params
          params.require(:employeeinfo).permit(:firstname, :lastname, :pan_card)
      end
  
      def certificate_params
          params.require(:employee).permit(employeecertificates_attributes: [:certi])
      end
  
      def upload_file(uploaded_file, folder_path, new_fname)
      file_name = uploaded_file.original_filename
      file_extension = file_name.split(".").last
      new_file_name = "#{new_fname}.#{file_extension}"
  
      File.open(File.join(folder_path, new_file_name), 'wb') do |file|
        file.write(uploaded_file.read)
      end
  
  end
  
  end