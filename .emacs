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
