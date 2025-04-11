class Employeeinfo < ApplicationRecord
    has_many :employeecertificates, dependent: :destroy
    accepts_nested_attributes_for :employeecertificates, allow_destroy: true
    has_one_attached :pan_card
end
