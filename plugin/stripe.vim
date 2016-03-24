scriptencoding utf-8
if exists('g:loaded_stripe')
  finish
endif
let g:loaded_stripe = 1

let s:save_cpo = &cpo
set cpo&vim

command! StripeEnable call stripe#enable(bufnr("%"))
command! StripeDisable call stripe#disable(bufnr("%"))
command! StripeToggle call stripe#toggle(bufnr("%"))

augroup striper-auto-update
	autocmd!
	autocmd BufEnter,CursorHold * call stripe#auto_update()
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
