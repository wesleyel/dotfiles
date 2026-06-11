;;; init-input.el --- Input methods -*- lexical-binding: t; -*-

(defcustom my/rime-system-user-data-dir "~/Library/Rime/"
  "System Rime user data directory used by Squirrel."
  :type 'directory)


(defvar my/rime-bootstrap-done nil
  "Non-nil means Emacs Rime has copied system Rime bootstrap files.")

(defun my/rime-bootstrap-stamp-file ()
  "Return the path of the Emacs Rime bootstrap stamp file."
  (expand-file-name ".bootstrap-done" rime-user-data-dir))

(defun my/rime-copy-system-file (file-name)
  "Copy FILE-NAME from system Rime data to Emacs Rime data when it exists."
  (let ((source (expand-file-name file-name my/rime-system-user-data-dir))
        (target (expand-file-name file-name rime-user-data-dir)))
    (when (file-exists-p source)
      (make-directory (file-name-directory target) t)
      (copy-file source target t))))

(defun my/rime-runtime-file-p (file)
  "Return non-nil when FILE is Rime runtime state rather than source config."
  (or (member file '("." ".." ".DS_Store" "build" "user.yaml"))
      (string-suffix-p ".userdb" file)))

(defun my/rime-copy-system-data ()
  "Copy system Rime source config files into Emacs Rime data directory."
  (let ((source-dir (file-name-as-directory
                     (expand-file-name my/rime-system-user-data-dir)))
        (target-dir (file-name-as-directory
                     (expand-file-name rime-user-data-dir))))
    (when (file-directory-p source-dir)
      (make-directory target-dir t)
      (dolist (file (directory-files source-dir))
        (unless (my/rime-runtime-file-p file)
          (let ((source (expand-file-name file source-dir))
                (target (expand-file-name file target-dir)))
            (cond
             ((file-directory-p source)
              (when (file-exists-p target)
                (delete-directory target t))
              (copy-directory source target t t t))
             ((file-regular-p source)
              (copy-file source target t)))))))))


(defun my/rime-bootstrap-from-system ()
  "Prepare Emacs Rime data from Squirrel data before first activation."
  (unless (or my/rime-bootstrap-done
              (file-exists-p (my/rime-bootstrap-stamp-file)))
    (make-directory (expand-file-name rime-user-data-dir) t)
    (my/rime-copy-system-file "installation.yaml")
    (if (file-exists-p (expand-file-name "default.custom.yaml"
                                          my/rime-system-user-data-dir))
        (my/rime-copy-system-file "default.custom.yaml")
      (my/rime-copy-system-file "default.yaml"))
    (my/rime-copy-system-data)
    (with-temp-file (my/rime-bootstrap-stamp-file)
      (insert (current-time-string) "\n"))
    (setq my/rime-bootstrap-done t)))

(defun my/rime-sync ()
  "Sync Rime user data (bidirectional merge with backup)."
  (interactive)
  (rime-sync))

(defun my/rime-deploy-and-sync ()
  "Deploy Rime then sync user data after a short delay."
  (interactive)
  (rime-deploy)
  (message "Rime deploying; sync will run once deploy completes...")
  (run-at-time 5 nil #'rime-sync))

(defun my/rime-bootstrap-from-system-force ()
  "Force a fresh Emacs Rime bootstrap from Squirrel data."
  (interactive)
  (let ((stamp (my/rime-bootstrap-stamp-file))
        (my/rime-bootstrap-done nil))
    (when (file-exists-p stamp)
      (delete-file stamp))
    (my/rime-bootstrap-from-system)
    (message "Emacs Rime bootstrap refreshed.")))

(use-package rime
  :demand t
  :bind
  (("C-c i i" . toggle-input-method)
   ("C-c i r" . rime-force-enable)
   ("C-c i s" . rime-select-schema)
   ("C-c i d" . my/rime-deploy-and-sync)
   ("C-c i y" . my/rime-sync)
   ("C-c i o" . rime-open-configuration)
   ("C-c i b" . my/rime-bootstrap-from-system-force))
  :custom
  (default-input-method "rime")
  (rime-librime-root "/opt/homebrew")
  (rime-user-data-dir (expand-file-name "rime/" user-emacs-directory))
  (rime-share-data-dir "/Library/Input Methods/Squirrel.app/Contents/SharedSupport")
  (rime-show-candidate 'posframe)
  (rime-posframe-style 'vertical)
  (rime-disable-predicates
   '(rime-predicate-current-uppercase-letter-p
     rime-predicate-punctuation-after-ascii-p))
  :config
  (advice-add 'rime-activate :before
              (lambda (&rest _)
                (my/rime-bootstrap-from-system))))

(provide 'init-input)

;;; init-input.el ends here
