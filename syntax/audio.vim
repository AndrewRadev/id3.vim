syn match audioHeader '^File:'
syn match audioHeaderDelimiter '=\{5,}'

syn match audioTagLabel '^Title:'
syn match audioTagLabel '^Artist:'
syn match audioTagLabel '^Album:'
syn match audioTagLabel '^Track No:'
syn match audioTagLabel '^Year:'
syn match audioTagLabel '^Date:'
syn match audioTagLabel '^Genre:'
syn match audioTagLabel '^Comment:'
syn match audioTagLabel '^Description:'

hi link audioHeader          Identifier
hi link audioTagLabel        Identifier
hi link audioHeaderDelimiter Operator
