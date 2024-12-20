-- TODO: startup profiling
return {
	{
		enabled = false,
		-- enabled = os.getenv('NVIM_PROFILE') ~= nil,
		'folke/snacks.nvim',
		lazy = false,
		priority = 1000,
		opts = function()
			local Snacks = require('snacks')
			-- Toggle the profiler
			Snacks.toggle.profiler():map('<f1>')
			-- Toggle the profiler highlights
			Snacks.toggle.profiler_highlights():map('<f2>')

			return {
				profiler = {
					filter_mod = {
						default = false,
						['^blink.cmp%.'] = true,
						['^blink.cmp.completion.windows.render%.'] = false,
						['blink.cmp.sources.snippets.registry'] = false,
						-- ['^luasnip%.'] = true,
						-- ['^rainbow-delimiters%.'] = true,
					},
				},
			}
		end,
	},
	{
		enabled = os.getenv('NVIM_PROFILE') ~= nil,
		'stevearc/profile.nvim',
		config = function()
			local should_profile = os.getenv('NVIM_PROFILE')
			if should_profile then
				local profile = require('profile')
				profile.instrument_autocmds()
				local range = os.getenv('NVIM_PROFILE')
				if range == '1' or range == 'start' then
					range = '*'
				end

				profile.ignore('vim.tbl_*')
				profile.ignore('vim.shared.*')
				profile.ignore('vim._editor.*')
				profile.ignore('blink.cmp.windows.lib.render.*')
				profile.ignore('blink.cmp.windows.render_item*')
				profile.instrument(range)
				if should_profile:lower():match('^start') then
					profile.start(range)
				end
			end

			local function toggle_profile()
				if not should_profile then
					vim.notify('Set NVIM_PROFILE to enable profiling', 'warn')
					return
				end
				local prof = require('profile')
				if prof.is_recording() then
					prof.stop()
					vim.ui.input(
						{ prompt = 'Save profile to:', completion = 'file', default = 'profile.json' },
						function(filename)
							if filename then
								prof.export(filename)
								vim.notify(string.format('Wrote %s', filename))
							end
						end
					)
				else
					prof.start('*')
				end
			end
			vim.keymap.set('', '<f1>', toggle_profile)
		end,
	},
}
