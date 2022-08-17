;; Set option key to be the meta key
(setq mac-option-modifier 'meta)
(setq mac-escape-modifier nil)

;; So that emacs follows my links without prompt
(setq vc-follow-symlinks t)

;; The only proper tab formatting
(setq tab-width 4)
(setq indent-tabs-mode nil)

;; Make sure emacs knows the background is black
(add-to-list 'default-frame-alist '(background-color . "black"))
;; ## added by OPAM user-setup for emacs / base ## 56ab50dc8996d2bb95e7856a6eddb17b ## you can edit, but keep this line
(require 'opam-user-setup "~/.emacs.d/opam-user-setup.el")
;; ## end of OPAM user-setup addition for emacs / base ## keep this line
