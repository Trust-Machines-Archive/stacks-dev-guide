(define-read-only (greet (name (string-ascii 20)))
  (concat (concat "Hello, " name) "!")
)
