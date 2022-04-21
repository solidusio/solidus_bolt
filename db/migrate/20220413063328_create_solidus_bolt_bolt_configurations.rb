class CreateSolidusBoltBoltConfigurations < ActiveRecord::Migration[6.1]
  def change
    create_table :solidus_bolt_bolt_configurations do |t|
      t.string :bearer_token
      t.string :environment_url
      t.string :merchant_public_id
      t.string :merchant_id
      t.string :api_key
      t.string :signing_secret
      t.string :publishable_key
      t.timestamps
    end
  end
end
