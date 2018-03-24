class AddPitchingStatsToCareerStat < ActiveRecord::Migration[5.1]
  def change
    add_column :career_stats, :w, :integer
    add_column :career_stats, :l, :integer
    add_column :career_stats, :era, :float
    add_column :career_stats, :g, :integer
    add_column :career_stats, :ip, :float
    add_column :career_stats, :so, :integer
    add_column :career_stats, :whip, :float
  end
end
