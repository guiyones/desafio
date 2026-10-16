module ProjectsHelper
  def project_progress(project)
    case project.status
    when :upcoming then "começa em #{project.starts_on.strftime("%d/%m")}"
    when :active   then "dia #{project.day_number(Date.current)} de #{Project::DURATION}"
    when :finished then "terminou em #{project.ends_on.strftime("%d/%m")}"
    end
  end

  def project_elapsed_percentage(project)
    (project.elapsed_days.count * 100.0 / Project::DURATION).round
  end
end
