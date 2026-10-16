module ProjectsHelper
  def project_progress(project)
    case project.status
    when :upcoming then "começa em #{project.starts_on.strftime("%d/%m")}"
    when :active   then "dia #{project.day_number(Date.current)} de #{Project::DURATION}"
    when :finished then "terminou em #{project.ends_on.strftime("%d/%m")}"
    end
  end
end
