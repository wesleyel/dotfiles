;;; init-git.el --- Git integration -*- lexical-binding: t; -*-

(use-package magit
  :bind
  (("C-x g" . magit-status)
   ("C-c g s" . magit-status)
   ("C-c g b" . magit-blame-addition)
   ("C-c g l" . magit-log-buffer-file)
   ("C-c g f" . magit-file-dispatch)))

(use-package diff-hl
  :hook
  ((prog-mode . diff-hl-mode)
   (text-mode . diff-hl-mode)
   (dired-mode . diff-hl-dired-mode))
  :config
  (diff-hl-flydiff-mode 1)
  (add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh))

(provide 'init-git)

;;; init-git.el ends here
