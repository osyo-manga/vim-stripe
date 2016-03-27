scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:R = vital#of('stripe').import("Random")

sign define stripe_dummy texthl=NONE

function! s:random_id()
	return abs(s:R.next())
endfunction

function! s:sign(id, name, line, bufnr)
	let id = a:id + a:line + a:bufnr
	execute "sign place " . id . " line=" . a:line . " name=" . a:name . " buffer=" . a:bufnr
	return id
endfunction

function! s:unsign(id, bufnr)
	execute "sign unplace " . a:id . " buffer=" . a:bufnr
endfunction


let s:striper = {}

function! s:striper.new(bufnr, ...)
	let obj = deepcopy(s:striper)
	let obj.bufnr = a:bufnr
	let obj.sign_id_list = []
	let obj.prev_changedtick = -1
	let obj.config = extend({
\		"group_odd" : "",
\		"group_even" : "",
\	}, get(a:, 1, {}))
	return obj
endfunction

function! s:striper.reset()
	if empty(self.sign_id_list)
		return
	endif
	call map(self.sign_id_list, "s:unsign(v:val, self.bufnr)")
	let self.sign_id_list = []
endfunction

function! s:striper.set(...)
	let force = get(a:, 1, 0)
	let changedtick = getbufvar(self.bufnr, "changedtick")
	if self.prev_changedtick == changedtick && force == 0
		return
	endif
	let self.prev_changedtick = changedtick

	let dummy_id = s:random_id()
	execute "sign place " . dummy_id . " line=1 name=stripe_dummy buffer=" . self.bufnr

	let old = deepcopy(self)
	let self.sign_id_list = []
	let line = line("$")

	let id = s:random_id()
	if self.config.group_odd !=# ""
		execute "sign define stripe_odd linehl=" . self.config.group_odd
		let self.sign_id_list += map(filter(range(1, line), "v:val % 2 != 0"), "s:sign(id, 'stripe_odd', v:val, self.bufnr)")
	endif

	if self.config.group_even !=# ""

		let self.sign_id_list += map(filter(range(1, line), "v:val % 2 == 0"), "s:sign(id, 'stripe_even', v:val, self.bufnr)")
	endif

	execute "sign unplace " . dummy_id
	call old.reset()
endfunction


let s:stripers = {}
function! stripe#get(...)
	let bufnr = get(a:, 1, bufnr("%"))
	if has_key(s:stripers, bufnr)
		return s:stripers[bufnr]
	endif
	let s:stripers[bufnr] = s:striper.new(bufnr, g:stripe_config)
	return s:stripers[bufnr]
endfunction

function! stripe#set(...)
	let bufnr = get(a:, 1, bufnr("%"))
	let force = get(a:, 2, 0)
	let striper = stripe#get(bufnr)
	call striper.set(force)
endfunction

function! stripe#reset(...)
	let bufnr = get(a:, 1, bufnr("%"))
	let striper = stripe#get(bufnr)
	call striper.reset()
endfunction

function! stripe#enable(...)
	let bufnr = get(a:, 1, bufnr("%"))
	call setbufvar(bufnr, "stripe_enable", 1)
	call stripe#set(bufnr, 1)
endfunction

function! stripe#disable(...)
	let bufnr = get(a:, 1, bufnr("%"))
	call setbufvar(bufnr, "stripe_enable", 0)
	call stripe#reset(bufnr)
endfunction

function! stripe#toggle(...)
	let bufnr = get(a:, 1, bufnr("%"))
	if getbufvar(bufnr, "stripe_enable")
		return stripe#disable()
	else
		return stripe#enable()
	endif
endfunction

let g:stripe#enable_auto_update = get(g:, "stripe#enable_auto_update", 1)
function! stripe#auto_update()
	if !exists("g:stripe_config")
		return
	endif

	if g:stripe#enable_auto_update && get(b:, "stripe_enable", 1) == 0
		return
	endif
	try
		
		let bufnr = get(a:, 1, bufnr("%"))
		call stripe#set(bufnr)
	catch
		echom "stripe.vim : " . v:exception . ":" . v:throwpoint
	endtry
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
