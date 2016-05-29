;; misc settings ---------------------------------------------------------------

(prefer-coding-system 'utf-8)
(setq column-number-mode t)
(setq default-major-mode 'text-mode)
(setq indent-tabs-mode nil)
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)
(setq initial-major-mode 'text-mode)
(setq initial-scratch-message "")
(setq make-backup-files nil)
(setq sentence-end-double-space nil)
(setq suggest-key-bindings t)
(setq tab-witdh 4)
(setq visible-bell t)

;; global keys -----------------------------------------------------------------

(global-set-key (kbd "RET") 'newline-and-indent)
  
;; theme and appearance --------------------------------------------------------

(if (eq system-type 'windows-nt)
    (set-default-font "Consolas-11")
  (set-default-font "DejaVu Sans Mono-12"))

(require 'package)
(package-initialize)
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.org/packages/") t)
(load-theme 'zenburn t)

;; JavaScript ------------------------------------------------------------------

(autoload 'js2-mode "js2-mode" nil 2)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

;; org-mode --------------------------------------------------------------------

(defun ha4-browse-org-html ()
  (interactive)
  (w32-shell-execute "open" (concat (file-name-sans-extension buffer-file-name) ".html")))

(add-hook
 'org-mode-hook
 (lambda ()
   (setq org-agenda-files (list "~/OneDrive"))
   (require 'ox-html)
   (setq org-html-head
	 (concat
	  "<link rel='stylesheet' type='text/css' href='http://www.pirilampo.org/styles/readtheorg/css/htmlize.css'/>"
	  "<link rel='stylesheet' type='text/css' href='http://www.pirilampo.org/styles/readtheorg/css/readtheorg.css'/>"
	  "<script src='https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js'></script>"
	  "<script src='https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js'></script>"
	  "<script type='text/javascript' src='http://www.pirilampo.org/styles/readtheorg/js/readtheorg.js'></script>"))
   (local-set-key (kbd "<f5>") 'org-html-export-to-html)   
   (local-set-key (kbd "<f6>") 'ha4-browse-org-html)   
   (add-to-list 'org-html-mathjax-options
		(list 'path
		      (concat "https://cdn.mathjax.org/mathjax"
			      "/latest/MathJax.js?"
			      "config=TeX-AMS-MML_HTMLorMML")))))

;; paredit ---------------------------------------------------------------------

(autoload 'enable-paredit-mode "paredit"
  "Turn on pseudo-structural editing of Lisp code." t)
(add-hook 'emacs-lisp-mode-hook #'enable-paredit-mode)
(add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)
(add-hook 'ielm-mode-hook #'enable-paredit-mode)
(add-hook 'lisp-mode-hook #'enable-paredit-mode)
(add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
(add-hook 'scheme-mode-hook #'enable-paredit-mode)
