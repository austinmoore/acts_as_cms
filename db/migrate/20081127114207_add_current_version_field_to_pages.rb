class AddCurrentVersionFieldToPages < ActiveRecord::Migration
  def self.up
    change_table :pages do |t|
      t.string :current_version
    end
  end

  def self.down
    change_table :pages do |t|
      t.remove :current_version
    end
  end
end
