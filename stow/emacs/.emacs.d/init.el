;;; init.el --- Fresh Emacs configuration -*- lexical-binding: t; -*-

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

(require 'init-core)
(require 'init-package)
(require 'init-completion)
(require 'init-input)
(require 'init-vterm)
(require 'init-org)
(require 'init-project)
(require 'init-git)
(require 'init-gptel)
(require 'init-typst)
(require 'init-help)
(require 'init-discovery)

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;;; init.el ends here
