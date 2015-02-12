#!/usr/bin/env ruby
# Aysar K ~ 2015

require 'rubygems'
require 'date'
require 'JSON'
require 'rest_client'

### ADD YOUR KEYS ###
a_api_key = ""
a_workspace_id = 1
t_api_key = ""
t_url_name = ""
#####################

asana_uri = "https://#{a_api_key}:@app.asana.com/api/1.0"
teamwork_uri = "https://#{t_api_key}:X@#{t_url_name}.teamwork.com"

a_projects_resp = RestClient.get "#{asana_uri}/workspaces/#{a_workspace_id}/projects?archived=false"
data = JSON.parse(a_projects_resp)['data']

puts "Found #{data.size} Asana projects to import to Teamwork"
puts "Continue? (y/n)"
continue = gets.strip
if (continue == "n")
	abort
end

data.each do |p|
	puts "Adding project #{p["name"]}..."
	a_p_resp = RestClient.get "#{asana_uri}/projects/#{p["id"]}"
	project = JSON.parse(a_p_resp)['data']
	
	# project creation
	t_project_content = { 'project' => {"name"=>p["name"], "description"=>project["notes"]} }.to_json
	RestClient.post("#{teamwork_uri}/projects.json", t_project_content, :content_type => :json, :accept => :json){ |response, request, result, &block|
		case response.code
		when 200
		t_project = JSON.parse(response)

		# tasklist creation
		t_tasklist_content = { 'todo-list' => {"name"=>"Master"} }.to_json
		t_tasklist_resp = RestClient.post "#{teamwork_uri}/projects/#{t_project["id"]}/todo_lists.json", t_tasklist_content, :content_type => :json, :accept => :json
		t_tasklist = JSON.parse(t_tasklist_resp)

		# asana task retieval
		puts "Adding tasks..."
		a_tasks_resp = RestClient.get "#{asana_uri}/projects/#{p["id"]}/tasks"
		a_tasks_data = JSON.parse(a_tasks_resp)['data']
		task_count = 0;
		tasks_size = a_tasks_data.size
		a_tasks_data.each do |a_task|
			task_count += 1
			print "#{task_count}/#{tasks_size} | "
			a_task_resp = RestClient.get "#{asana_uri}/tasks/#{a_task["id"]}"
			a_full_task = JSON.parse(a_task_resp)['data']

			# task creation
			duedate = ""
			if (a_full_task["due_on"] != nil)
				date = Date.parse(a_full_task["due_on"])
				duedate = date.strftime("%Y%m%d")
			end
			t_task_content = { 'todo-item' => {"content"=>a_full_task["name"], "description"=>a_full_task["notes"], "due-date"=>duedate} }.to_json
			t_task_resp = RestClient.post "#{teamwork_uri}/tasklists/#{t_tasklist["TASKLISTID"]}/tasks.json", t_task_content, :content_type => :json, :accept => :json
			t_task = JSON.parse(t_task_resp)
			if (a_full_task['completed'])
				t_task_complete = RestClient.put "#{teamwork_uri}/tasks/#{t_task["id"]}/complete.json", {}, :content_type => :json, :accept => :json
			end
		end
	when 422
		puts "#{response} for #{p["name"]}"
	else
		puts "Teamwork Error: #{response.code} #{response.to_str} for #{p["name"]}"
		puts "Continue? (y/n) "
		continue = gets.strip
		if (continue == "n")
			abort
		end
	end
	}
end
