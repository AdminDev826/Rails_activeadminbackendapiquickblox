class ChangeVerifiedDefaultForExistingUsers < ActiveRecord::Migration
  def change
  	User.all.map{|u| u.update(verified: true)}
  end
end
