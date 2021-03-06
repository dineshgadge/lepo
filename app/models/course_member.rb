# == Schema Information
#
# Table name: course_members
#
#  id          :integer          not null, primary key
#  course_id   :integer
#  user_id     :integer
#  role        :string
#  group_index :integer          default(0)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class CourseMember < ApplicationRecord
  belongs_to :course
  belongs_to :user
  validates_presence_of :course_id
  validates_presence_of :user_id
  validates_uniqueness_of :course_id, scope: [:user_id]
  # FIXME: Group work
  validates_inclusion_of :group_index, in: (0...COURSE_GROUP_MAX_SIZE).to_a
  validates_inclusion_of :role, in: %w[manager assistant learner]

  def deletable?
    stickies = Sticky.where(course_id: course_id, manager_id: user_id)
    case role
    when 'manager'
      course = Course.find(course_id)
      return false if course.evaluator? user_id

      manager_num = CourseMember.where(course_id: course_id, role: 'manager').size
      return (stickies.size.zero? && (manager_num > 1))
    when 'assistant'
      return stickies.size.zero?
    when 'learner'
      outcomes = Outcome.where(manager_id: user_id, course_id: course_id)
      outcomes.each do |outcome|
        return false unless outcome.outcome_messages.empty?
      end
      return stickies.size.zero?
    end
    false
  end

  def self.update_managers(course_id, current_ids, ids)
    transaction do
      # unregister
      current_ids.each do |c_id|
        if ids.include? c_id
          # neednot add or delete
          ids.delete c_id
        else
          course_member = CourseMember.find_by(course_id: course_id, user_id: c_id, role: 'manager')
          course_member.destroy! if course_member.deletable?
        end
      end
      # register
      ids.each do |id|
        course_member = CourseMember.new(course_id: course_id, user_id: id, role: 'manager')
        course_member.save!
      end
    end
    return true
  rescue => e
    logger.info(e.inspect)
    return false
  end
end
