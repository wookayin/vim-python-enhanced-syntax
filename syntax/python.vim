" python.vim
" ==========
"   an additional enhanced syntax for python
"   author: Jongwook Choi (@wookayin)

" Status
" ------
" Currently, it works an additional syntax on top of 'python-mode'.
" Later, it will be a independent and self-reliant syntax support.


" =======================================
" General : Python String {{{
" =======================================

" python docstring : treat as special, not String
hi! def link  pythonDocstring    SpecialComment

" Override pythonString primitive so that it has 'extend' property.
" without this, pythonCall (e.g. foo("aa,)") will not be matched properly
" (brought from python-mode/syntax/python.vim)
syn region pythonString     start=+[bB]\='+ skip=+\\\\\|\\'\|\\$+ excludenl end=+'+ end=+$+ keepend extend contains=pythonEscape,pythonEscapeError,@Spell
syn region pythonString     start=+[bB]\="+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end=+$+ keepend extend contains=pythonEscape,pythonEscapeError,@Spell
syn region pythonString     start=+[bB]\="""+ end=+"""+ keepend extend contains=pythonEscape,pythonEscapeError,pythonDocTest2,pythonSpaceError,@Spell
syn region pythonString     start=+[bB]\='''+ end=+'''+ keepend extend contains=pythonEscape,pythonEscapeError,pythonDocTest,pythonSpaceError,@Spell

" }}}
" =======================================
" Python Function & Method Definition {{{
" =======================================

" Use brighter color for method/function definition
hi pythonFunction       ctermfg=191     guifg=#d7ff5f
hi pythonParam          ctermfg=229     guifg=#ffffaf

" python function definition (parameters)
syn keyword     pythonStatement         def nextgroup=pythonFunction skipwhite
syn match       pythonFunction          "\%(\%(def\s\|@\)\s*\)\@<=\h\%(\w\|\.\)*" contained nextgroup=pythonVars
syn region      pythonVars              start="(" skip=+\(".*"\|'.*'\)+ end=")" contained contains=pythonParameters transparent keepend
syn match       pythonParameters        "[^,]*" contained contains=pythonParam skipwhite
syn match       pythonParam             "[^,]*" contained contains=pythonOperator,pythonExtraOperator,pythonLambdaExpr,pythonRepeat,pythonConditional,
                                                                  \pythonBuiltinObj,pythonBuiltinType,pythonBuiltinFunc,pythonConstant,
                                                                  \pythonString,pythonNumber,pythonBrackets,pythonSelf,pythonComment,pythonCall
                                                                  \skipwhite
syn match       pythonBrackets          "{[(|)]}" contained skipwhite

" }}}
" ====================================
" Python function call (arguments) {{{
" ====================================

function! s:convert_syntax_keyword_containedin(syntaxGroup, syntaxCallGroup)
    " requires 'execute()' function (vim 7.4.2008+ or neovim)
    if !exists('*execute')
        return
    endif

    " https://vi.stackexchange.com/questions/18408/ (courtesy of @user938271)
    let l:rule = execute(printf('syn list %s', a:syntaxGroup))
    let l:rule = matchstr(l:rule, 'xxx\zs.*')
    " if <xxx match> then, it is not 'syntax keyword' anymore. we should stop here
    if (l:rule =~ '^\s*match')
        return
    endif

    " convert it to regex rule
    let l:rule = substitute(l:rule, 'links\s\+to\s\+.*', '', '')
    let l:rule = join(split(l:rule), '\|')

    exe 'syn clear ' . a:syntaxGroup
    exe 'syn match ' . a:syntaxGroup     . ' /\C\<\%(' . l:rule . '\)\>/'
    exe 'syn match ' . a:syntaxCallGroup . ' /\C\<\%(' . l:rule . '\)\>/ contained'
endfunction

" function call: identifier \h\i*, followed by whitespaces and '('
" should handle Builtin{Type,Func} as well.
call s:convert_syntax_keyword_containedin('pythonBuiltinType', 'pythonCallBuiltinType')
call s:convert_syntax_keyword_containedin('pythonBuiltinFunc', 'pythonCallBuiltinFunc')

syn match       pythonCall              /\<\h\i*\ze\s*(/    contains=pythonCallBuiltinType,pythonCallBuiltinFunc
                                                            \ nextgroup=pythonCallRegion skipwhite keepend
hi link         pythonCallBuiltinType   pythonCall
hi link         pythonCallBuiltinFunc   pythonCall


" then, match parenthesis. inside it, we contain comma-separated python expressions.
syn region      pythonCallRegion        contained matchgroup=pythonParamsDelim start=/(/  end=/)/ keepend extend
                                        \ contains=pythonCallComma,pythonCall,@pythonCallArgument,pythonCallArgKeyword
hi! def link    pythonParamsDelim       Delimiter
hi              pythonParamsDelim       ctermfg=148     guifg=#afd700

syn match       pythonCallComma         contained /,/ display nextgroup=pythonCommaError skipwhite skipnl skipempty
hi! def link    pythonCallComma         pythonParamsDelim
syn match       pythonCommaError        contained /,/ extend display
hi! link        pythonCommaError        Error

syn cluster     pythonCallArgument      contains=pythonComment,pythonCall,pythonCallRegion,
                                                  \pythonOperator,pythonExtraOperator,pythonLambdaExpr,pythonRepeat,pythonConditional,
                                                  \pythonBuiltinObj,pythonBuiltinType,pythonBultinFunc,pythonConstant,pythonFloat,
                                                  \pythonString,pythonNumber,pythonBrackets,pythonSelf,pythonDocstring,
                                                  \skipwhite

" Highlight keyword argument in python function call
syn match       pythonCallArgKeyword    contained /\h\i*\ze\s*==\@!/
hi! def link    pythonCallArgKeyword    Special
hi              pythonCallArgKeyword    ctermfg=179     guifg=#dfaf5f
" }}}


" vim: foldmethod=marker
