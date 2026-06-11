;;; init-package.el --- Package setup -*- lexical-binding: t; -*-

(require 'package)
(require 'cl-lib)

(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa" . "https://melpa.org/packages/")))

(package-initialize)

(require 'use-package)
(setq use-package-always-ensure t)

(defvar my/required-packages
  '(vertico marginalia orderless consult helpful projectile which-key
    magit diff-hl
    rime vterm
    gptel
    tempel
    typst-ts-mode typst-preview)
  "Community packages needed by this configuration.")

(unless (cl-every #'package-installed-p my/required-packages)
  (package-refresh-contents)
  (dolist (package my/required-packages)
    (unless (package-installed-p package)
      (package-install package))))

(provide 'init-package)

;;; init-package.el ends here
