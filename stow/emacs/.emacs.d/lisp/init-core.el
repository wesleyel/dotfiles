;;; init-core.el --- Core editor defaults -*- lexical-binding: t; -*-

(setq inhibit-startup-screen t)
(setq ring-bell-function #'ignore)
(tool-bar-mode -1)

(setq desktop-auto-save-timeout 300
      desktop-restore-frames t
      desktop-restore-forces-onscreen nil
      desktop-restore-reuses-frames t)
(desktop-save-mode 1)

(defvar my/default-font-candidates
  '("Maple Mono NF CN")
  "Preferred font family names, in lookup order.")

(defun my/available-font-family ()
  "Return the first available font from `my/default-font-candidates'."
  (catch 'font
    (dolist (family my/default-font-candidates)
      (when (find-font (font-spec :family family))
        (throw 'font family)))))

(defun my/apply-default-font (&optional frame)
  "Apply the preferred default font to FRAME."
  (when (display-graphic-p frame)
    (when-let ((family (my/available-font-family)))
      (set-face-attribute 'default frame :family family)
      (set-face-attribute 'fixed-pitch frame :family family)
      (set-fontset-font t 'han (font-spec :family family) frame 'prepend))))

(add-hook 'after-make-frame-functions #'my/apply-default-font)
(add-hook 'emacs-startup-hook #'my/apply-default-font)

(when (eq system-type 'darwin)
  (let ((homebrew-bin "/opt/homebrew/bin"))
    (when (file-directory-p homebrew-bin)
      (add-to-list 'exec-path homebrew-bin)
      (setenv "PATH" (concat homebrew-bin path-separator (getenv "PATH")))))
  (global-set-key (kbd "s-c") #'kill-ring-save)
  (global-set-key (kbd "s-v") #'yank)
  (global-set-key (kbd "s-z") #'undo))

(provide 'init-core)

;;; init-core.el ends here
