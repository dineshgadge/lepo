# == Schema Information
#
# Table name: sticky_stars
#
#  id         :integer          not null, primary key
#  manager_id :integer
#  sticky_id  :integer
#  stared     :boolean          default(TRUE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :sticky_star do
    sequence(:manager_id) { |i| i }
    sequence(:sticky_id) { |i| i }
  end
end