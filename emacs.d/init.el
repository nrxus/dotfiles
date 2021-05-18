;; ------------------------------- ui changes -------------------------------
;; remove ui elements
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

;; always show line numbers
(line-number-mode t)

;; allows full height on any font
(setq frame-resize-pixelwise t)

;; no more tutorial
(setq inhibit-startup-message t)
(global-unset-key (kbd "<menu>"))

;; ----------------------------- editor tweaks -----------------------------
;; newline at the end by default
(setq-default require-final-newline t)

;; prevent extraneous tabs
(setq-default indent-tabs-mode nil)

;; delete whitespace just when a file is saved.
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; update buffer if files changed in disk
(global-auto-revert-mode t)

;; force revert
(defun revert-buffer-no-confirm ()
  "Revert buffer without confirmation."
  (interactive) (revert-buffer t t))

(global-set-key (kbd "s-u") 'revert-buffer-no-confirm)

;; ------------------------------ x clipboard ------------------------------
;; put x clipboard into the kill ring before replacing it
(setq-default save-interprogram-paste-before-kill t)

;; replace when pasting
(delete-selection-mode)

;; --------------------------------- other tweaks --------------------------------
;; Do not put 'customize' config in init.el; give it another file.
(setq custom-file "~/.emacs.d/custom-file.el")

;; put backups somewhere else
(setq backup-directory-alist `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))

;; save recent files
(recentf-mode 1)
(setq recentf-max-menu-items 25)
(setq recentf-max-saved-items 25)

;; handle buffers of filenames with the same name
(setq uniquify-buffer-name-style 'forward)

;; better buffer
(global-set-key (kbd "C-x C-b") 'ibuffer)

(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
(defun colorize-compilation-buffer ()
  (ansi-color-apply-on-region compilation-filter-start (point-max)))
(add-hook 'compilation-filter-hook 'colorize-compilation-buffer)

;; enable hide-show when programming
(add-hook 'prog-mode-hook 'hs-minor-mode)

;; kill buffer other in other window
(defun kill-other-buffer ()
  "Kill the buffer in the other window."
  (interactive)
  (kill-buffer (window-buffer (other-window 1)))
  (other-window 1))

(define-key ctl-x-4-map (kbd "k") 'kill-other-buffer)

(eval-after-load "conf-mode"
  '(progn (define-key conf-toml-mode-map (kbd "C-c C-p") nil)))

;; --------------------------- preparing packages ---------------------------
;; prepare MELPA package
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(package-initialize)

;; use package
(eval-when-compile
  (require 'use-package))

(require 'use-package-ensure)
(setq use-package-always-ensure t)

;; ------------------------------- generic packages --------------------------
;; theme
(use-package base16-theme
  :config (load-theme 'base16-atelier-plateau t))

;; hide minor modes
(use-package diminish)

;; allows me to create mini modes
(use-package hydra)

;; bind two quick subsequent presses to a function
(use-package key-chord
  :config (key-chord-mode 1))

;; window switching
(use-package ace-window
  :bind ("M-o" . ace-window))

;; git
(use-package magit
  :bind ("C-x g" . magit-status))

(setq-default mode-line-format (delete '(vc-mode vc-mode) mode-line-format))

;; diff in the fringe
(use-package diff-hl)
(global-diff-hl-mode)
(add-hook 'dired-mode-hook 'diff-hl-dired-mode)
(add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
(add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)

;; go back and forth in commits
(use-package git-timemachine)

;; search
(use-package ivy
  :config
  (ivy-mode)
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  (global-set-key (kbd "C-c C-r") 'ivy-resume)
  :diminish)

(use-package counsel
  :config
  (counsel-mode)
  (setq ivy-initial-inputs-alist nil)
  :bind ("C-c s")
  :diminish)

(use-package swiper
  :bind ("C-s" . swiper-isearch))

(use-package smex)

;; project
(use-package projectile
  :init
  (setq projectile-completion-system 'ivy)
  :config
  (projectile-global-mode t)
  ;; :config (define-key projectile-mode-map (kbd "C-c C-p") 'projectile-command-map)
  :diminish nil)

(use-package counsel-projectile
  :config (counsel-projectile-mode))

(defun projectile-test-project (arg)
  "Run project test command.

Normally you'll be prompted for a compilation command, unless
variable `compilation-read-command'.  You can force the prompt
with a prefix ARG."
  (interactive "P")
  (let ((command (projectile-test-command (projectile-compilation-dir))))
    (projectile--run-project-cmd command projectile-test-cmd-map
                                 :show-prompt arg
                                 :prompt-prefix "Test command: "
                                 :save-buffers t)))

(defun projectile-test-file ()
  "Runs the projectile test command for the file in the current window"
  (interactive)
  (let ((command (projectile-test-command (projectile-compilation-dir)))
        (file (file-relative-name buffer-file-name (projectile-project-root))))
    (projectile-run-compilation (concat command " " file))))

(defhydra hydra-projectile (:color teal
                                   :hint nil)
  "
     PROJECTILE: %(projectile-project-root)

^ ^        Open            ^ ^   Run      ^ ^ Other Projects
^-----^--------------------^-^--------------------------------
_<SPC>_: within project   _T_: test file      _p_: switch
    _g_: file at point   _sr_: search         _F_: find anywhere
    _b_: buffer           _c_: compile
    _d_: directory        _P_: test project
    _t_: test/impl

"
  ("<SPC>" counsel-projectile)
  ("F"     projectile-find-file-in-known-projects)
  ("P"     projectile-test-project)
  ("T"     projectile-test-file)
  ("b"     counsel-projectile-switch-to-buffer)
  ("c"     projectile-compile-project)
  ("d"     counsel-projectile-find-dir)
  ("g"     counsel-projectile-find-file-dwim)
  ("i"     projectile-invalidate-cache "invalidate cache")
  ("p"     counsel-projectile-switch-project)
  ("sr"    counsel-projectile-rg)
  ("t"     projectile-toggle-between-implementation-and-test)
  ("q"     nil "cancel" :color blue))

(global-set-key (kbd "C-c C-p") #'hydra-projectile/body)

;; parens
(use-package smartparens
  :hook ((prog-mode . turn-on-smartparens-mode))
  :hook ((conf-mode . turn-on-smartparens-mode))
  :config
  (require 'smartparens-config)
  (progn (show-smartparens-global-mode t))
  :diminish smartparens-mode)

;; undo/redo history
(use-package undo-tree
  :config
  (global-undo-tree-mode)
  (setq undo-tree-visualizer-diff t)
  :diminish)

;; expand selection ala IDEA
(use-package expand-region
  :bind
  ("<M-up>" . er/expand-region)
  ("<M-down>" . er/contract-region))

;; useful commands
(use-package crux
  :bind (
         ([remap move-beginning-of-line] . crux-move-beginning-of-line)
         ("<S-return>" . crux-smart-open-line)
         ("<C-S-return>" . crux-smart-open-line-above)
         ("C-k" . crux-kill-and-join-forward)
         ("<C-S-backspace>" . crux-kill-whole-line)
         ("C-S-k" . crux-kill-line-backwards)
         ("C-c d" . crux-duplicate-current-line-or-region))
  :demand)

;; org-mode
(use-package org)

;; easily transpose lines
(use-package move-text)

;; move text
(defhydra hydra-move-text ()
  "Move text"
  ("u" move-text-up "up")
  ("d" move-text-down "down"))

(global-set-key (kbd "C-S-u") #'hydra-move-text/move-text-up)
(global-set-key (kbd "C-S-d") #'hydra-move-text/move-text-down)

;; hide show
(defhydra hydra-hs (global-map "C-c @")
  "
Hide^^            ^Show^            ^Toggle^    ^Navigation^
----------------------------------------------------------------
_h_ hide all      _s_ show all      _t_oggle    _n_ext line
_d_ hide block    _a_ show block              _p_revious line
_l_ hide level

_SPC_ cancel
"
  ("s" hs-show-all)
  ("h" hs-hide-all)
  ("a" hs-show-block)
  ("d" hs-hide-block)
  ("t" hs-toggle-hiding)
  ("l" hs-hide-level)
  ("n" forward-line)
  ("p" (forward-line -1))
  ("SPC" nil)
  )

(key-chord-define-global "hh" 'hydra-hs/body)

;; multi-cursor
(use-package multiple-cursors)

(defhydra hydra-multiple-cursors (:hint nil)
  "
 Up^^             Down^^           Miscellaneous           % 2(mc/num-cursors) cursor%s(if (> (mc/num-cursors) 1) \"s\" \"\")
------------------------------------------------------------------
 [_p_]   Next     [_n_]   Next     [_l_] Edit lines  [_0_] Insert numbers
 [_P_]   Skip     [_N_]   Skip     [_a_] Mark all    [_A_] Insert letters
 [_M-p_] Unmark   [_M-n_] Unmark   [_s_] Search
 [Click] Cursor at point       [_q_] Quit"
  ("l" mc/edit-lines :exit t)
  ("a" mc/mark-all-like-this :exit t)
  ("n" mc/mark-next-like-this)
  ("N" mc/skip-to-next-like-this)
  ("M-n" mc/unmark-next-like-this)
  ("p" mc/mark-previous-like-this)
  ("P" mc/skip-to-previous-like-this)
  ("M-p" mc/unmark-previous-like-this)
  ("s" mc/mark-all-in-region-regexp :exit t)
  ("0" mc/insert-numbers :exit t)
  ("A" mc/insert-letters :exit t)
  ("<mouse-1>" mc/add-cursor-on-click)
  ;; Help with click recognition in this hydra
  ("<down-mouse-1>" ignore)
  ("<drag-mouse-1>" ignore)
  ("q" nil))

(key-chord-define-global "mc" 'hydra-multiple-cursors/body)

(use-package emojify :hook (after-init . global-emojify-mode))

;; -------------------------------- generic programming --------------------------------

;; lsp
;; (use-package eglot
;; :config (add-to-list 'eglot-server-programs '(rust-mode . ("rust-analyzer"))))

;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
(setq lsp-keymap-prefix "C-l")

(use-package lsp-mode
  :commands lsp
  :custom
  ;; what to use when checking on-save. "check" is default, I prefer clippy
  (lsp-rust-analyzer-cargo-watch-command "clippy")
  (lsp-eldoc-render-all t)
  (lsp-idle-delay 0.6)
  :config
  (setq lsp-modeline-code-actions-segments '(count name icon))
  (setq lsp-headerline-breadcrumb-enable nil)
  :diminish)

;; (use-package lsp-ui
;; :commands lsp-ui-mode
;; :custom
;; (lsp-ui-sideline-enable nil)
;; (lsp-ui-peek-always-show t)
;; (lsp-ui-sideline-show-hover t)
;; (lsp-ui-doc-enable nil))

(setq lsp-rust-analyzer-proc-macro-enable t)
(setq lsp-rust-analyzer-cargo-load-out-dirs-from-check t)

(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)

(use-package which-key
  :config
  (which-key-mode)
  :diminish)

;; autocomplete
(use-package company
  :ensure
  :custom
  (company-idle-delay 0.5) ;; how long to wait until popup
  ;; (company-begin-commands nil) ;; uncomment to disable popup
  :hook (emacs-lisp-mode . company-mode)
  :bind (("<C-tab>" . company-complete)
         :map company-active-map
	 ("C-n" . company-select-next)
	 ("C-p" . company-select-previous)
	 ("M-<" . company-select-first)
	 ("M->" . company-select-last))
  :diminish)

;; snippets for autocomplete
(use-package yasnippet
  :config
  (yas-reload-all)
  (add-hook 'prog-mode-hook 'yas-minor-mode)
  (add-hook 'text-mode-hook 'yas-minor-mode)
  :diminish yas-minor-mode)

;; guess indentation
(use-package dtrt-indent
  :hook (prog-mode . dtrt-indent-mode)
  :diminish)

;; flymake alternative
(use-package flycheck
  :diminish)

(use-package eldoc
  :diminish)

;; (setq eldoc-echo-area-display-truncation-message nil)
;; (setq eldoc-echo-area-use-multiline-p 3)

(use-package all-the-icons)

;; -------------------------------- programming languages --------------------------------

(use-package rustic
  :bind (:map rustic-mode-map
              ("M-j" . lsp-ui-imenu)
              ("M-?" . lsp-find-references)
              ("C-c C-c l" . flycheck-list-errors)
              ("C-c C-c a" . lsp-execute-code-action)
              ("C-c C-c r" . lsp-rename)
              ("C-c C-c q" . lsp-workspace-restart)
              ("C-c C-c Q" . lsp-workspace-shutdown)
              ("C-c C-c s" . lsp-rust-analyzer-status))
  :config
  ;; uncomment for less flashiness
  ;; (setq lsp-eldoc-hook nil)
  ;; (setq lsp-enable-symbol-highlighting nil)
  (setq lsp-signature-auto-activate nil)

  ;; comment to disable rustfmt on save
  (add-hook 'rustic-mode-hook 'rk/rustic-mode-hook))

(eval-after-load "rustic"
  '(progn (define-key rustic-mode-map (kbd "C-c C-p") nil)))

(defun rk/rustic-mode-hook ()
  ;; so that run C-c C-c C-r works without having to confirm
  (setq-local buffer-save-without-query t))

;; markdown
(use-package markdown-mode
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown")
  :config (unbind-key "C-c C-p" markdown-mode-map))

(use-package yaml-mode)

;; node-modules
(use-package add-node-modules-path)

;; prettier
(use-package prettier-js)

;; javascript
(use-package js2-mode
  :mode "\\.js\\'")

(use-package rjsx-mode)

;; typescript
(use-package typescript-mode)

;; tsx
(use-package web-mode
  :mode "\\.tsx\\'"
  :config
  ((flycheck-add-mode 'javascript-eslint 'web-mode)))

(defun setup-prettier ()
  (interactive)
  (add-node-modules-path)
  (prettier-js-mode))

(eval-after-load 'js2-mode
  '(add-hook 'js2-mode-hook 'setup-prettier))

(eval-after-load 'typescript-mode
  '(add-hook 'typescript-mode-hook 'setup-prettier))

(eval-after-load 'web-mode
  '(add-hook 'web-mode-hook 'setup-prettier))

(defun remove-conflicting-tide-format()
  "removes tide formatter when prettier-js-mode is enabled"
  (if prettier-js-mode
      (remove-hook 'before-save-hook 'tide-format-before-save)
    (when tide-mode
      (add-hook 'before-save-hook 'tide-format-before-save))))

(eval-after-load 'prettier-js
  '(add-hook 'prettier-js-mode-hook 'remove-conflicting-tide-format))

;; tsserver
(use-package tide
  :init
  (defun setup-tide-mode ()
    (interactive)
    (tide-setup)
    (tide-hl-identifier-mode)
    (flycheck-mode)
    (company-mode))
  (defun setup-tsx-mode ()
    (when (string-equal "tsx" (file-name-extension buffer-file-name))
      (setup-tide-mode)))
  :after (typescript-mode company flycheck)
  :hook ((typescript-mode . setup-tide-mode)
         (js2-mode . setup-tide-mode)
         (web-mode . setup-tsx-mode)
         (before-save . tide-format-before-save))
  ;; replacement for x-ref-find-references in tide
  :config
  ;; (define-key tide-mode-map (kbd "M-?") 'tide-references)
  (flycheck-add-next-checker 'javascript-eslint 'javascript-tide 'append)
  (flycheck-add-next-checker 'typescript-tide 'javascript-eslint 'append)
  :diminish)

;; diminish workarounds
(add-hook 'hs-minor-mode-hook (lambda () (diminish 'hs-minor-mode)))

;; org mode

(use-package org-present)

;; (push "~/workspace/ob-rust/" load-path)
;; (require 'ob-rust)

(add-hook 'org-present-mode-hook
          (lambda ()
            (org-present-big)
            (org-display-inline-images)
            (org-present-hide-cursor)
            (org-present-read-only)))

(add-hook 'org-present-mode-quit-hook
          (lambda ()
            (org-present-small)
            (org-remove-inline-images)
            (org-present-show-cursor)
            (org-present-read-write)))
