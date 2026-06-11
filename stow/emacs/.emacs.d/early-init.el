;;; early-init.el --- Early startup settings -*- lexical-binding: t; -*-

;; Keep startup predictable while the new configuration is being built.
(setq package-enable-at-startup nil)

;; On macOS, make Option behave as Emacs Meta instead of inserting symbols like ≈.
(when (eq system-type 'darwin)
  (setq mac-option-modifier 'meta
        ns-option-modifier 'meta
        mac-command-modifier 'super
        ns-command-modifier 'super))

;;; early-init.el ends here
