;;; init-org.el --- Org notes and capture -*- lexical-binding: t; -*-

(defvar my/org-directory (expand-file-name "notes" user-emacs-directory)
  "Directory for personal Org notes.")

(defvar my/emacs-notes-file (expand-file-name "emacs.org" my/org-directory)
  "Org file for Emacs notes.")

(defun my/org-capture-emacs-note ()
  "Capture a quick note into the Emacs notes file."
  (interactive)
  (require 'org-capture)
  (org-capture nil "e"))

(use-package org
  :ensure nil
  :bind
  (("C-c n e" . my/org-capture-emacs-note)
   ("C-c n c" . org-capture)
   ("C-c n a" . org-agenda))
  :config
  (add-hook 'emacs-startup-hook
            (lambda ()
              (find-file my/emacs-notes-file)))
  (setq org-directory my/org-directory
        org-default-notes-file (expand-file-name "inbox.org" org-directory)
        org-agenda-files (list org-directory)
        org-capture-templates
        `(("e" "Emacs note" entry
           (file+headline ,my/emacs-notes-file "Notes")
           "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n"
           :empty-lines 1)
          ("t" "Task" entry
           (file+headline ,org-default-notes-file "Tasks")
           "* TODO %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n"
           :empty-lines 1))))

(provide 'init-org)

;;; init-org.el ends here
