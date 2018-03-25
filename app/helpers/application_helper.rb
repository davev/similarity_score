module ApplicationHelper

  def format_avg(f)
    f.to_s.gsub(/^0+/, '')
  end

end
