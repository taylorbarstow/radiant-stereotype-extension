class AddStereotype < ActiveRecord::Migration
  def self.up
    add_column :pages, :stereotype, :string
  end

  def self.down
    remove_column :pages, :stereotype, :string
  end
end
