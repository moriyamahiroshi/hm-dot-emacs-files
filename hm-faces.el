;;; hm-faces.el ---

;; Copyright (C) 2012  MORIYAMA Hiroshi

;; Author: MORIYAMA Hiroshi <hiroshi@kvd.biglobe.ne.jp>
;; Keywords: faces

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(require 'hm-group)
(require 'font-lock)

(eval-after-load "font-lock"
  '(global-font-lock-mode t))

(defgroup hm-faces nil
  "My faces for font-lock highlighthing."
  :group 'my)

;;; Heading Faces

(defface hm-heading-level-1-face
  '((((class color) (background dark))
     (:height 1.47 :foreground "#333372" :weight bold))
    (t (nil)))
  "Face for heading comment in Lisp or Emacs-Lisp mode buffer."
  :group 'hm-faces)

(defface hm-heading-level-1-filename-part-face
  '((((class color) (background dark))
     (:height 2.0 :foreground "white" :weight bold))
    (t (nil)))
  "Face for heading top-level heading comment (the first line) in
Emacs-Lisp mode buffer."
  :group 'hm-faces)

(defface hm-heading-level-1-description-part-face
  '((((class color) (background dark))
     (:height 0.6 :weight bold :foreground "LightGray"
              :inherit 'hm-heading-level-1-filename-part-face))
    (t (nil)))
  "Face for heading top-level heading comment (the first line) in
Emacs-Lisp mode buffer."
  :group 'hm-faces)

(defface hm-heading-level-2-face
  '((((class color) (background dark))
     (:height 1.6 :foreground "deep sky blue" :weight bold))
    (t (nil)))
  "Face for heading comment in Lisp or Emacs-Lisp mode buffer."
  :group 'hm-faces)

(defface hm-heading-level-3-face
  '((((class color) (background light))
     (:height 1.5 :weight bold :foreground "forest green"))
    (((class color) (background dark))
     (:height 1.5 :weight bold :foreground "orange"))
    (t (nil)))
  "Face for heading comment in Lisp or Emacs-Lisp mode buffer."
  :group 'hm-faces)

(defface hm-heading-level-4-face
  '((((class color) (background light))
     (:height 1.2 :weight bold :foreground "dark green"))
    (((class color) (background dark))
     (:height 1.2 :weight bold :foreground "spring green"))
    (t (nil)))
  "Face for heading comment in Lisp or Emacs-Lisp mode buffer."
  :group 'hm-faces)

(defface hm-heading-level-5-face
  '((((class color) (background light))
     (:weight bold :foreground "Firebrick"))
    (((class color) (background dark))
     (:weight bold :foreground "chocolate1"))
    (t (nil)))
  "Face for heading comment in Lisp or Emacs-Lisp mode buffer."
  :group 'hm-faces)

(defface hm-ends-here-comment-face
  '((((class color) (background light))
     (:weight bold :foreground "Firebrick"))
    (((class color) (background dark))
     (:weight bold :foreground "chocolate1"))
    (t (nil)))
  "Face for end here comment (e.g. \";;; .emacs.el ends here.\")."
  :group 'hm-faces)

;;; Bracket Faces

(defface hm-paren-face
  '((((class color) (background light))
     (:foreground "#999"))
    (((class color) (background dark))
     (:foreground "#AAA"))
    (t (nil)))
  "Face for parenthesis in source code."
  :group 'hm-faces)

(defface hm-brace-face
  '((((class color) (background light))
     (:foreground "#999"))
    (((class color) (background dark))
     (:foreground "#AAA"))
    (t (nil)))
  "Face for braces in source code."
  :group 'hm-faces)

(defface hm-bracket-face
  '((((class color) (background light))
     (:foreground "#999"))
    (((class color) (background dark))
     (:foreground "#AAA"))
    (t (nil)))
  "Face for bracket in source code."
  :group 'hm-faces)

(font-lock-add-keywords 'lisp-mode '(("(\\|)" . 'hm-paren-face)))
(font-lock-add-keywords 'emacs-lisp-mode '(("(\\|)" . 'hm-paren-face)))
(font-lock-add-keywords 'js-mode '(("(\\|)" . 'hm-paren-face)))
(font-lock-add-keywords 'js-mode '(("{\\|}" . 'hm-brace-face)))
(font-lock-add-keywords 'js-mode '(("\\[\\|\\]" . 'hm-bracket-face)))

;;; Font-lock matcher regexps

(defvar hm-heading-level-3-lisp-re
  "^;;;\\(?:[ \t]*\\|[ \t].+?\\)$")

;;; Font-lock matcher functions

(defun hm-re-search-orphaned-line-forward (line-re &optional limit)
  "現在位置からバッファ位置 LIMIT まで、乃至 LIMIT が NIL であれば
`point-max' までの間で 、正規表現 LINE-RE に一致し、且つ前後の行が
同じ正規表現に一致 *しない* 行(孤立行)を探索し、その行に正規表現
LINE-RE が一致した際の `match-data' を返す。

LINE-RE が複數行に一致し得る正規表現だつた場合の擧動は未定義。"
  (let ((looking-at-relative-line
         #'(lambda (relative-line-number regexp)
             (save-excursion
               (save-restriction
                 (widen)
                 (and (zerop (forward-line relative-line-number))
                      (looking-at regexp)))))))
    (save-restriction
      (narrow-to-region (point) (or limit (point-max)))
      (when (re-search-forward line-re nil t)
        (when (save-match-data
                (not (or (apply looking-at-relative-line (list -1 line-re))
                         (apply looking-at-relative-line (list 1 line-re)))))
          (match-data))))))

;;; Add font lock keywords for Emacs Lisp mode

(font-lock-add-keywords 'emacs-lisp-mode
  `(("^;;; .*"
     . (0 'hm-heading-level-4-face t))
    ("^;;; .*"
     . (0 'hm-heading-level-5-face t))
    ((lambda (limit)
       (hm-re-search-orphaned-line-forward hm-heading-level-3-lisp-re limit))
     . (0 'hm-heading-level-3-face t))
    ("^;;; \\(?:Commentary\\|Code\\):[ \t]*$"
     . (0 'hm-heading-level-2-face t))
    ("^;;; \\(?:.+? \\)?ends here[.]?\\s-*$"
     . (0 'hm-ends-here-comment-face t))
    ;;
    ;; First line.
    ("\\`;;; \\(.+? --- .+\\)$" . (1 'hm-heading-level-1-face t))
    ;;
    ;; First line with filename and short description.
    ("\\`\\(;;; .*?\\)\\(\\(?: \\(---\\|—\\) .+\\)?\\)$"
     (1 'hm-heading-level-1-filename-part-face t)
     (2 'hm-heading-level-1-description-part-face t))
    ;;
    ;; Advice.
    ("\\<ad-do-it\\>" . (0 'font-lock-builtin-face))
    ;;
    ;; "def****" macros.
    ;; (this keyword definition is based on `lisp-font-lock-keywords-1' defined
    ;; in `font-lock.el').
    (,(concat "(\\("
              ;; Package prefix.
              "\\(?:\\sw+?-\\)"
              "def\\(?:ine-?\\)?"
              ;; Variable declarations.
              "\\(?:\\(?:\\(?:buffer-?\\)?local-?\\)?var\\(?:iable\\)?\\)\\)\\>"
              ;; Any whitespace and defined object.
              "[ \t'\(]*"
              "\\(setf[ \t]+\\sw+)\\|\\sw+\\)?")
     (1 'font-lock-keyword-face)
     (2 'font-lock-variable-name-face nil t))))

;;; Font Lock Keywords in Lisp Mode

(font-lock-add-keywords 'lisp-mode
  `(((lambda (limit)
       (hm-re-search-orphaned-line-forward hm-heading-level-3-lisp-re limit))
     . (0 'hm-heading-level-3-face t))
    ("^;;; \\(?:Commentary\\|Code\\):[ \t]*$"
     . (0 'hm-heading-level-2-face t))
    ("^;;; \\(?:.+? \\)?ends here[.]?\\s-*$"
     . (0 'hm-ends-here-comment-face t))))

(defun hm-lisp-add-function-keyword (name indent-hook-number)
  (font-lock-add-keywords 'lisp-mode
    `((,(concat "(\\(\\(?:[^:\s-]+:\\)?" (symbol-name name) "\\)\\>")
       . (1 font-lock-keyword-face))))
  (put name 'lisp-indent-hook indent-hook-number))

(hm-lisp-add-function-keyword 'defcfun 2) ;CFFI
(hm-lisp-add-function-keyword 'defcvar 2) ;CFFI
(hm-lisp-add-function-keyword 'defcenum 1);CFFI
(hm-lisp-add-function-keyword 'defctype 1) ;CFFI
(hm-lisp-add-function-keyword 'defcstruct 1) ;CFFI

;;; CSS mode

(font-lock-add-keywords 'css-mode
  `(("^[ \t]*/\\* ::::: .+? ::::: \\*/[ \t]*$"
     . (0 'hm-heading-level-2-face t))))

;;; Comment Lines

(add-hook 'find-file-hook
  #'(lambda ()
      (when (or (string-match (concat "/\\.git/info/exclude\\'")
                              (or (buffer-file-name) "")))
        (set-syntax-table (let ((table (copy-syntax-table text-mode-syntax-table)))
                            (modify-syntax-entry ?\# "<" table)
                            (modify-syntax-entry ?\n ">" table)
                            (modify-syntax-entry ?\\ "\\" table)
                            table))
        (font-lock-fontify-buffer))))

(defun hm-set-background-color-light ()
  ;; Created: 2011-09-22T13:36:59+09:00
  (interactive)
  (set-background-color "#FEFEFA")
  (set-foreground-color "black"))

(defun hm-set-background-color-dark ()
  ;; Created: 2011-09-22T13:36:59+09:00
  (interactive)
  (set-background-color "gray4")
  (set-foreground-color "white"))

(provide 'hm-faces)
;;; hm-faces.el ends here
