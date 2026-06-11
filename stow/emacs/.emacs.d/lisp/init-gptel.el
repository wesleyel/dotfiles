;;; init-gptel.el --- LLM chat configuration -*- lexical-binding: t; -*-

(use-package gptel
  :demand t
  :bind
  (("C-c g" . gptel-menu)
   ("C-c G" . gptel))
  :custom
  (gptel-default-mode 'org-mode)
  (gptel-prompt-prefix-alist
   '((org-mode . "#+begin_example\n")
     (markdown-mode . "```\n")
     (text-mode . "")))
  (gptel-response-prefix-alist
   '((org-mode . "#+end_example\n\n")
     (markdown-mode . "```\n\n")
     (text-mode . "\n\n")))
  :config
  (let ((deepseek (gptel-make-openai "DeepSeek"
                    :host "api.deepseek.com"
                    :endpoint "/chat/completions"
                    :stream t
                    :key #'gptel-api-key-from-auth-source
                    :models '(deepseek-v4-pro
                              deepseek-v4-flash)
                    :request-params
                    '(:thinking (:type "enabled")
                      :reasoning_effort "high"))))
    (setq gptel-model 'deepseek-v4-pro
          gptel-backend deepseek)))

(provide 'init-gptel)

;;; init-gptel.el ends here
