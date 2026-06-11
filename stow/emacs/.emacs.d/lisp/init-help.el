;;; init-help.el --- Help buffers and lookup -*- lexical-binding: t; -*-

(use-package helpful
  :bind
  (("C-h f" . helpful-callable)
   ("C-h v" . helpful-variable)
   ("C-h k" . helpful-key)
   ("C-h x" . helpful-command)))

(provide 'init-help)

;;; init-help.el ends here
