;;; init-typst.el --- Typst editing support -*- lexical-binding: t; -*-

(require 'projectile)

(defun my/typst-preview-setup-root ()
  "Make `typst-preview' use Projectile's current project root."
  (setq-local typst-preview-default-dir
              (file-truename (or (projectile-project-root)
                                 default-directory))))

(defcustom my/typst-preview-auto-sync t
  "Non-nil means sync the current Typst position to preview after cursor idle."
  :type 'boolean)

(defcustom my/typst-preview-auto-sync-delay 0.35
  "Idle seconds before syncing the current Typst position to preview."
  :type 'number)

(defvar-local my/typst-preview-auto-sync-timer nil
  "Idle timer used to sync the current Typst buffer to preview.")

(defun my/typst-preview-auto-sync-buffer (buffer)
  "Sync BUFFER's current position to typst-preview when possible."
  (when (buffer-live-p buffer)
    (with-current-buffer buffer
      (when (and my/typst-preview-auto-sync
                 (bound-and-true-p typst-preview-mode)
                 (fboundp 'typst-preview-connected-p)
                 (typst-preview-connected-p))
        (let ((inhibit-message t)
              (message-log-max nil))
          (ignore-errors
            (typst-preview-send-position)))))))

(defun my/typst-preview-schedule-auto-sync ()
  "Schedule preview position sync for the current Typst buffer."
  (when (and my/typst-preview-auto-sync
             (derived-mode-p 'typst-ts-mode)
             (bound-and-true-p typst-preview-mode))
    (when (timerp my/typst-preview-auto-sync-timer)
      (cancel-timer my/typst-preview-auto-sync-timer))
    (setq my/typst-preview-auto-sync-timer
          (run-with-idle-timer my/typst-preview-auto-sync-delay
                               nil
                               #'my/typst-preview-auto-sync-buffer
                               (current-buffer)))))

(use-package typst-ts-mode
  :mode "\\.typ\\'"
  :hook
  ((typst-ts-mode . my/typst-preview-setup-root)
   (typst-ts-mode . (lambda ()
                      (add-hook 'post-command-hook
                                #'my/typst-preview-schedule-auto-sync
                                nil
                                t)))
   (typst-ts-mode . eglot-ensure))
  :bind
  (:map typst-ts-mode-map
        ("C-c t d" . xref-find-definitions)
        ("C-c t r" . xref-find-references)
        ("C-c t i" . consult-imenu)
        ("C-c t p" . typst-preview-mode)
        ("C-c t s" . typst-preview-send-position)
        ("C-c t o" . typst-preview-open-browser)
        ("C-c t R" . typst-preview-restart)
        ("C-c t q" . typst-preview-stop))
  :config
  (with-eval-after-load 'eglot
    (cl-defmethod eglot-register-capability :around
      (server method id &rest params)
      (unless (equal method "workspace/didChangeConfiguration")
        (cl-call-next-method)))
    (add-to-list 'eglot-server-programs
                 `((typst-ts-mode)
                   . ,(eglot-alternatives
                       `((,typst-ts-lsp-download-path "lsp")
                         ("tinymist" "lsp")
                         "typst-lsp"))))))

(use-package typst-preview
  :custom
  (typst-preview-executable "tinymist")
  (typst-preview-browser "default")
  (typst-preview-invert-colors "auto")
  (typst-preview-open-browser-automatically t)
  (typst-preview-autostart t)
  (typst-preview-ask-if-pin-main nil)
  (typst-preview-default-dir "."))

(provide 'init-typst)

;;; init-typst.el ends here
