# Active Storage Demo with Employee Info & Certificates

A simple Rails app demonstrating how to use Active Storage to upload and manage employee information, PAN card, and certificate attachments using nested forms, file system storage, and Bootstrap-styled views.

---

## 🔧 Setup

### Requirements

- **Ruby**: `3.2.3`
- **Rails**: `8.0.2`

---

## 🚀 Let's Get Started

> If you get stuck, check out [my tutorial](https://medium.com/jungletronics/work-with-active-storage-94dc4a7fc11f) for the full working version.

### 1. Create a New Rails App

```bash
rails new active_storage_demo
cd active_storage_demo
code .
```

### 2. Add Required Gems

In your Gemfile:
```ruby
gem "toastr-rails"
gem "jquery-rails"
gem "rails-ujs"
```

Then install them:

    bundle install

🔌 Setup Active Storage

    rails active_storage:install

Creates:

    active_storage_blobs

    active_storage_attachments

    active_storage_variant_records

🧱 Models
#### 1. Generate Models

rails g model employeeinfo firstname:string lastname:string
rails g model employeecertificate employeeinfo:references

#### 2. Setup Associations

`app/models/employeecertificate.rb`

```ruby
class Employeecertificate < ApplicationRecord
  belongs_to :employeeinfo
  has_one_attached :certi
end
```
`app/models/employeeinfo.rb`
```ruby
class Employeeinfo < ApplicationRecord
  has_many :employeecertificates, dependent: :destroy
  accepts_nested_attributes_for :employeecertificates, allow_destroy: true
  has_one_attached :pan_card
end
```
#### 3. Migrate Database

rails db:migrate

📁 Active Storage Config

`config/storage.yml
`
```ruby
test:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>

local:
  service: Disk
  root: <%= Rails.root.join("storage") %>
```

Uncomment and configure Amazon/GCS/Azure if needed for cloud deployments.

🎮 Controller

Generate controller:

    rails g controller employeeinfodetails

`app/controllers/employeeinfodetails_controller.rb`
```ruby
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
      FileUtils.mkdir_p(folder_path)

      upload_file(params[:cv], folder_path, "#{folder_name}_cv")
      upload_file(params[:photo], folder_path, "#{folder_name}_my_pic")

      certificate_path = folder_path.join('certificates')
      FileUtils.mkdir_p(certificate_path)

      params[:employee][:employeecertificates_attributes].each_with_index do |certificate, index|
        upload_file(certificate[:certi], certificate_path, "certificate_#{index + 1}")
      end

      @employee.update(certificate_params)
      redirect_to employeeinfodetails_path
    end
  end

  def show
    @employee = Employeeinfo.find_by(id: params[:id])
    if @employee
      @folder_name = "#{@employee.id}_#{@employee.lastname}"
      folder_path = Rails.public_path.join('employee_files', @folder_name)
      file_list = Dir["#{folder_path}/*"]

      @cv_file_path = extract_file_path(file_list, 'cv')
      @my_pic_file_path = extract_file_path(file_list, 'my_pic')

      certi_path = folder_path.join('certificates')
      certi_files = Dir["#{certi_path}/*"]
      @certificates = certi_files.map { |c| c[/"employee_files.*$/] }
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
    ext = File.extname(uploaded_file.original_filename)
    new_file = "#{new_fname}#{ext}"
    File.open(File.join(folder_path, new_file), 'wb') { |f| f.write(uploaded_file.read) }
  end

  def extract_file_path(files, keyword)
    file = files.find { |f| f.include?(keyword) }
    "employee_files/#{@folder_name}/#{File.basename(file)}" if file
  end
end
```
🗺 Routes

`config/routes.rb`
```ruby
resources :employeeinfodetails, only: [:index, :show, :create, :new]
root "employeeinfodetails#index"
get "employees/download_file" => "employeeinfodetails#download_file"
```
🎨 Front-End Setup

`app/views/layouts/application.html.erb`
```ruby
<!-- Bootstrap -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js"></script>

<!-- Bootstrap Icons -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

<!-- jQuery -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<!-- Toastr CSS/JS -->
<link href="https://cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/toastr.min.css" rel="stylesheet">
<script src="https://cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/toastr.min.js"></script>
```
    💡 Alternative:
 Use importmap (Rails 7+) via `config/importmap.rb` and `app/javascript/application.js`.

💻 JavaScript

`app/javascript/application.js
`
```ruby
import "@hotwired/turbo-rails"
import "controllers"

$(document).on('turbo:load', function() {
  addCertificate();
  submitEmployeeForm();
});

function addCertificate() {
  $('.add-certicate').on('click', function(e) {
    if ($('form .certi-box').length < 10) {
      // Add more certificate fields...
    }
  });
}
```
📂 Folder Structure Example
```ruby
public/employee_files/
  └── 1_Smith/
      ├── 1_Smith_cv.pdf
      ├── 1_Smith_my_pic.jpg
      └── certificates/
          ├── certificate_1.pdf
          └── certificate_2.pdf
```
✅ Done!

You now have a working Rails app with Active Storage, file uploads, nested attributes, and Bootstrap UI!

Happy coding! 🎉
## Authors

- [@jaythree](https://www.linkedin.com/in/giljrx/)


## Documentation

[Active Storage Overview](https://guides.rubyonrails.org/active_storage_overview.html#what-is-active-storage-questionmark)


## License

[MIT](https://choosealicense.com/licenses/mit/)

