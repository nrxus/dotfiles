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
  :bind* ("M-o" . ace-window))

;; git
(use-package magit
  :bind ("C-x g" . magit-status))

(use-package diff-hl)
(global-diff-hl-mode)
(add-hook 'dired-mode-hook 'diff-hl-dired-mode)
(add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
(add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)

;; search
(use-package ivy
  :config
  (ivy-mode)
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  :diminish)

(use-package counsel
  :config (counsel-mode)
  :bind ("C-c s")
  :diminish)

(use-package swiper
  :bind ("C-s" . swiper-isearch))

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
  :hook ((prog-mode . turn-on-smartparens-strict-mode))
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

;; expand selection
(use-package expand-region)

;; generic programming

;; lsp
(use-package eglot
  :config (add-to-list 'eglot-server-programs '(rust-mode . ("rust-analyzer"))))

;; autocomplete
(use-package company)

;; snippets for autocomplete
(use-package yasnippet
  :config (yas-global-mode t)
  :diminish)

;; programming languages

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
