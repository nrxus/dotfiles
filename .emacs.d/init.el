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

;; ----------------------------- editor tweaks -----------------------------
;; newline at the end by default
(setq-default require-final-newline t)

;; prevent extraneous tabs
(setq-default indent-tabs-mode nil)

;; delete whitespace just when a file is saved.
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; update buffer if files changed in disk
(global-auto-revert-mode t)

;; ------------------------------ x clipboard ------------------------------
;; put x clipboard into the kill ring before replacing it
(setq-default save-interprogram-paste-before-kill t)

;; replace when pasting
(delete-selection-mode)

;; --------------------------------- other tweaks --------------------------------
;; Do not put 'customize' config in init.el; give it another file.
(setq custom-file "~/.emacs.d/custom-file.el")

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

;; window switching
(use-package ace-window
  :bind ("M-o" . ace-window))

;; git
(use-package magit
  :bind ("C-x g" . magit-status))

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
  :config (define-key projectile-mode-map (kbd "C-c C-p") 'projectile-command-map)
  :diminish nil)

(use-package counsel-projectile
  :config (counsel-projectile-mode))

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

;; allow to create cool keychords
(use-package hydra)

(use-package key-chord
  :config (key-chord-mode 1))

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

;; -------------------------------- generic programming --------------------------------

;; lsp
(use-package eglot
  :config (add-to-list 'eglot-server-programs '(rust-mode . ("rust-analyzer"))))

;; autocomplete
(use-package company
  :hook (emacs-lisp-mode . company-mode)
  :bind ("<C-tab>" . company-complete)
  :diminish
  :ensure)

;; snippets for autocomplete
(use-package yasnippet
  :config (yas-global-mode t)
  :diminish)

;; -------------------------------- programming languags --------------------------------

(use-package rust-mode
  :hook
  (rust-mode . eglot-ensure)
  (rust-mode . company-mode))

(use-package markdown-mode
  :ensure t
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))
