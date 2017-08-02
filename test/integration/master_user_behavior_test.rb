require 'test_helper'

class MasterUserBehaviorTest < ActionDispatch::IntegrationTest
  test 'setup / signin page behavior' do
    DatabaseCleaner.cleaning do
      # before initial setup
      visit root_path
      assert page.has_selector?('#setup-resource')
      assert_not page.has_selector?('#signin-resource')

      # after initial setup
      create(:user, role: 'admin')
      visit root_path
      assert page.has_selector?('#signin-resource')
      assert_not page.has_selector?('#setup-resource')
    end
  end

  test 'new course creation behavior' do
    user = create(:user, role: 'admin')
    signin_with user.user_id, user.password
    assert page.has_selector?('#dashboard-resource')
    # create_new_term

    new_course_creation_from_sub_pane
    new_course_creation_from_main_pane
  end

  # ====================================================================
  # Private Functions
  # ====================================================================
  private

  # def create_new_term
  #   click_main_nav_item I18n.t('views.navs.preferences'), '#preference-resource'
  #   click_on('term-pref')
  #
  #   term = build(:term)
  # end

  def new_course_creation_from_sub_pane
    term = create(:term)

    assert_not page.has_selector?('#sub-pane .dropdown-menu')
    click_on('new-resource-btn')
    assert page.has_selector?('#sub-pane .dropdown-menu')
    click_on(I18n.t('views.navs.new_course'))
    fill_in_course_form term, true
    click_on('cancel-btn')
    assert page.has_selector?('#edit-course')
    click_on('next-btn')
    assert page.has_selector?('#edit-lessons')
    click_on('complete-btn')
    assert page.has_selector?('#course-resource')
  end

  def new_course_creation_from_main_pane
    term = create(:term)

    click_main_nav_item I18n.t('views.navs.preferences'), '#preference-resource'
    assert page.has_selector?('#preference-resource')
    click_on('new-course-pref')
    fill_in_course_form term, true
    click_on('complete-btn')
    assert page.has_selector?('#course-resource')
  end

  def fill_in_course_form(term, new_record)
    expected_selector = new_record ? '#new-course' : '#edit-course'
    assert page.has_selector?(expected_selector)
    course = build(:course)
    assert page.has_selector?('#course-form')
    within('#course-form') do
      fill_in 'course_title', with: course.title
      select term.title, from: 'course_term_id'
      fill_in 'course_overview', with: course.overview
      # click_on('running_title')
      click_on 'submit-btn'
    end
    assert page.has_selector?('#edit-lessons')
  end
end