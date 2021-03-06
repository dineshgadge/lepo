class StickiesController < ApplicationController
  module AllActions
    # ====================================================================
    # Public Functions
    # ====================================================================
    def ajax_create_sticky
      sticky = Sticky.new(sticky_params)
      sticky.manager_id = session[:id]
      return unless sticky.save

      set_star_sort_stickies_session
      case sticky.target_type
      when 'page'
        stickies = stickies_by_content_from_panel sticky.target_id, sticky.content_id
        @sticky = Sticky.new(course_id: sticky.course_id, content_id: sticky.content_id, target_type: sticky.target_type, target_id: sticky.target_id)
      when 'note'
        stickies = stickies_by_note_from_panel sticky.target_id
        @sticky = Sticky.new(course_id: sticky.course_id, target_type: sticky.target_type, target_id: sticky.target_id)
      end
      session[:sticky_panel] = 'show'
      render_page_with_sticky_panel stickies
    end

    def ajax_search_sticky
      @keyword = params[:keyword]
      @stickies = searched_stickies @keyword
      render 'stickies/renders/sticky_reports'
    end

    def ajax_update_sticky
      sticky = Sticky.find(params[:id])
      sticky.update_attributes(sticky_params)
      sticky = Sticky.find(params[:id])
      render 'stickies/renders/update', locals: { sticky: sticky, view_category: params[:view_category] }
    end

    def ajax_arrange_stickies
      content_id = params[:content_id].to_i
      set_related_course_stickies_session params[:related_course_stickies] if params[:related_course_stickies]
      set_star_sort_stickies_session params[:star_sort_stickies] if params[:star_sort_stickies]
      view_category = params[:view_category]
      stickies = stickies_by_content content_id
      stickies.select! { |s| s.category == params[:view_category] }
      render 'stickies/renders/stickies', locals: { view_category: view_category, stickies: stickies, content_id: content_id }
    end

    def ajax_arrange_sticky_panel
      case params[:target_type]
      when 'page'
        set_star_sort_stickies_session params[:star_sort_stickies] if params[:star_sort_stickies]
        case session[:nav_section]
        when 'open_courses', 'repository'
          @sticky = Sticky.new(content_id: params[:content_id], course_id: session[:nav_id], target_type: params[:target_type], target_id: params[:target_id])
        else
          @sticky = Sticky.new(content_id: params[:content_id], target_type: params[:target_type], target_id: params[:target_id])
        end
        stickies = stickies_by_content_from_panel @sticky.target_id, @sticky.content_id
      when 'note'
        @sticky = Sticky.new(course_id: session[:nav_id], target_type: params[:target_type], target_id: params[:target_id])
        stickies = stickies_by_note_from_panel @sticky.target_id
      end
      case params[:sticky_panel]
      when 'show', 'mini'
        session[:sticky_panel] = params[:sticky_panel]
      when 'private', 'course'
        session[:sticky_panel] = 'edit'
        @sticky.category = params[:sticky_panel]
      end
      render 'stickies/renders/sticky_panel', locals: { stickies: stickies }
    end

    def ajax_destroy_sticky
      @keyword = params[:keyword] if params[:keyword]
      sticky = Sticky.find(params[:id])
      content_id = sticky.content_id
      target_type = sticky.target_type
      target_id = sticky.target_id
      sticky.destroy if sticky.destroyable? session[:id]

      if params[:view_category] == 'panel'
        render_sticky_panel sticky.course_id, target_type, target_id, content_id
      else
        render_sticky_view params[:view_category], target_type, target_id, content_id
      end
    end

    def ajax_toggle_star_sticky
      @keyword = params[:keyword] if params[:keyword]
      sticky = Sticky.find_by(id: params[:id])
      if sticky
        user_id = session[:id]
        sticky_star = StickyStar.find_by_manager_id_and_sticky_id(user_id, sticky.id)
        star_increment = 1

        Sticky.transaction do
          if sticky_star
            star_increment = -1 if sticky_star.stared
            sticky_star.update_attributes!(stared: !sticky_star.stared)
          else
            StickyStar.create!(manager_id: user_id, sticky_id: sticky.id)
          end
          stars_count = sticky.stars_count + star_increment
          sticky.update_attributes!(stars_count: stars_count)
        end
      end

      if params[:view_category] == 'panel'
        render_sticky_panel sticky.course_id, params[:target_type], params[:target_id], params[:content_id]
      else
        render_sticky_view params[:view_category], params[:target_type], params[:target_id], params[:content_id]
      end
    end

    # ====================================================================
    # Private Functions
    # ====================================================================

    private

    def last_sticky_dates(lessons)
      set_star_sort_stickies_session
      last_sticky_dates = []
      lessons.each_with_index do |l, i|
        stickies = get_course_stickies session[:nav_id], 'page', l.content_id
        last_sticky_dates[i] = stickies[0].updated_at unless stickies.empty?
      end
      last_sticky_dates
    end

    def render_sticky_panel(course_id, target_type, target_id, content_id = nil)
      case target_type
      when 'page'
        stickies = stickies_by_content_from_panel target_id, content_id
        @sticky = Sticky.new(course_id: course_id, target_type: 'page', target_id: target_id, content_id: content_id)
      when 'note'
        stickies = stickies_by_note_from_panel target_id
        @sticky = Sticky.new(course_id: course_id, target_type: 'note', target_id: target_id)
      end
      render_page_with_sticky_panel stickies
    end

    def render_sticky_view(view_category, _target_type, _target_id, content_id = nil)
      case view_category
      when 'course', 'private'
        stickies = stickies_by_content content_id
        stickies = stickies.select { |s| s.category == view_category }
        render 'stickies/renders/stickies', locals: { stickies: stickies, view_category: view_category, content_id: content_id }
      when 'hot'
        course = Course.find session[:nav_id]
        stickies = course.hot_stickies
        render 'stickies/renders/hot_stickies', locals: { stickies: stickies, view_category: view_category, content_id: content_id }
      when 'user'
        stickies = course_stickies_by_user session[:id], session[:nav_id]
        render 'stickies/renders/stickies', locals: { stickies: stickies, view_category: view_category, content_id: content_id }
      when 'search'
        @stickies = searched_stickies params[:keyword]
        render 'stickies/renders/sticky_reports'
      end
    end

    def stickies_by_content(content_id)
      case session[:nav_section]
      when 'home'
        get_stickies content_id, 'page'
      else
        get_course_stickies session[:nav_id], 'page', content_id
      end
    end

    def stickies_by_content_from_panel(target_id, content_id)
      if (session[:nav_section] == 'open_courses') || ((session[:nav_section] == 'repository') && (session[:nav_controller] == 'courses'))
        content = Content.find(content_id)
        get_course_stickies_by_target session[:nav_id], 'page', target_id, content.id
      else
        get_stickies content_id, 'page', target_id
      end
    end

    def stickies_by_note_from_panel(target_id)
      get_course_stickies_by_target session[:nav_id], 'note', target_id
    end

    def course_stickies_by_user(user_id, course_id)
      Sticky.where(category: 'course', manager_id: user_id, course_id: course_id).order(created_at: :desc).limit(20)
    end

    def render_page_with_sticky_panel(stickies)
      render 'stickies/renders/sticky_panel', locals: { stickies: stickies }
    end

    def searched_stickies(keyword = nil)
      case session[:nav_section]
      when 'home'
        stickies = Sticky.search_by_manager session[:id], keyword
      when 'open_courses', 'repository'
        stickies = Sticky.search_by_course session[:id], session[:nav_id], keyword
      end
      stickies
    end

    def sticky_params
      params.require(:sticky).permit(:content_id, :course_id, :target_type, :target_id, :category, :message)
    end
  end
end
