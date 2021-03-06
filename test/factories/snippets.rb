# == Schema Information
#
# Table name: snippets
#
#  id            :integer          not null, primary key
#  manager_id    :integer
#  note_id       :integer
#  category      :string           default("text")
#  description   :text
#  source_type   :string           default("direct")
#  source_id     :integer
#  master_id     :integer
#  display_order :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryGirl.define do
  factory :snippet do
    association :manager, factory: :user
    association :note
    association :source, factory: :web_source
    description 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
    sequence(:master_id) { |i| i }
    sequence(:display_order) { |i| i }

    factory :header_snippet do
      category 'header'
    end

    factory :subheader_snippet do
      category 'subheader'
    end

    factory :upload_image_snippet do
      source_type 'upload'
      category 'image'
    end

    factory :upload_pdf_snippet do
      source_type 'upload'
      category 'pdf'
    end

    factory :web_text_snippet do
      source_type 'web'
      category 'text'
    end

    factory :web_image_snippet do
      source_type 'web'
      category 'image'
      description 'sample.png'
    end

    factory :web_pdf_snippet do
      source_type 'web'
      category 'pdf'
    end

    factory :web_scratch_snippet do
      source_type 'web'
      category 'scratch'
    end

    factory :web_ted_snippet do
      source_type 'web'
      category 'ted'
    end

    factory :web_youtube_snippet do
      source_type 'web'
      category 'youtube'
    end
  end
end
