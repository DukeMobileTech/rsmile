class SafetyPlan
  include Prawn::View

  PAGE = '<page>'.freeze
  BLUE = '296891'

  def initialize(content)
    super()
    @content = content
    @language = content['language']&.downcase&.strip
    register_fonts
    write_content
    number_odd_pages
    number_even_pages
    secure_content
  end

  def register_fonts
    font_families.update(
      'Tahoma' => {
        bold: "#{Rails.root}/app/pdfs/fonts/Tahoma-Bold.ttf",
        normal: "#{Rails.root}/app/pdfs/fonts/Tahoma.ttf"
      },
      'Geneva' => {
        normal: "#{Rails.root}/app/pdfs/fonts/Geneva.ttf"
      },
      'BeVietnamPro' => {
        bold: "#{Rails.root}/app/pdfs/fonts/BeVietnamPro-Bold.ttf",
        normal: "#{Rails.root}/app/pdfs/fonts/BeVietnamPro-Regular.ttf",
        bold_italic: "#{Rails.root}/app/pdfs/fonts/BeVietnamPro-BoldItalic.ttf",
        italic: "#{Rails.root}/app/pdfs/fonts/BeVietnamPro-MediumItalic.ttf"
      }
    )
    font 'BeVietnamPro'
    font_size 12
    self.fallback_fonts = %w[Tahoma Geneva]
    default_leading 5
  end

  def write_content
    page_one
    page_two
    page_three
    page_four
  end

  def page_one
    access_list = @content['access']&.split(',')&.map { |i| i.strip }&.sort
    text localize_text('title'), align: :center, color: BLUE, style: :bold, inline_format: true
    text localize_text('intro_title'), style: :bold, inline_format: true
    text localize_text('intro_p_1'), inline_format: true
    move_down 10
    text localize_text('intro_p_2'), inline_format: true
    indent(20) do
      (1..7).each do |i|
        text localize_text("intro_step_#{i}")
      end
    end
    move_down 10
    text localize_text('intro_p_3')
    move_down 10
    text localize_text('intro_p_4')
    move_down 20
    text localize_text('access_title'), style: :bold, inline_format: true
    text localize_text('access_p_1')
    move_down 10
    text localize_text('access_p_2'), inline_format: true
    indent(15) do
      if access_list&.include?('1')
        text "<b>[√]</b> #{localize_text('access_1')}", inline_format: true
      else
        text "[ ] #{localize_text('access_1')}", inline_format: true
      end
      indent(15) do
        text localize_text('access_1_1')
        text localize_text('access_1_2')
      end
    end
    indent(15) do
      if access_list&.include?('2')
        text "<b>[√]</b> #{localize_text('access_2')}", inline_format: true
      else
        text "[ ] #{localize_text('access_2')}", inline_format: true
      end
      indent(15) do
        text localize_text('access_2_1')
        text localize_text('access_2_2')
      end
    end
    indent(15) do
      if access_list&.include?('3')
        text "<b>[√]</b> #{localize_text('access_3')}", inline_format: true
      else
        text "[ ] #{localize_text('access_3')}", inline_format: true
      end
      indent(15) do
        text localize_text('access_3_1')
      end
    end
    indent(15) do
      if access_list&.include?('4')
        text "<b>[√]</b> #{localize_text('access_4')}", inline_format: true
      else
        text "[ ] #{localize_text('access_4')}", inline_format: true
      end
      indent(15) do
        text "<u>#{@content['access_other']}</u>", inline_format: true
      end
    end
  end

  def page_two
    warning_list = @content['warning']&.split(',')&.map { |i| i.strip }&.sort
    coping_list = @content['coping']&.split(',')&.map { |i| i.strip }&.sort
    move_down 20
    text localize_text('warning_title'), style: :bold, inline_format: true
    move_down 10
    text localize_text('warning_p_1')
    move_down 10
    text localize_text('warning_p_2'), inline_format: true
    indent(15) do
      (1..14).each do |i|
        if warning_list&.include?(i.to_s)
          text "<b>[√]</b> #{localize_text("warning_#{i}")}", inline_format: true
        else
          text "[ ] #{localize_text("warning_#{i}")}"
        end
      end
      if @content['warning_other'].strip.blank?
        text "[ ] #{localize_text('warning_15')}"
      else
        text "<b>[√]</b> #{localize_text('warning_15')} <u>#{@content['warning_other']}</u>", inline_format: true
      end
    end
    move_down 10
    text localize_text('cope_title'), style: :bold, inline_format: true
    move_down 10
    text localize_text('cope_p_1')
    move_down 10
    text localize_text('cope_p_2'), inline_format: true
    indent(15) do
      (1..14).each do |i|
        if coping_list&.include?(i.to_s)
          text "<b>[√]</b> #{localize_text("cope_#{i}")}", inline_format: true
        else
          text "[ ] #{localize_text("cope_#{i}")}"
        end
      end
      if @content['coping_other'].strip.blank?
        text "[ ] #{localize_text('cope_15')}"
      else
        text "<b>[√]</b> #{localize_text('cope_15')} <u>#{@content['coping_other']}</u>", inline_format: true
      end
    end
  end

  def page_three
    distractions = @content['person_or_place']&.split(',')
    distractions = distractions&.select { |i| !i&.include?(':') }&.map { |i| i.strip }
    support = @content['name_and_phone']&.split(',')
    support = support&.select { |i| !i&.include?(':') }&.map { |i| i.strip }
    move_down 20
    text localize_text('distract_title'), style: :bold, inline_format: true
    move_down 10
    text localize_text('distract_p_1')
    move_down 10
    text localize_text('distract_p_2'), inline_format: true
    indent(15) do
      distractions&.each do |pp|
        text localize_text('person_or_place') + "<u>#{pp}</u>", inline_format: true
      end
      start = distractions.nil? ? 1 : distractions&.size + 1
      (start..6).each do
        text localize_text('person_or_place')
      end
    end
    move_down 10
    text localize_text('social_title'), style: :bold, inline_format: true
    move_down 10
    text localize_text('social_p_1')
    move_down 10
    text localize_text('social_p_2'), inline_format: true
    move_down 10
    text localize_text('social_p_3')
    move_down 10
    indent(15) do
      support&.each do |ss|
        text localize_text('name_and_number') + "<u>#{ss}</u>", inline_format: true
      end
      start = support.nil? ? 1 : support&.size + 1
      (start..6).each do
        text localize_text('name_and_number')
      end
    end
  end

  def page_four
    professional = @content['professional_help']&.split(',')
    professional = professional&.map { |i| i&.include?(':') ? '' : i.strip }
    matters_list = @content['what_matters']&.split(',')&.map { |i| i.strip.to_i }&.sort
    matters_entry = @content['what_matters_entry']&.split(',')
    move_down 20
    text localize_text('prof_title'), style: :bold, inline_format: true
    move_down 10
    text localize_text('prof_p_1')
    move_down 10
    text localize_text('prof_p_2'), inline_format: true
    move_down 10
    indent(15) do
      text I18n.t('safety.prof_doctor', doctor: "<u>#{professional[0]}</u>", locale: @language),
           inline_format: true
      text I18n.t('safety.prof_provider', provider: "<u>#{professional[1]}</u>", locale: @language),
           inline_format: true
      text I18n.t('safety.prof_lifeline', lifeline: "<u>#{professional[2]}</u>", locale: @language),
           inline_format: true
      text I18n.t('safety.prof_community', community: "<u>#{professional[3]}</u>", locale: @language),
           inline_format: true
      text I18n.t('safety.prof_other', other: "<u>#{professional[4]}</u>", locale: @language), inline_format: true
    end
    move_down 10
    text localize_text('matters_title'), style: :bold, inline_format: true
    move_down 10
    text localize_text('matters_p_1')
    move_down 10
    text localize_text('matters_p_2'), inline_format: true
    move_down 10
    indent(15) do
      order = [1, 5, 6, 8, 2, 11, 4, 3, 7, 10, 9]
      order.each do |i|
        if matters_list&.include?(i)
          index = order.find_index(i)
          if !matters_entry[index]&.include?(':')
            text "<b>[√]</b> #{localize_text("matters_#{i}")}", inline_format: true
          else
            text "<b>[√]</b> #{localize_text("matters_#{i}")} <u>#{matters_entry[index].strip}</u>", inline_format: true
          end
        else
          text "[ ] #{localize_text("matters_#{i}")}", inline_format: true
        end
      end
    end
    move_down 10
    text localize_text('conclusion_title'), style: :bold, inline_format: true
    move_down 10
    text localize_text('conclusion_p_1')
    move_down 10
    text localize_text('conclusion_p_2')
  end

  def localize_text(key)
    I18n.t("safety.#{key}", locale: @language)
  end

  def number_odd_pages
    odd_options = {
      at: [bounds.right - 150, 0],
      width: 150,
      align: :right,
      page_filter: :odd,
      start_count_at: 1
    }
    number_pages PAGE, odd_options
  end

  def number_even_pages
    even_options = {
      at: [0, bounds.left],
      width: 150,
      align: :left,
      page_filter: :even,
      start_count_at: 2
    }
    number_pages PAGE, even_options
  end

  def secure_content
    password = @content['password']
    if password.blank?
      encrypt_document
    else
      encrypt_document(user_password: password, owner_password: password)
    end
  end
end
