init.el --- Spacemacs Initialization File
;;
;; Copyright (c) 2012-2016 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;; Without this comment emacs25 adds (package-initialize) here
;; (package-initialize)

(setq gc-cons-threshold 100000000)
(defconst spacemacs-version         "0.105.20" "Spacemacs version.")
(defconst spacemacs-emacs-min-version   "24.3" "Minimal version of Emacs.")

(if (not (version<= spacemacs-emacs-min-version emacs-version))
    (message (concat "Your version of Emacs (%s) is too old. "
                     "Spacemacs requires Emacs version %d or above.")
             emacs-version spacemacs-emacs-min-version)
  (load-file (concat user-emacs-directory "core/core-load-paths.el"))
  (require 'core-spacemacs)
  (spacemacs/init)
  (spacemacs/maybe-install-dotfile)
  (configuration-layer/sync)
  (spacemacs/setup-startup-hook)
  (require 'server)
  (unless (server-running-p) (server-start)))


;; 显示行号
;;(global-linum-mode 1)


;; 快速打开配置文件
(defun open-init-file()
  (interactive)
  (find-file "~/.emacs.d/init.el"))

;; 这一行代码，将函数 open-init-file 绑定到 <f2> 键上
(global-set-key (kbd "<f2>") 'open-init-file)

;;;;;;;;;;;;python shell setting;;;;;;;;;;;;
;;set python shell-interpreter
(setq python-shell-interpreter "ipython"
      python-shell-interpreter-args "-i")
;;disable python warning info
(setq python-shell-prompt-detect-failure-warning nil)


;;;;;;;;;;;;chinese-pyim settting;;;;;;;;;;;;
;;install chinese-pyim
;;(require 'chinese-pyim)
;;(require 'chinese-pyim-basedict)
;;(chinese-pyim-basedict-enable)



;;;;;;;;;;;;;set Gnus;;;;;;;;;;;
;; Get email, and store in nnml
  (setq gnus-secondary-select-methods
        '(
          (nnimap "gmail"
                  (nnimap-address
                   "imap.gmail.com")
                  (nnimap-server-port 993)
                  (nnimap-stream ssl))
          ))

  ;; Send email via Gmail:
  (setq message-send-mail-function 'smtpmail-send-it
        smtpmail-default-smtp-server "smtp.gmail.com")

  ;; Archive outgoing email in Sent folder on imap.gmail.com:
  (setq gnus-message-archive-method '(nnimap "imap.gmail.com")
        gnus-message-archive-group "[Gmail]/Sent Mail")

  ;; set return email address based on incoming email address
  (setq gnus-posting-styles
        '(((header "to" "address@outlook.com")
           (address "address@outlook.com"))
          ((header "to" "address@gmail.com")
           (address "address@gmail.com"))))

  ;; store email in ~/gmail directory
  (setq nnml-directory "~/gmail")
  (setq message-directory "~/gmail")
;;;;;;;;;;;;;set Gnus;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;DIY org agenda;;;;;;;;;;;;;;;;;;;;;;;;;;
(global-set-key (kbd "<f8>") 'org-agenda-list)
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "<f7>") 'org-agenda)
(setq org-agenda-custom-commands
      '(("n" "My custom agenda"
         ((org-agenda-list nil nil 1)
          (tags "Study")
          (tags "Work")
          (tags-todo "-Maybe")
          ))))



;;;;;;;;;;;;neotree in emacs;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'neotree-mode-hook
          (lambda ()
            (define-key evil-normal-state-local-map (kbd "q") 'neotree-hide)))
            (require 'neotree)
            (define-key neotree-mode-map (kbd "O") #'neotree-enter-horizontal-split)
            (define-key neotree-mode-map (kbd "o") #'neotree-enter-vertical-split)
;;;;;;;;;;;;neotree in emacs;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;each access to other window;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(global-set-key (kbd "C-;") 'other-window)

;;;;;;;;;;;;;After this, lines will wrap;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;(setq org-startup-truncated nil)




;;;;;;;;;;;;;;;;;;;;;org-auto-clcok;;;;;;;;;;;;;;;;;;;;;;;;;;
(eval-after-load 'org
  '(progn
     (defun wicked/org-clock-in-if-starting ()
       "Clock in when the task is marked STARTED."
       (when (and (string= org-state "STARTED")
                  (not (string= org-last-state org-state)))
         (org-clock-in)))

     (add-hook 'org-after-todo-state-change-hook
               'wicked/org-clock-in-if-starting)

     (defadvice org-clock-in (after wicked activate)
       "Set this task's status to 'STARTED'."
       (org-todo "STARTED"))


     (defun wicked/org-clock-out-if-waiting ()
       "Clock out when the task is marked WAITING or PAUSED."
       (when (and (or (string= org-state "WAITING")
                      (string= org-state "PAUSED"))
                  (equal (marker-buffer org-clock-marker) (current-buffer))
                  (< (point) org-clock-marker)
                  (> (save-excursion (outline-next-heading) (point))
                     org-clock-marker)
                  (not (string= org-last-state org-state)))
         (org-clock-out)))

     (add-hook 'org-after-todo-state-change-hook
               'wicked/org-clock-out-if-waiting)))



;;;;;;;;;;;;;;;;;;;;;kill-other-buffer;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun kill-other-buffers()
  "Kill all other buffers."
  (interactive)
  (mapc 'kill-buffer
        (delq (current-buffer)
              (remove-if-not 'buffer-file-name (buffer-list)))))

(global-set-key (kbd "C-x C-b") 'ibuffer)
;; Ensure ibuffer opens with point at the current buffer's entry.
(defadvice ibuffer
    (around ibuffer-point-to-most-recent) ()
    "Open ibuffer with cursor pointed to most recent buffer name."
    (let ((recent-buffer-name (buffer-name)))
      ad-do-it
      (ibuffer-jump-to-buffer recent-buffer-name)))
(ad-activate 'ibuffer)



;;;;;;;;;;;;;;;;;;;;;kill-other-buffer;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun prelude-open-with ()
  "Simple function that allows us to open the underlying
file of a buffer in an external program."
  (interactive)
  (when buffer-file-name
    (shell-command (concat
                    (if (eq system-type 'darwin)
                        "open"
                      (read-shell-command "Open current file with: "))
                    " "
                    buffer-file-name))))


(global-set-key (kbd "C-c o") 'prelude-open-with)
