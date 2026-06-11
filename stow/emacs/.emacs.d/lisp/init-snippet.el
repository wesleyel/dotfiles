;;; init-snippet.el --- Snippet & template support -*- lexical-binding: t; -*-

(use-package tempel
  :bind (("M-+" . tempel-complete)
         ("M-=" . tempel-insert))
  :init
  (defun my/tempel-setup-capf ()
    "Add Tempel Capf; `tempel-expand' is tried before other Capfs."
    (setq-local completion-at-point-functions
                (cons #'tempel-expand completion-at-point-functions)))

  :config
  (setq tempel-path (expand-file-name "templates/*.eld" user-emacs-directory))

  (defun my/tempel-typst-tab ()
    "Try `tempel-expand', falling back to `indent-for-tab-command'."
    (interactive)
    (if (tempel-expand)
        t
      (call-interactively #'indent-for-tab-command)))

  (defun my/tempel-typst-setup ()
    "Setup tempel for typst-ts-mode buffers."
    (my/tempel-setup-capf)
    (local-set-key (kbd "TAB") #'my/tempel-typst-tab))

  (add-hook 'typst-ts-mode-hook #'my/tempel-typst-setup)
  (add-hook 'typst-ts-mode-hook #'tempel-abbrev-mode))

;;; Hypersnips auto-expansion for typst (triggers that are not valid template names)

(defun my/typst--replace-back (len text)
  "Replace LEN chars before point with TEXT."
  (goto-char (- (point) len))
  (delete-char len)
  (insert text))

(defun my/typst-auto-expand ()
  "Auto-expand Hypersnips-style math shorthands and subscripts in typst."
  (when (derived-mode-p 'typst-ts-mode)
    (let ((case-fold-search nil))
      ;; ;; → \;    ,, → \,    ``` → space
      (cond
       ((looking-back ";;" 2)
        (my/typst--replace-back 2 "\\;"))
       ((looking-back ",," 2)
        (my/typst--replace-back 2 "\\,"))
       ((looking-back "```" 3)
        (my/typst--replace-back 3 " space")))
      ;; letter_XX → letter_(XX)  (multi-digit subscript)
      (when (search-backward "_" (max (point-min) (- (point) 5)) t)
        (let ((pos (point)))
          (when (looking-at "_\\([0-9]\\{2,\\}\\)")
            (let ((num (match-string 1))
                  (beg (1- (point)))
                  (end (match-end 0)))
              (goto-char pos)
              (delete-region beg end)
              (insert "_(" num ")")))))
      (goto-char (point-max))
      ;; letter + digit → letter_digit
      (when (and (>= (point) 2)
                 (looking-back "[A-Za-z)][0-9]" 2))
        (let ((letter (buffer-substring (- (point) 2) (1- (point))))
              (digit (buffer-substring (1- (point)) (point))))
          (unless (save-excursion
                    (goto-char (- (point) 3))
                    (looking-at "_"))
            (my/typst--replace-back 2 (concat letter "_" digit)))))
      ;; letter + same letter → letter_letter  (excluding i, l, o)
      (when (and (>= (point) 2)
                 (looking-back "\\([A-Za-hj-kmnp-z]\\)\\1" 2))
        (unless (save-excursion
                  (goto-char (- (point) 3))
                  (looking-at "_\\|^[A-Za-z]"))
          (let ((char (match-string 1)))
            (my/typst--replace-back 2 (concat char "_" char))))))))

(add-hook 'typst-ts-mode-hook
          (lambda ()
            (add-hook 'post-self-insert-hook #'my/typst-auto-expand nil t)))

(provide 'init-snippet)
;;; init-snippet.el ends here
