local M = {}

local runners = {}
local last_command = ''
local commandIndex = 1
M.use_preCommand = false
M.precommand = 'start cmd.exe /k '

local findfile = function(name)
	local f = io.open(name,'r')
	if f~=nil then 
		io.close(f)
		return true 
	else
		return false 
	end
end

local get_runner_config = function()
	local commands = {}
	local lines = io.lines("runner.run")
	local pre = ''
	local sufx = ''
	local runner = {}
	runners = {}
	local i = 0
	for line in lines do
		l = line
		if string.find(line,':') == 1 then --[[ THis is a function ]] 
			i = i + 1
			if i > 1 then
				table.insert(runners,i,runner)
			end
			runner = {}
			runner.path = ''
			runner.peramitors = ''
			runner.executable = ''
			runner.funk_name=l
		end
		for pre,sufx in string.gmatch(line, "(.+)=(.+)") do 
			commandIndex = 1
			if pre == nil then
				break
			end
			if sufx == nil then
				break
			end
			if pre == 'PATH' then --[[ This is the main build path]] 
				runner.path = sufx .. '\\'
			end
			if pre == 'PERAM' then --[[ Peramitors for that build]] 
				runner.peramitors = sufx
			end
			if pre == 'EX' then --[[ The executable ]] 
				runner.executable = sufx
			end
			if pre == 'CMD' then --[[ This runs a console command ]] 
				table.insert(commands, commandIndex,sufx)
				runner.commands = commands
				commandIndex = commandIndex + 1
			end
			if pre == "PRE" then
				if sufx == 'true' then
					M.use_preCommand = true
				else
					M.use_preCommand = false
				end
				print(sufx)
			else
				M.use_preCommand = false
			end 
		end
	end
	table.insert(runners,i, runner)
end

local get_runner_options = function()
	local options = ''
	table.foreach(runners, function(t)
		local option = runners[t].funk_name
		print(option)
	end,
	{})
end

M.setup = function(m) 
	if m.precommand ~= nil then
		M.precommand = m.precommand
	end
	M.use_preCommand = false

	vim.api.nvim_create_user_command('RunnerCreate', function()
		if findfile("runner.run") == false then
			--code
			file = io.open('./runner.run', 'a')
			io.close(file)
			vim.cmd([[e runner.run]])
		else
			vim.cmd([[e runner.run]])
		end
	end,
	{})

	vim.api.nvim_create_user_command('RunnerOptions', function()
		if findfile("runner.run") == true then
			--code
			get_runner_config()
			get_runner_options()
		else
			print('Runner Config Not Found')
		end
	end,
	{})



	vim.api.nvim_create_user_command('RunnerSet', function() 

		if findfile("runner.run") == true then

			get_runner_config()
			get_runner_options()
			last_command = ''
			vim.ui.input({prompt = 'Runner: :'}, function(i) last_command = i end)
			last_command = ':' .. last_command
			print("\nlast command:"..last_command)
			local command = ''
			table.foreach(runners, function(t)

				if runners[t].funk_name == last_command then
					if runners[t].commands ~= nil then
						table.foreach(runners[t].commands, function(i)
							command = command .. runners[t].commands[i] .. ' & '
						end)
					else
						command = ''
					end
					local c = command .. runners[t].path ..runners[t].executable .. ' ' .. runners[t].peramitors
					if false == true then
						c = M.precommand .. '"' .. c .. '"'
					end 
					print('true')
					local handler = vim.fn.jobstart(c,{
						on_stdin = function(_,data,event)
						end
					})
					return 1
				end

			end)
		else
			print("ERROR runner file dose not exist.")
		end
	end,{})
	end,{})


	vim.api.nvim_create_user_command('Runner', function() 

		if findfile("runner.run") == true then

			get_runner_config()
			if last_command == '' then
				get_runner_options()
				vim.ui.input({prompt = 'Runner: :'}, function(i) last_command = i end)
				last_command = ':' .. last_command
			end
			print("\nlast command:"..last_command)
			local command = ''
			table.foreach(runners, function(t)

				if runners[t].funk_name == last_command then
					if runners[t].commands ~= nil then
						table.foreach(runners[t].commands, function(i)
							command = command .. runners[t].commands[i] .. ' & '
						end)
					else
						command = ''
					end
					local c = command .. runners[t].path ..runners[t].executable .. ' ' .. runners[t].peramitors
					if false == true then
						c = M.precommand .. '"' .. c .. '"'
					end 
					print('true')
					local handler = vim.fn.jobstart(c,{
						on_stdin = function(_,data,event)
						end
					})
					return 1
				end

			end)
		else
			print("ERROR runner file dose not exist.")
		end
	end,{})

end
return M
