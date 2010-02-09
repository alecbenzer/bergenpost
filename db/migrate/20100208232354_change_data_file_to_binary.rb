class ChangeDataFileToBinary < ActiveRecord::Migration
  def self.up
    change_table :data_files do |t|
      t.remove :data
      t.binary :data
    end
  end

  def self.down
    change_table :data_files do |t|
      t.remove :data
      t.string :data
    end
  end
end
