;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq-default with-editor-emacsclient-executable "emacsclient")

(when (>= emacs-major-version 24)
  (require 'package)
  (package-initialize)
  (add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
  )

(require 'poly-R)
(require 'poly-markdown)

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Jacob Levine"
      user-mail-address "jacoblevine@princeton.edu")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'


(setq doom-font (font-spec :family "monospace" :size 14))
(setq doom-theme 'doom-palenight)

;; Setup org and org-roam
(setq org-directory "~/Documents")
(setq org-roam-directory "~/Documents/Science/notes")

;;(add-to-list 'org-structure-template-alist '("r" . "src R"))

(setq org-id-track-globally t)
(setq org-agenda-files (directory-files-recursively "~/Documents/Science/notes" "org$"))
;; create custom todo keywords
(setq org-todo-keywords
       '((sequence "TODO(t)" "MAYBE(m)" "STARTED(s)" "WAIT(w)" "|" "DONE(d)" "CANCELLED(c)")))

;; make syntax highlighting work on export
;;(setq org-html-htmlize-output-type 'css)
(setq org-src-fontify-natively t)

;; make roam autosyn on startup
;;(org-roam-db-autosync-mode)
;; configure dailies
(setq org-roam-dailies-directory "dailies/")

(setq org-roam-dailies-capture-templates
      '(("d" "default" entry "* %?" :if-new
         (file+head "%<%Y-%m-%d>.org"
                    "#+title: %<%Y-%m-%d>"))))


(setq org-roam-completion-everywhere t)

(use-package org
  :bind (:map org-mode-map
         ("C-M-i" . completion-at-point)))

(require `org-inlinetask)

;;org-jekyll-lite
(add-to-list 'load-path "~/.doom.d/lisp/ox-jekyll-lite/")
(require 'ox-jekyll-lite)
(setq org-jekyll-project-root "~/Documents/Science/Website/jsilevine.github.io/")

;; yasnippets
(setq yas-snippet-dirs '("~/.doom.d/snippets"))
(yas-global-mode 1)

;; flyspell
;; (global-set-key (kbd "C-c s c") 'flyspell-auto-correct-previous-word)

;; org-ref
(after! org
  (require 'org-ref))

(use-package! org-ref

  ;; this bit is highly recommended: make sure Org-ref is loaded after Org
  :after org

  ;; Put any Org-ref commands here that you would like to be auto loaded:
  ;; you'll be able to call these commands before the package is actually loaded.
  :commands
  (org-ref-cite-hydra/body
   org-ref-bibtex-hydra/body)

  ;; if you don't need any autoloaded commands, you'll need the following
  ;; :defer t

  ;; This initialization bit puts the `orhc-bibtex-cache-file` into `~/.doom/.local/cache/orhc-bibtex-cache
  ;; Not strictly required, but Org-ref will pollute your home directory otherwise, creating the cache file in ~/.orhc-bibtex-cache
  :init
  (let ((cache-dir (concat doom-cache-dir "org-ref")))
    (unless (file-exists-p cache-dir)
      (make-directory cache-dir t))
    (setq orhc-bibtex-cache-file (concat cache-dir "/orhc-bibtex-cache"))))


(setq bibtex-completion-bibliography '("~/Documents/Science/bibtex/My Library.bib")
	;;bibtex-completion-library-path '("~/Dropbox/emacs/bibliography/bibtex-pdfs/")
	;;bibtex-completion-notes-path "~/Dropbox/emacs/bibliography/notes/"
	;;bibtex-completion-notes-template-multiple-files "* ${author-or-editor}, ${title}, ${journal}, (${year}) :${=type=}: \n\nSee [[cite:&${=key=}]]\n"

	bibtex-completion-additional-search-fields '(keywords)
	bibtex-completion-display-formats
	'((article       . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} ${journal:40}")
	  (inbook        . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} Chapter ${chapter:32}")
	  (incollection  . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} ${booktitle:40}")
	  (inproceedings . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} ${booktitle:40}")
	  (t             . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*}"))
	bibtex-completion-pdf-open-function
	(lambda (fpath)
	  (call-process "open" nil 0 nil fpath)))


(require 'bibtex)

(setq bibtex-autokey-year-length 4
	bibtex-autokey-name-year-separator "-"
	bibtex-autokey-year-title-separator "-"
	bibtex-autokey-titleword-separator "-"
	bibtex-autokey-titlewords 2
	bibtex-autokey-titlewords-stretch 1
	bibtex-autokey-titleword-length 5
	org-ref-bibtex-hydra-key-binding (kbd "H-b"))

(define-key bibtex-mode-map (kbd "H-b") 'org-ref-bibtex-hydra/body)

(require 'org-ref-ivy)

(setq org-ref-insert-link-function 'org-ref-insert-link-hydra/body
      org-ref-insert-cite-function 'org-ref-cite-insert-ivy
      org-ref-insert-label-function 'org-ref-insert-label-link
      org-ref-insert-ref-function 'org-ref-insert-ref-link
      org-ref-cite-onclick-function (lambda (_) (org-ref-citation-hydra/body)))

(define-key org-mode-map (kbd "C-c ]") 'org-ref-insert-link)

(setq org-latex-pdf-process
      '("pdflatex -interaction nonstopmode -output-directory %o %f"
	"bibtex %b"
	"pdflatex -interaction nonstopmode -output-directory %o %f"
	"pdflatex -interaction nonstopmode -output-directory %o %f"))

;; ox-word -- for converting pdf files to .docx
(use-package ox-word
:load-path "~/.doom.d/ox-word"
:after ox)


;; set useful org keybindings
(global-set-key (kbd "C-c n i") 'org-roam-node-insert)
(global-set-key (kbd "C-c n l") 'org-roam-buffer-toggle)
(global-set-key (kbd "C-c n f") 'org-roam-node-find)
(global-set-key (kbd "C-c n c") 'org-mark-ring-goto)
(global-set-key (kbd "C-c n n") 'org-id-get-create)
(global-set-key (kbd "C-c n d") 'org-roam-dailies-capture-today)


;; Default-Frame-Alist
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(cursor-color . "white"))

;; set up buffer orientation to be like Rstudio
 (setq ess-ask-for-ess-directory nil)
 (setq ess-local-process-name "R")
 (setq ansi-color-for-comint-mode 'filter)
 (setq comint-scroll-to-bottom-on-input t)
 (setq comint-scroll-to-bottom-on-output t)
 (setq comint-move-point-for-output t)

 ;;  (defun my-ess-start-R ()
 ;;    (interactive)
 ;;    (unless (mapcar (lambda (s) (string-match "*R" (buffer-name s))) (buffer-list)))
 ;;     (unless (string-match "*R" (mapcar (function buffer-name) (buffer-list)))
 ;;        (progn
 ;;          (delete-other-windows)
 ;;          (setq w1 (selected-window))
 ;;          (setq w1name (buffer-name))
 ;;          (setq w2 (split-window-right w1 nil t))
 ;;          (R)
 ;;          (set-window-buffer w2 "*R")
 ;;          (set-window-buffer w1 w1name))))
 ;; (defun my-ess-eval ()
 ;;   (interactive)
 ;;   (my-ess-start-R)
 ;;   (if (and transient-mark-mode mark-active)
 ;;       (call-interactively 'ess-eval-region)
 ;;     (call-interactively 'ess-eval-line-and-step)))
 ;; (add-hook 'ess-mode-hook
 ;;           '(lambda()
 ;;              (local-set-key [(shift return)] 'my-ess-eval)))
 ;; (add-hook 'inferior-ess-mode-hook
 ;;           '(lambda()
 ;;              (local-set-key [C-up] 'comint-previous-input)
 ;;              (local-set-key [C-down] 'comint-next-input)))
 ;; (add-hook 'Rnw-mode-hook
 ;;           '(lambda()
 ;;              (local-set-key [(shift return)] 'my-ess-eval)))

;; (require 'ess-site)

;; (defun markdown-html (buffer)
;;   (princ (with-current-buffer buffer
;;     (format "<!DOCTYPE html><html><title>Impatient Markdown</title><xmp theme=\"united\" style=\"display:none;\"> %s  </xmp><script src=\"http://strapdownjs.com/v/0.2/strapdown.js\"></script></html>" (buffer-substring-no-properties (point-min) (point-max))))
;;          (current-buffer)))

;; add keybinding to open and close R dired
 (add-hook 'ess-r-mode-hook
           '(lambda ()
              (local-set-key (kbd "C-c r d") #'ess-rdired)))

 (add-hook 'ess-rdired-mode-hook
           '(lambda ()
              (local-set-key (kbd "C-c r d") #'kill-buffer-and-window)))

(setq inferior-R-program-name "/usr/local/bin/R")

 (set-popup-rules!
   '(("^\\*R dired"
      :side left :slot 1 :height 0.35 :modeline t)
     ("^\\*R.*\\*$"
      :side right :height 0.5 :slot -1 :width 0.4 :modeline t)
     ("^\\*help.*\\*$"
      :side right :slot 1 :height 0.35 :select nil :ttl nil :quit nil :modeline t)
     ("^\\*shell.*\\*$"
      :side left :slot 1 :width 0.25 :height 0.35 :modeline t)
     ("\\.pdf$"
      :side right :height 1 :width 0.5 :modeline t)))

;; make treemacs navigable to
(after! (:and treemacs ace-window)
  (setq aw-ignored-buffers (delq 'treemacs-mode aw-ignored-buffers)))

(with-eval-after-load 'doom-themes
  (doom-themes-treemacs-config))

;;(treemacs-load-theme "doom-atom")


;; ;; add keybinding for rmarkdown code-chunks
;; (defun jil-insert-r-chunk (header)
;;   "Insert an r-chunk in markdown mode."
;;   (interactive "sLabel: ")
;;   (insert (concat "```{r " header "}\n\n```"))
;;   (forward-line -1))


;; Set new convenient keybindings
(global-set-key (kbd "C-c i") 'jil-insert-r-chunk)
(global-set-key (kbd "C-x t m") 'treemacs)
(global-set-key (kbd "C-c l") 'org-store-link)
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c c") 'org-capture)
(global-set-key (kbd "C-c s s") 'shell)
(global-set-key (kbd "C-x o") 'ace-window)

;; use lintr and flycheck
(add-hook 'after-init-hook #'global-flycheck-mode)
(add-hook 'ess-mode-hook
          (lambda () (flycheck-mode t)))

;;;; change run shortcut to control+enter
;;(eval-after-load "ess-mode"
  ;;'(progn
    ;; (define-key ess-mode-map [(control return)] 'ess-eval-region-or-line-and-step)))

(use-package projectile
  :init
  (setq
   ;; we mainly want projects defined by a few markers and we always want to take the top-most marker.
   ;; Reorder so other cases are secondary
   projectile-project-root-files #'( ".projectile" )
   projectile-project-root-files-functions #'(projectile-root-top-down
                                              projectile-root-top-down-recurring
                                              projectile-root-bottom-up
                                              projectile-root-local)))

(setq projectile-project-search-path '("~/Documents/Science/Princeton/"))
(setq projectile-indexing-method 'hybrid)

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', where Emacs
;;   looks when you load packages with `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "John Doe"
      user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


(setenv "PATH" (concat (getenv "PATH") ":/Library/TeX/texbin/"))
(setq exec-path (append exec-path '("/Library/TeX/texbin/")))

(setenv "PATH" "/usr/local/bin:/Library/TeX/texbin/:$PATH" t)
(setq exec-path (append exec-path '("/Library/TeX/texbin")))


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
