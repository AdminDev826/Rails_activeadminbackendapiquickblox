statuses = @statuses
puts statuses.inspect

json.task_statuses statuses do |k, v|
    json.status k
    json.value v
end
