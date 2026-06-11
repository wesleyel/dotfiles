;;; init-project.el --- Project management -*- lexical-binding: t; -*-

(use-package projectile
  :custom
  (projectile-completion-system 'default)
  (projectile-project-search-path '("~/Documents" "~/codes" "~/work"))
  (projectile-switch-project-action #'projectile-dired)
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (projectile-mode 1))

(provide 'init-project)

;;; init-project.el ends here
