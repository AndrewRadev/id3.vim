syn match audioHeader '^File:'
syn match audioHorizontalDelimiter '=\{5,}'

syn match audioTagLabel '^Title:'
syn match audioTagLabel '^Artist:'
syn match audioTagLabel '^Album:'
syn match audioTagLabel '^Track No:'
syn match audioTagLabel '^Year:'
syn match audioTagLabel '^Date:'
syn match audioTagLabel '^Genre:'
syn match audioTagLabel '^Comment:'
syn match audioTagLabel '^Description:'
syn match audioTagLabel '^Version:'

hi link audioHeader              Identifier
hi link audioTagLabel            Identifier
hi link audioTagMetadata         Comment
hi link audioHorizontalDelimiter Operator
