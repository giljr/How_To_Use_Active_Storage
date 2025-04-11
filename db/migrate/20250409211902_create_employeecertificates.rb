class CreateEmployeecertificates < ActiveRecord::Migration[8.0]
  def change
    create_table :employeecertificates do |t|
      t.references :employeeinfo, null: false, foreign_key: true

      t.timestamps
    end
  end
end
