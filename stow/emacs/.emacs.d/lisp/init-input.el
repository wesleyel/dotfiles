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

(defun my/rime--typst-display-math-delimiter-p (beg end)
  "Return non-nil when math between BEG and END is Typst display math.
Display math uses `$ ... $' with whitespace on both sides of the content."
  (and (> end (+ beg 2))
       (char-equal (char-after beg) ?$)
       (memq (char-after (1+ beg)) '(?\s ?\t))
       (> end (+ beg 3))
       (memq (char-before (1- end)) '(?\s ?\t))
       (char-equal (char-before end) ?$)))

(defun my/rime--typst-display-math-at-point-p ()
  "Return non-nil when point is inside Typst display math (`$ ... $')."
  (condition-case nil
      (when (and (derived-mode-p 'typst-ts-mode)
                 (featurep 'treesit)
                 (treesit-language-available-p 'typst t))
        (let ((node (treesit-node-at (point))))
          (when-let ((math (and node
                                (treesit-parent-until
                                 node
                                 (lambda (n)
                                   (string= (treesit-node-type n) "math"))))))
            (my/rime--typst-display-math-delimiter-p
             (treesit-node-start math)
             (treesit-node-end math)))))
    (error nil)))

(defun my/rime--typst-entering-display-math-p ()
  "Return non-nil when the current key finishes a display-math opener (`$ ')."
  (and rime--current-input-key
       (= rime--current-input-key ?\s)
       (char-equal (char-before) ?$)))

(defun my/rime--typst-code-at-point-p ()
  "Return non-nil when point is inside a Typst code fragment."
  (condition-case nil
      (and (derived-mode-p 'typst-ts-mode)
           (featurep 'treesit)
           (treesit-language-available-p 'typst t)
           (let ((node (treesit-node-at (point))))
             (and node
                  (treesit-parent-until
                   node
                   (lambda (n)
                     (string= (treesit-node-type n) "code"))))))
    (error nil)))

(defun my/rime--hash-triggered-on-line-p ()
  "Return non-nil when a `#' appears earlier on the current line."
  (let ((pos (point))
        (line-start (line-beginning-position)))
    (and (> pos line-start)
         (save-excursion
           (goto-char pos)
           (and (re-search-backward "#" line-start t)
                t)))))

(defconst my/rime--pair-alist
  '((?\( . ?\))
    (?\[ . ?\])
    (?\{ . ?\})
    (?\$ . ?\$))
  "Open characters that auto-insert a closing counterpart in ascii mode.")

(defun my/rime--pair-close (open)
  "Return the closing character paired with OPEN, or nil."
  (cdr (assoc open my/rime--pair-alist)))

(defun my/rime--should-pair-open-p (open)
  "Return non-nil when OPEN should trigger auto-pairing in ascii mode."
  (when-let ((close (my/rime--pair-close open)))
    (if (equal open ?\$)
        (and (not (my/rime--typst-display-math-at-point-p))
             (not (memq (char-before) '(?\s ?\t))))
      close)))

(defun my/rime--commit-pending-composition ()
  "Commit the current Rime composition, if any."
  (when (and (fboundp 'rime-lib-get-context)
             (fboundp 'rime--has-composition)
             (rime--has-composition (rime-lib-get-context)))
    (let ((context (rime-lib-get-context)))
      (if-let ((preview (alist-get 'commit-text-preview context)))
          (insert preview)
        (when (rime-lib-process-key 32 0)
          (when-let ((commit (rime-lib-get-commit)))
            (insert commit))))
      (when (fboundp 'rime--clear-state)
        (rime--clear-state)))))

(defun my/rime-input-method--around (orig key)
  "Handle `#' commit-to-ascii and ascii-mode bracket pairing."
  (setq rime--current-input-key key)
  (if (and (fboundp 'rime--rime-lib-module-ready-p)
           (rime--rime-lib-module-ready-p))
      (cond
       ((and (equal key ?#)
             (fboundp 'rime--text-read-only-p)
             (not (rime--text-read-only-p))
             (fboundp 'rime--should-enable-p)
             (rime--should-enable-p))
        (my/rime--commit-pending-composition)
        (insert ?#)
        nil)
       ((and (my/rime--should-pair-open-p key)
             (fboundp 'rime--should-enable-p)
             (not (rime--should-enable-p)))
        (insert key (my/rime--pair-close key))
        (backward-char 1)
        nil)
       (t
        (funcall orig key)))
    (list key)))

(defun my/rime-predicate-hash-ascii-p ()
  "Use ascii input after `#' in code or same-line comments."
  (or (my/rime--typst-code-at-point-p)
      (and (not (derived-mode-p 'typst-ts-mode))
           (my/rime--hash-triggered-on-line-p))))

(defun my/rime-predicate-typst-display-math-p ()
  "In typst-ts-mode, use ascii input only inside display math (`$ ... $').

Inline math (`$x$') and markup stay in Chinese.  Use `rime-force-enable'
(`C-c i r') to input Chinese once inside display math."
  (and (derived-mode-p 'typst-ts-mode)
       (or (my/rime--typst-display-math-at-point-p)
           (my/rime--typst-entering-display-math-p))))

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
     rime-predicate-punctuation-after-ascii-p
     my/rime-predicate-hash-ascii-p
     my/rime-predicate-typst-display-math-p))
  :config
  (advice-add 'rime-input-method :around #'my/rime-input-method--around)
  (advice-add 'rime-activate :before
              (lambda (&rest _)
                (my/rime-bootstrap-from-system))))

(provide 'init-input)

;;; init-input.el ends here
