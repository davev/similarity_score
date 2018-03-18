

class AddTrigramIndexOnNameToPlayers < ActiveRecord::Migration[5.1]
  # for concurrently, need to disable running this migration inside of a transaction
  # https://robots.thoughtbot.com/how-to-create-postgres-indexes-concurrently-in
  disable_ddl_transaction!


  # generates trigram index on players.name, such as:
  #   CREATE INDEX CONCURRENTLY index_players_on_name_gin_trgm_ops
  #   ON players
  #   USING gin (name gin_trgm_ops);

  # info on trigram indexes: https://about.gitlab.com/2016/03/18/fast-search-using-postgresql-trigram-indexes/
  def change
    add_index :players, "name gin_trgm_ops", using: :gin, algorithm: :concurrently
  end
end
