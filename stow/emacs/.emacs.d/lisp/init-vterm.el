;;; init-vterm.el --- VTerm configuration -*- lexical-binding: t; -*-

(use-package vterm
  :demand t
  :custom
  (vterm-shell (executable-find "fish"))
  (vterm-max-scrollback 10000)
  (vterm-kill-buffer-on-exit t)
  (vterm-buffer-name-string "vterm[%s]")
  :bind
  (:map vterm-mode-map
        ("C-c C-c" . vterm-send-C-c)
        ("C-c C-u" . vterm-clear-scrollback)
        ("s-v" . vterm-yank))
  :init
  (setq vterm-always-compile-module t)
  :config
  (when (eq system-type 'darwin)
    (setq vterm-tramp-shells
          `(("fish" ,(executable-find "fish"))))))

(provide 'init-vterm)

;;; init-vterm.el ends here
