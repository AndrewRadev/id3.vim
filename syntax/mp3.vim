syn match mp3Header '^File:'
syn match mp3HeaderDelimiter '=\{5,}'

syn match mp3TagLabel '^Title:'
syn match mp3TagLabel '^Artist:'
syn match mp3TagLabel '^Album:'
syn match mp3TagLabel '^Track No:'
syn match mp3TagLabel '^Year:'
syn match mp3TagLabel '^Genre:'
syn match mp3TagLabel '^Comment:'

hi link mp3Header          Identifier
hi link mp3TagLabel        Identifier
hi link mp3HeaderDelimiter Operator
