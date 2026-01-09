;; --- 1. Package Management & Installation ---
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Automatically install all required packages
(setq my-packages '(adwaita-dark-theme swiper treemacs vertico orderless vterm yaml-mode jinja2-mode ansible ansible-doc))
(dolist (pkg my-packages)
  (unless (package-installed-p pkg)
    (package-refresh-contents)
    (package-install pkg)))


(global-set-key (kbd "C-f") 'swiper)  ; Ctrl-F now opens a list of all matches

;; --- 2. GNOME Look & Feel ---
(setq inhibit-startup-message t)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode -1)
(setq frame-resize-pixelwise t)
(setq frame-title-format '("")) ; Clean title bar

(set-face-attribute 'default nil :font "Adwaita Mono-12")
(load-theme 'adwaita-dark t)
(setq ring-bell-function 'ignore)

;; --- 3. Standard Behavior (CUA & Search) ---
(cua-mode t)                 ; Standard Ctrl-C, Ctrl-V, Ctrl-X, Ctrl-Z
(vertico-mode t)             ; Clean vertical search list
(setq completion-styles '(orderless basic)) ; Fuzzy search logic

;; --- 4. Navigation Shortcuts (GNOME Style) ---
(global-set-key (kbd "C-p") 'project-find-file)          ; Search project (VS Code style)
(global-set-key (kbd "C-w") 'kill-current-buffer)       ; Close file
(global-set-key (kbd "<C-tab>") 'next-buffer)           ; Next tab
(global-set-key (kbd "<C-S-iso-lefttab>") 'previous-buffer) ; Previous tab
(global-set-key (kbd "<f8>") 'treemacs)                 ; File tree sidebar
(windmove-default-keybindings 'meta)                    ; Alt + Arrows move between splits

;; --- 5. Terminal (vterm) with Fish ---
(require 'vterm)
(setq vterm-shell (or (executable-find "fish") (executable-find "bash")))

(defun my/toggle-terminal ()
  "Toggle vterm at the bottom of the screen."
  (interactive)
  (let ((vterm-buffer (get-buffer "*vterm*")))
    (if (and vterm-buffer (get-buffer-window vterm-buffer))
        (if (eq (current-buffer) vterm-buffer)
            (delete-window (get-buffer-window vterm-buffer))
          (select-window (get-buffer-window vterm-buffer)))
      (progn
        (split-window-below -12)
        (other-window 1)
        (if (and vterm-buffer (buffer-live-p vterm-buffer))
            (switch-to-buffer vterm-buffer)
          (vterm))))))

(global-set-key (kbd "<f12>") 'my/toggle-terminal)
(global-set-key (kbd "C-S-W") 'kill-current-buffer) ; Kill terminal process

(with-eval-after-load 'vterm
  (define-key vterm-mode-map (kbd "<f12>") nil)
  (define-key vterm-mode-map (kbd "C-S-W") nil)
  (define-key vterm-mode-map (kbd "M-<up>") nil)
  (define-key vterm-mode-map (kbd "M-<down>") nil)
  (define-key vterm-mode-map (kbd "M-<left>") nil)
  (define-key vterm-mode-map (kbd "M-<right>") nil))


;; --- Programming & Syntax Highlighting ---

;; 1. Python, Shell & YAML (Tree-Sitter)
;; Emacs 29+ remapping. Ensure you ran: sudo dnf install tree-sitter-yaml
(setq major-mode-remap-alist
      '((python-mode . python-ts-mode)
        (yaml-mode . yaml-ts-mode)
        (bash-mode . bash-ts-mode)))

;; 2. Enable Global Font Lock (Critical for syntax highlighting)
(global-font-lock-mode t)

;; 3. Ansible Integration
;; We need to ensure ansible-mode activates even when using yaml-ts-mode
(defun my/enable-ansible ()
  "Enable Ansible minor mode."
  (ansible 1))

(add-hook 'yaml-mode-hook 'my/enable-ansible)
(add-hook 'yaml-ts-mode-hook 'my/enable-ansible)

;; Force specific folders/files to be treated as Ansible
;; This is crucial. If a file is just "samba.yml", Emacs just sees YAML.
;; We tell it: "If it's in a 'playbook' or 'roles' folder, it's Ansible."
(add-to-list 'auto-mode-alist '("/playbooks/.*\\.yml\\'" . yaml-ts-mode))
(add-to-list 'auto-mode-alist '("/roles/.*\\.yml\\'" . yaml-ts-mode))
(add-to-list 'auto-mode-alist '("/group_vars/.*" . yaml-ts-mode))
(add-to-list 'auto-mode-alist '("/host_vars/.*" . yaml-ts-mode))

;; 4. Jinja2 & Templates
(require 'jinja2-mode)
(add-to-list 'auto-mode-alist '("\\.j2\\'" . jinja2-mode))
(add-to-list 'auto-mode-alist '("\\.sh\\.j2\\'" . jinja2-mode))
(add-to-list 'auto-mode-alist '("\\.yml\\.j2\\'" . jinja2-mode))

;; 5. Indentation Guides
(unless (package-installed-p 'highlight-indent-guides)
  (package-install 'highlight-indent-guides))
(add-hook 'prog-mode-hook 'highlight-indent-guides-mode)
(add-hook 'yaml-ts-mode-hook 'highlight-indent-guides-mode) ;; Force it on Tree-sitter YAML
(setq highlight-indent-guides-method 'character)


;; --- 6. Keep init.el clean ---
;; This moves the "custom-set-variables" block to a separate file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))


;; --- PGTK GNOME Integration ---
(add-to-list 'default-frame-alist '(undecorated . nil)) ;; Keep decorations but...
(setq frame-resize-pixelwise t)      ; Prevents white gaps at the bottom
(setq window-divider-default-bottom-width 0)
(setq window-divider-default-right-width 0)
(window-divider-mode 1)              ; Removes ugly internal borders
