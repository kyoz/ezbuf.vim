command! -nargs=? -complete=buffer -bang BClose
  \ :call CloseBuffer('<args>', '<bang>')
command! -nargs=? -complete=buffer -bang BCloseOther
  \ :call CloseOtherBuffers('<args>', '<bang>')
command! -nargs=? -complete=buffer -bang BCloseAll
  \ :call CloseAllBuffers('<bang>')
command! -nargs=? -complete=buffer -bang BCloseSaved
  \ :call CloseSavedBuffers('<bang>')

"------------------------------------------------------------------------------

nnoremap <leader>bx :BClose<CR>
nnoremap <leader>bX :BCloseAll<CR>
nnoremap <leader>bo :BCloseOther<CR>
nnoremap <leader>bs :BCloseSaved<CR>

"------------------------------------------------------------------------------

func! CloseBuffer(buffer, bang)
	if a:buffer == ''
		" No buffer provided, use the current buffer.
		let buffer = bufnr('%')
	elseif (a:buffer + 0) > 0
		" A buffer number was provided.
		let buffer = bufnr(a:buffer + 0)
	else
		" A buffer name was provided.
		let buffer = bufnr(a:buffer)
	endif

	if buffer == -1
		echohl ErrorMsg
		echomsg "No matching buffer for" buffer
		echohl None
		return
	endif

	let delete_count = 0

  if buffer && buflisted(buffer)
    if a:bang == '' && getbufvar(buffer, '&modified')
      echohl ErrorMsg
      echomsg "No write since last change for buffer"
             \ buffer "(add ! to override)"
      echohl None
    else
      " Change buffer before delete current buffer
      silent exe 'bprevious'
      silent exe 'bdel' . a:bang . ' ' . buffer
      if ! buflisted(buffer)
        let delete_count = delete_count+1
      endif
    endif
  endif

	if delete_count >= 1
		echomsg "Buffer" buffer "deleted"
	else
		echomsg "Can't delete buffers"
	endif
endfunc

"------------------------------------------------------------------------------

" Without any arguments the current buffer is kept.  With an argument the
" buffer name/number supplied is kept.
func! CloseOtherBuffers(buffer, bang)
	if a:buffer == ''
		" No buffer provided, use the current buffer.
		let buffer = bufnr('%')
	elseif (a:buffer + 0) > 0
		" A buffer number was provided.
		let buffer = bufnr(a:buffer + 0)
	else
		" A buffer name was provided.
		let buffer = bufnr(a:buffer)
	endif

	if buffer == -1
		echohl ErrorMsg
		echomsg "No matching buffer for" a:buffer
		echohl None
		return
  else
    " If buffer is provided, jump to that buffer before delete others
    silent exe 'buffer' buffer
	endif

	let last_buffer = bufnr('$')

	let delete_count = 0
	let n = 1
	while n <= last_buffer
		if n != buffer && buflisted(n)
			if a:bang == '' && getbufvar(n, '&modified')
				echohl ErrorMsg
				echomsg "No write since last change for buffer"
							\ n "(add ! to override)"
				echohl None
			else
				silent exe 'bdel' . a:bang . ' ' . n
				if ! buflisted(n)
					let delete_count = delete_count+1
				endif
			endif
		endif
		let n = n+1
	endwhile

	if delete_count == 1
		echomsg delete_count "buffer deleted"
	elseif delete_count > 1
		echomsg delete_count "buffers deleted"
	endif
endfunc

"------------------------------------------------------------------------------

func! CloseAllBuffers(bang)
	let last_buffer = bufnr('$')

	let delete_count = 0
	let n = 1
	while n <= last_buffer
		if buflisted(n)
			if a:bang == '' && getbufvar(n, '&modified')
				echohl ErrorMsg
				echomsg 'No write since last change for buffer'
							\ n '(add ! to override)'
				echohl None
			else
				silent exe 'bdel' . a:bang . ' ' . n
				if ! buflisted(n)
					let delete_count = delete_count+1
				endif
			endif
		endif
		let n = n+1
	endwhile

	if delete_count == 1
		echomsg delete_count "buffer deleted"
	elseif delete_count > 1
		echomsg delete_count "buffers deleted"
	endif
endfunc

"------------------------------------------------------------------------------

func! CloseSavedBuffers(bang)
	let last_buffer = bufnr('$')

	let delete_count = 0
	let n = 1
	while n <= last_buffer
		if buflisted(n)
			if ! (a:bang == '' && getbufvar(n, '&modified'))
				silent exe 'bdel' . a:bang . ' ' . n
				if ! buflisted(n)
					let delete_count = delete_count+1
				endif
			endif
		endif
		let n = n+1
	endwhile

	if delete_count == 1
		echomsg delete_count "buffer deleted"
	elseif delete_count > 1
		echomsg delete_count "buffers deleted"
	endif
endfunc

