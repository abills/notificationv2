class AddConfirmableToUsers < ActiveRecord::Migration
  def change
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :unconfirmed_email, :string
    add_column :users, :country_iso, :string
    add_column :users, :mobile_phone_no, :string
    add_column :users, :boxcar_id, :string
    add_column :users, :use_mobile_ph_flag, :integer
    add_column :users, :use_email_flag, :integer
    add_column :users, :use_im_flag, :integer
    add_column :users, :use_boxcar_flag, :integer
    add_column :users, :business_hrs_start, :integer
    add_column :users, :business_hrs_end, :integer
    add_column :users, :business_days, :integer
    add_column :users, :nma_api_key, :string
    add_column :users, :use_nma_flag, :integer
    add_column :users, :nmwp_api_key, :string
    add_column :users, :use_nmwp_flag, :integer
    add_column :users, :rss_token, :string
    add_column :users, :timezone, :float
  end
end
