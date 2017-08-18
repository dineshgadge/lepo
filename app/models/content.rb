# == Schema Information
#
# Table name: contents
#
#  id          :integer          not null, primary key
#  category    :string
#  folder_id   :string
#  title       :string
#  condition   :text
#  overview    :text
#  status      :string           default("open")
#  as_category :string           default("text")
#  as_overview :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Content < ApplicationRecord
  include RandomString
  before_validation :set_default_value
  has_one :manager, -> { where('content_members.role = ?', 'manager') }, through: :content_members, source: :user
  has_many :asset_files, -> { order(upload_file_name: :asc) }, dependent: :destroy
  has_many :attachment_files, -> { order(upload_file_name: :asc) }, dependent: :destroy
  has_many :courses, through: :lessons
  has_many :content_members, dependent: :destroy
  has_many :assistants, -> { where('content_members.role = ?', 'assistant') }, through: :content_members, source: :user
  has_many :users, -> { where('content_members.role = ?', 'user') }, through: :content_members, source: :user
  has_many :lessons
  has_many :objectives, -> { order(id: :asc) }, dependent: :destroy
  has_many :page_files, -> { order(display_order: :asc) }, dependent: :destroy
  has_many :stickies, -> { where('stickies.target_type = ?', 'page') }, dependent: :destroy
  validates_presence_of :folder_id
  validates_presence_of :overview
  validates_presence_of :title
  validates_uniqueness_of :folder_id
  validates_inclusion_of :as_category, in: %w[text file outside]
  validates_inclusion_of :category, in: %w[upload]
  validates_inclusion_of :status, in: %w[open archived]
  #  validate :presence_of_objective  # doesn't work for update(2011-01-09)
  #  validate_on_create :presence_of_objective

  accepts_nested_attributes_for :objectives, allow_destroy: true, reject_if: proc { |att| att['title'].blank? }, limit: CONTENT_OBJECTIVE_MAX_SIZE
  after_save :adjust_allocation

  # ====================================================================
  # Public Functions
  # ====================================================================
  def self.associated_by(user_id, role)
    contents = ContentMember.where(user_id: user_id, role: role).to_a
    contents.map!(&:content)
    contents.sort! { |a, b| a.updated_at <=> b.updated_at }
    contents.reverse!
  end

  def self.associated_by_with_status(user_id, role, status)
    contents = associated_by user_id, role
    contents.delete_if { |c| c.status != status }
  end

  def self.associated_by_without_status(user_id, role, status)
    contents = associated_by user_id, role
    contents.delete_if { |c| c.status == status }
  end

  def page_file_id(page_num)
    pages = page_files.select(:id).to_a
    return pages[page_num - 1].id if (page_num >= 1) && (page_num <= pages.size)
    return -1 if (page_num == -1) || (page_num == pages.size + 1) # content assignment page
    0 # content cover page or something wrong
  end

  def self.by_system_managers
    contents = []
    User.system_staffs.each do |sm|
      contents += associated_by_with_status sm.id, 'manager', 'open'
    end
    contents
  end

  def self.transitionable?(from_status, to_status)
    # FIXME: status
    return true if from_status == to_status
    case from_status
    when 'open'
      return true if to_status == 'archived'
    end
    false
  end

  def fill_objectives
    (CONTENT_OBJECTIVE_MAX_SIZE - objectives.size).times do |_o|
      objectives.build
    end
  end

  def manager
    content_manager = content_members.find_by_role('manager')
    content_manager.user
  end

  def manager?(user_id)
    manager.id == user_id
  end

  def manager_changeable?(user_id)
    manager?(user_id) || User.find(user_id).system_staff?
  end

  def assistant?(user_id)
    assistants.each do |s|
      return true if s.id == user_id
    end
    false
  end

  def editable_objectives?
    lessons = self.lessons
    lessons.each do |ls|
      ls.outcomes.each do |lp|
        return false unless lp.objectives.empty?
      end
    end
    true
  end

  def staff?(user_id)
    (manager? user_id) || (assistant? user_id)
  end

  def deletable?(user_id)
    return false if new_record?
    lessons.size.zero? && (staff? user_id)
  end

  def fill_goals
    (COURSE_GOAL_MAX_SIZE - goals.size).times do |_g|
      goals.build
    end
  end

  def presence_of_objective
    errors.add(:objectives, 'を、1つ以上設定する必要があります') if objectives.empty?
  end

  def status_display_order
    case status
    when 'open'
      0
    when 'archived'
      1
    end
  end

  # ====================================================================
  # Private Functions
  # ====================================================================

  private

  def adjust_allocation
    # make summation of allocations equal to 10 (default maximum objective num is 3, ability is less edqual than 5)
    mean_allocation = [[10], [5, 5], [4, 3, 3], [3, 3, 2, 2], [2, 2, 2, 2, 2]]

    return if objectives.empty? # for unexpected error rescue
    # achievement allocation sum check
    allocation_sum = 0
    objectives.each do |objective|
      allocation_sum += objective.allocation
    end
    return if allocation_sum == 10

    # achievement allocation adjustment
    allocation_array = mean_allocation[(objectives.size - 1)]
    objectives.each_with_index do |objective, i|
      objective.allocation = allocation_array[i]
    end
    save
  end

  def set_default_value
    self.folder_id = random_string(FOLDER_NAME_LENGTH) unless folder_id
  end
end
