;;; init.el --- MORIYAMA Hiroshi's Emacs init file -*- coding: utf-8 -*-

;; Copyright © 2012  MORIYAMA Hiroshi

;; Author: MORIYAMA Hiroshi <hiroshi@kvd.biglobe.ne.jp>

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

;; Get a summary of this file:

;;     % egrep '^;;; ' init.el

;;; Code:


;;; My Group

(defgroup my nil
  "My customize variables."
  :prefix 'my-)

(defcustom my-do-not-read-desktop
  nil
  "この値が非NILの場合初期化ファイルの最後の (desktop-read) を實行
しない。"
  :group 'my
  :type 'boolean)

(defcustom my-default-coding-sytem
  'utf-8-unix
  "Default using character encoding."
  :group 'my)

(defcustom my-hatena-user-name
  nil
  "はてなのID。"
  :group 'my)

(defconst my-emacs-init-file-pathname
  load-file-name
  "Absolute pathname of the init file.")


;;; Debug

;; 起動にかかつた時間を *Message* バッファに印字。
(add-hook 'after-init-hook
  #'(lambda ()
      (message "Init time by Emacs %d: %.3f sec."
               emacs-major-version
               (float-time (time-subtract
                            after-init-time before-init-time)))))

;; "--debug-init" オプション附きで起動したときキー入力を記録する設定。
(when debug-on-error
  (let ((dribble-file "~/.emacs.d/emacs-dribble.log"))
    (rename-file dribble-file (concat dribble-file ".old") t)
    (open-dribble-file dribble-file)))


;;; Title Bar

(defvar my-backup--frame-title-format
  frame-title-format
  "カスタマイズ變數 `frame-title-format' の初期値控。")

(setq frame-title-format
      (concat
       ;; Program name.
       "GNU Emacs"
       ;; Emacs version.
       " " (number-to-string emacs-major-version)
       "." (number-to-string emacs-minor-version)
       ;; (format-time-string " on %Y-%m-%d" emacs-build-time)
       ;; Hostname.
       " @ " system-name
       ;; File name or buffer name.
       " - "
       (replace-regexp-in-string (getenv "HOME") "~"
                                 (or buffer-file-name "%b"))))


;;; Frame Parameters

(setq default-frame-alist (append '((background . "gray4") ;#0a0a0a
                                    (foreground . "white") ;#000000
                                    ;; (height . 40)
                                    ;; (width . 72)
                                    ;; ;; (top . (- 0)) は畫面下端。
                                    ;; ;; (left . (- 0)) は畫面右端。
                                    ;; (top . (- 0))
                                    ;; (left . (- 0))
                                    (menu-bar-lines . 0)
                                    (tool-bar-lines . 0)
                                    (vertical-scroll-bars . nil)
                                    (horizontal-scroll-bars . nil))
                                  default-frame-alist)
      initial-frame-alist default-frame-alist)

;; 即時反映させる。
(modify-frame-parameters (selected-frame) default-frame-alist)


;;; Mode Line

(set-face-background 'modeline "#333372")
(set-face-foreground 'modeline "white")

;; 改行の種類表示。デフォルトは "(DOS)" とか "(Mac)" とか。
(setq-default eol-mnemonic-unix "(LF)")
(setq-default eol-mnemonic-dos "(CRLF)")
(setq-default eol-mnemonic-mac "(CR)")


;;; Customize Variables

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(safe-local-variable-values (quote ((Package . getopt) (Package . getopt-system) (Package . getopt-tests) (Package . CXML) (eval c-set-offset (quote substatement-open) 0) (ruby-indent-level . 4) (tab-always-indent . t) (lexical-binding . t) (Package . HUNCHENTOOT) (Package . CCL) (Package . CHUNGA) (Syntax . ANSI-Common-Lisp) (base . 10) (package . cl-user) (syntax . common-lisp) (Base . 10) (Package . DRAKMA) (Syntax . COMMON-LISP) (Syntax . Common-lisp) (Package . XREF) (Package . metabang\.graph) (tab-always-indent) (Encoding . utf-8) (Package . CL-USER) (Syntax . Common-Lisp) (encoding . utf-8) (readtable . runes)))))


;;; Aliases

(defalias 'char= '=) ;Common Lisp


;;; Utility

;; TODO: `defun-if-undefined' マクロを M-C-x したとき「if-undefined」が
;; T であつても強制的に再評価するアドヴァイス。

;; MEMO: defun系のマクロ定義を括つてゐる條件判定に `unless' ではなく
;; `if' と `not' を使つてゐるのは、`eval-last-sexp' 等で評價したとき、函
;; 數等が定義されたか否かを返値を見て判別可能にするため(`unless' や
;; `when' は常に NIL を返す)。

(if (not (fboundp 'defun-if-undefined))
    (defmacro defun-if-undefined (name &rest rest)
      `(unless (fboundp (quote ,name))
         (defun ,name ,@rest))))

(if (not (fboundp 'demacro-if-undefined))
    (defmacro defmacro-if-undefined (name &rest rest)
      `(unless (fboundp (quote ,name))
         (defmacro ,name ,@rest))))

(defmacro-if-undefined save-current-frame (&rest body)
  (let ((current-frame 'save-current-frame-current-frame))
    `(let ((,current-frame
            (or last-event-frame (selected-frame))))
       (unwind-protect
           ,@body
         (select-frame-set-input-focus ,current-frame)))))

(defun my-buffer-narrowed-p (&optional buffer)
  (with-current-buffer (or buffer (current-buffer))
    (not (zerop (- (1+ (buffer-size)) (point-max))))))

(defun my-replace-string-region (regexp to-string-or-func start end)
  "第二引数 TO-STRING-OR-FUNC は置換へる文字列又は文字列を返す函数。"
  (save-excursion
    (save-restriction
      (save-match-data
        (narrow-to-region start end)
        (goto-char (point-min))
        (while (re-search-forward regexp nil t)
          (replace-match (if (functionp to-string-or-func)
                             (save-match-data (funcall to-string-or-func))
                           to-string-or-func)))))))

(defun my-replace-string-buffer (regexp to-string-or-func)
  (my-replace-string-region regexp to-string-or-func (point-min) (point-max)))

(defun my-last-sexp-string ()
  (buffer-substring-no-properties (save-excursion
                                    (backward-sexp) (point)) (point)))

(defmacro-if-undefined when-exists-file-p (spec &rest body)
  ;; The first argument is '(varname pathname).
  `(when (file-exists-p ,(nth 1 spec))
     (let ((,(nth 0 spec) ,(nth 1 spec)))
       ,@body)))

(defmacro-if-undefined when-directory-p (spec &rest body)
  ;; The first argument is '(varname pathname).
  `(when (file-directory-p ,(nth 1 spec))
     (let ((,(nth 0 spec) ,(nth 1 spec)))
       ,@body)))

(defmacro-if-undefined add-to-load-path (directory-name)
  `(if (and (stringp ,directory-name)
            (file-directory-p ,directory-name))
       (add-to-list (quote load-path) (file-truename ,directory-name))))

(defun my-normalize-pathname (pathname &optional accept-nil)
  "文字列 PATHNAME に `file-truename' 函數を適用したパス名を返す。
それがディレクトリとして實在する場合は、末尾に一つだけ必ず \"/\"が
存在する。それがディレクトリではない場合、末尾の \"/\" は取除かれ
る。

    (my-normalize-pathname \"/usr\")
    ;=> \"/usr/
    (my-normalize-pathname \"/not-exists-directory/\") x
    ;=> \"/not-exists-directory\"
    (my-normalize-pathname \"/usr/bin///\")
    ;=> \"/usr/bin/\"
    (my-normalize-pathname \"/usr/bin/../sbin\")
    ;=> \"/usr/sbin/\"
    (my-normalize-pathname \"~/.emacs.d/.\")
    ;=> \"/home/user/.emacs.d/\"

この函數は通常第一引數が文字列であることを想定してゐるが、第二引數
ACCEPT-NIL が 非nilの場合、PATHNAME が nil でもエラーを發生させず
に nil を返すやうになる。これは、文字列または nil を返す函數をその
まま引數として呼出可能とするためのオプションである。"
  (if (and accept-nil (null pathname))
      nil
    (let ((truename (file-truename pathname)))
      (let ((truename (if (string-match "/\\'" truename)
                          truename
                        (concat truename "/"))))
        (if (file-directory-p truename)
            truename
          ;; strip "/".
          (substring truename 0 -1))))))

(defun-if-undefined inside-string-or-comment-p ()
  (let ((state (parse-partial-sexp (point-min) (point))))
    (or (nth 3 state) (nth 4 state))))

(defun-if-undefined re-search-forward-without-string-and-comments (&rest args)
  (let ((value (apply #'re-search-forward args)))
    (if (and value (inside-string-or-comment-p))
        (apply #'re-search-forward-without-string-and-comments args)
      value)))

(put 'defun-if-undefined 'lisp-indent-hook 'defun)
(put 'defmacro-if-undefined 'lisp-indent-hook 'defun)
(put 'save-current-frame 'lisp-indent-hook 'defun)
(put 'when-exists-file-p 'lisp-indent-hook 1)
(put 'when-directory-p 'lisp-indent-hook 1)

(font-lock-add-keywords 'emacs-lisp-mode
  '(("(\\(def\\(?:un\\|macro\\)-if-undefined\\)\\>"
     . (1 font-lock-keyword-face))
    ("(\\(save-current-frame\\)\\>"
     . (1 font-lock-keyword-face))))


;;; Load Path Utility

(defun-if-undefined user-emacs-directory ()
  (if (and (boundp 'user-emacs-directory)
           (stringp user-emacs-directory))
      (my-normalize-pathname user-emacs-directory)
    nil))

(add-to-list 'load-path (user-emacs-directory))


;;; `hm-' prefix

(require 'hm-group)


;;; Language and Character Encoding

(set-language-environment "Japanese")

(set-default-coding-systems my-default-coding-sytem)
(set-keyboard-coding-system my-default-coding-sytem)
(set-terminal-coding-system my-default-coding-sytem)

;; 使用するコーディングシステムの優先度を上げる。
(prefer-coding-system my-default-coding-sytem)

;; Gitの文字エンコーディング設定。
(eval-after-load "vc-git"
  '(dolist (var '(git-commits-coding-system ;obsolete
                  vc-git-commits-coding-system))
     (when (boundp var)
       (set var my-default-coding-sytem))))

;; MULE-UCS (supports Unicode and JIS X 0213 on Emacs 22).
(when (and (locate-library "mucs")
           (string< emacs-version "22"))
  (require 'un-define)
  (require 'jisx0213))

;; 改行の種類の別名を定義する。`C-x RET f` 等で使用できる。小文字でも可。
(define-coding-system-alias 'LF 'undecided-unix)
(define-coding-system-alias 'CRLF 'undecided-dos)
(define-coding-system-alias 'CR 'undecided-mac)

;; ファイル名の擴張子からその内容の文字エンコーディングを決定する設定。
(setq file-coding-system-alist
      (append '(("\\.utf-?8\\(?:'\\|\\.\\)" . utf-8)
                ("\\.jis\\(?:'\\|\\.\\)" . iso-2022-jp-2004)
                ("\\.sjis\\(?:'\\|\\.\\)" . shift_jis-2004)
                ("\\.cp932\\(?:'\\|\\.\\)" . cp932) ;Windows-31J
                ("\\.euc-?jp\\(?:'\\|\\.\\)" . euc-jisx0213))
              file-coding-system-alist))


;;; Input Methods

(defcustom my-japanese-input-use-small-kana
  t
  "ローマ字かな變換に於て促音や拗音に小さい假名を用ゐるか否か。こ
の値がnil の場合、ローマ字入力 \"tte\" が變換される假名は \"つて
\" となる。non-nil の場合 \"って\" となる。"
  :group 'my
  :type 'boolean)

(defadvice toggle-input-method (after my-switch-to-anthy-hiragana-mode activate)
  "`toggle-input-method' (C-\\) でAnthyが有效にされたとき、必ず
\「ひらがなモード」にする。"
  (if (string-equal default-input-method "japanese-anthy")
      (anthy-handle-key 10 (anthy-encode-key 10))))

(setq default-input-method "japanese-anthy")

(cond
 ;; Anthy.
 ((string-equal default-input-method "japanese-anthy")
  (setq load-path (append (list
                           (expand-file-name
                            "~/opt/seikananthy/share/emacs/site-lisp/anthy/")
                           (expand-file-name
                            "/usr/local/share/emacs/site-lisp/anthy"))
                          load-path))
  (setenv "LD_LIBRARY_PATH"
          (concat (expand-file-name "~/opt/seikananthy/lib/")
                  (if (getenv "LD_LIBRARY_PATH")
                      (concat ":" (getenv "LD_LIBRARY_PATH"))
                    "")))
  (load "anthy" t))
 ;; DDSKK.
 ((string-equal default-input-method "japanese-skk")
  (load "skk" t))
 ((string-equal default-input-method "japanese-egg-anthy")
  (setq input-method "japanese-egg-anthy")
  (set-language-info "Japanese" 'input-method "japanese-egg-anthy"))
 ;; FreeWnn.
 ((string-equal default-input-method "japanese-wnn")
  (load "wnn-setup" t))
 ;;
 (t nil))

(eval-after-load "skk"
  '(progn
     ;; More settings in the `~/.skk' file.
     (set-language-info "Japanese" 'input-method default-input-method)
     (setq auto-mode-alist
           (append '(("/\\.?skk-.*jisyo\\(\\.\\|\\'\\)" . skk-jisyo-edit-mode)
                     ("/SKK-JISYO\\." . skk-jisyo-edit-mode)
                     ("\\.skk\\'" . skk-jisyo-edit-mode))
                   auto-mode-alist))
     ;; in CSV mode buffer:
     (add-hook 'csv-mode-hook
       #'(lambda ()
           (set (make-local-variable 'skk-kuten-touten-alist) '((jp-en . ("。" . ","))))
           (set (make-local-variable 'skk-kutouten-type) 'jp-en)))))


;;; Anthy

(eval-after-load "anthy"
  '(progn
     (defun my-anthy-change-kana-map (roman kana)
       (anthy-change-hiragana-map roman (japanese-hiragana kana))
       (anthy-change-katakana-map roman (japanese-katakana kana)))))

;; ;; "Can't activate input method `japanese-anthy'" といふエラーが出る場合
;; ;; 參考: <http://www.tac.tsukuba.ac.jp/~hiromi/index.php?Guide%2Fanthy>
;; (load "leim-list")

;; Emacs23で應答が遲いバグの回避。
;; 參考: <http://sourceforge.jp/ticket/browse.php?group_id=14&tid=11263>
(eval-after-load "anthy"
  '(if (>= emacs-major-version 22)
       (setq anthy-accept-timeout 1)))

;; 變換候補の選擇キーを數字にする。
(eval-after-load "anthy"
  '(setq anthy-select-candidate-keybind
         '((0 . "1") (1 . "2") (2 . "3") (3 . "4") (4 . "5")
           (5 . "6") (6 . "7") (7 . "8") (8 . "9") (9 . "0"))))

;; `anthy-pre-edit-keymap' と他モードのキーマップの衝突回避
(eval-after-load "anthy"
  `(progn
     (anthy-deflocalvar anthy-preedit-previous-overriding-local-map
                        overriding-local-map
                        (concat "`anthy-enable-preedit-keymap' でキーマップを"
                                "プリエディット用のものに\n切替える直前の "
                                "`overriding-local-map' の値を記憶しておく"
                                "内部變數。"))
     ;;
     (defun anthy-enable-preedit-keymap ()
       "キーマップをプリエディットの存在する時のものに切替へる。"
       (setq anthy-preedit-previous-overriding-local-map overriding-local-map
             overriding-local-map anthy-preedit-keymap))
     ;;
     (defun anthy-disable-preedit-keymap ()
       "キーマップをプリエディットの存在しない時のものに切替へる。"
       (setq overriding-local-map anthy-preedit-previous-overriding-local-map)
       (anthy-update-mode-line))))

;;;; Anthy Kana Key Map

(eval-after-load "anthy"
  '(progn
     ;; 記號
     (my-anthy-change-kana-map "!" "!")
     (my-anthy-change-kana-map "#" "#")
     (my-anthy-change-kana-map "$" "$")
     (my-anthy-change-kana-map "%" "%")
     (my-anthy-change-kana-map "&" "&")
     (my-anthy-change-kana-map "'" "'")
     (my-anthy-change-kana-map "(" "(")
     (my-anthy-change-kana-map ")" ")")
     (my-anthy-change-kana-map "*" "*")
     (my-anthy-change-kana-map "/" "/")
     (my-anthy-change-kana-map ":" ":")
     (my-anthy-change-kana-map ";" ";")
     (my-anthy-change-kana-map "<" "<")
     (my-anthy-change-kana-map "=" "=")
     (my-anthy-change-kana-map ">" ">")
     (my-anthy-change-kana-map "?" "?")
     (my-anthy-change-kana-map "@" "@")
     (my-anthy-change-kana-map "\"" "\"")
     (my-anthy-change-kana-map "\\" "\\")
     (my-anthy-change-kana-map "^" "^")
     (my-anthy-change-kana-map "_" "_")
     (my-anthy-change-kana-map "`" "`")
     (my-anthy-change-kana-map "|" "|")
     ;; (my-anthy-change-kana-map "~" "~")

     ;; 大文字アルファベット。初期設定ではShiftキーを押しながらだと何も入
     ;; 力されないので。
     (my-anthy-change-kana-map "A" "A")
     (my-anthy-change-kana-map "B" "B")
     (my-anthy-change-kana-map "C" "C")
     (my-anthy-change-kana-map "D" "D")
     (my-anthy-change-kana-map "E" "E")
     (my-anthy-change-kana-map "F" "F")
     (my-anthy-change-kana-map "G" "G")
     (my-anthy-change-kana-map "H" "H")
     (my-anthy-change-kana-map "I" "I")
     (my-anthy-change-kana-map "J" "J")
     (my-anthy-change-kana-map "K" "K")
     (my-anthy-change-kana-map "L" "L")
     (my-anthy-change-kana-map "M" "M")
     (my-anthy-change-kana-map "N" "N")
     (my-anthy-change-kana-map "O" "O")
     (my-anthy-change-kana-map "P" "P")
     (my-anthy-change-kana-map "Q" "Q")
     (my-anthy-change-kana-map "R" "R")
     (my-anthy-change-kana-map "S" "S")
     (my-anthy-change-kana-map "T" "T")
     (my-anthy-change-kana-map "U" "U")
     (my-anthy-change-kana-map "V" "V")
     (my-anthy-change-kana-map "W" "W")
     (my-anthy-change-kana-map "X" "X")
     (my-anthy-change-kana-map "Y" "Y")
     (my-anthy-change-kana-map "Z" "Z")

     ;; 全角記號 / 全角英數字
     (setq anthy-wide-space " ") ;スペースバーを押下した時に插入される文字を半角空白に
     (my-anthy-change-kana-map "z " "　") ;"z " (zと空白) で全角空白
     (my-anthy-change-kana-map "z!" "！")
     (my-anthy-change-kana-map "z'" "’")
     (my-anthy-change-kana-map "z=" "＝")
     (my-anthy-change-kana-map "z?" "？")
     (my-anthy-change-kana-map "z[" "『")
     (my-anthy-change-kana-map "z]" "』")
     (my-anthy-change-kana-map "{" "『")
     (my-anthy-change-kana-map "}" "』")

     ;; う゛
     ;; U+3046 HIRAGANA LETTER U
     ;; U+309B KATAKANA-HIRAGANA VOICED SOUND MARK
     (my-anthy-change-kana-map "va" "う゛ぁ")
     (my-anthy-change-kana-map "vi" "う゛ぃ")
     (my-anthy-change-kana-map "vu" "う゛")
     (my-anthy-change-kana-map "ve" "う゛ぇ")
     (my-anthy-change-kana-map "vo" "う゛ぉ")
     (my-anthy-change-kana-map "vyu" "う゛ゅ")

     ;; ;; ゔ
     ;; ;; U+3094 HIRAGANA LETTER VU
     ;; ;; MEMO: 辭書が未對應なので現在は使用してゐない。
     ;; (my-anthy-change-kana-map "va" "ゔぁ")
     ;; (my-anthy-change-kana-map "vi" "ゔぃ")
     ;; (my-anthy-change-kana-map "vu" "ゔ")
     ;; (my-anthy-change-kana-map "ve" "ゔぇ")
     ;; (my-anthy-change-kana-map "vo" "ゔぉ")
     ;; (my-anthy-change-kana-map "vyu" "ゔゅ")

     ;; 正かなづかひ用のローマ字かな設定。
     (my-anthy-change-kana-map "wa" "わ")
     (my-anthy-change-kana-map "we" "ゑ")
     (my-anthy-change-kana-map "wu" "う")
     (my-anthy-change-kana-map "wi" "ゐ")
     (my-anthy-change-kana-map "wo" "を")
     (my-anthy-change-kana-map "kwa" "くわ")
     (my-anthy-change-kana-map "gwa" "ぐわ")
     (my-anthy-change-kana-map "kwe" "くゑ")
     (my-anthy-change-kana-map "gwe" "ぐゑ")

     ;; 撥音・拗音・促音に大書きのかなをもちゐる設定。
     (my-anthy-change-kana-map "kka" "つか")
     (my-anthy-change-kana-map "kki" "つき")
     (my-anthy-change-kana-map "kku" "つく")
     (my-anthy-change-kana-map "kke" "つけ")
     (my-anthy-change-kana-map "kko" "つこ")
     ;;
     (my-anthy-change-kana-map "tta" "つた")
     (my-anthy-change-kana-map "tti" "つち")
     (my-anthy-change-kana-map "ttu" "つつ")
     (my-anthy-change-kana-map "tte" "つて")
     (my-anthy-change-kana-map "tto" "つと")
     ;;
     (my-anthy-change-kana-map "tya" "ちや")
     (my-anthy-change-kana-map "tyu" "ちゆ")
     (my-anthy-change-kana-map "tyo" "ちよ")
     (my-anthy-change-kana-map "cha" "ちや")
     (my-anthy-change-kana-map "chu" "ちゆ")
     (my-anthy-change-kana-map "cho" "ちよ")
     ;;
     (my-anthy-change-kana-map "ttya" "つちや")
     (my-anthy-change-kana-map "ttyu" "つちゆ")
     (my-anthy-change-kana-map "ttyo" "つちよ")
     (my-anthy-change-kana-map "ccha" "つちや")
     (my-anthy-change-kana-map "cchu" "つちゆ")
     (my-anthy-change-kana-map "ccho" "つちよ")
     ;;
     (my-anthy-change-kana-map "kkya" "つきや")
     (my-anthy-change-kana-map "kkyu" "つきゆ")
     (my-anthy-change-kana-map "kkyo" "つきよ")
     (my-anthy-change-kana-map "kkwa" "つくわ")

     ;; その他のローマ字かな設定。
     (my-anthy-change-kana-map "mm" "む")))


;;; Anthy ユーザ辭書編輯モード

(when nil
  (require 'anthy-dict-mode)
  (add-to-list 'auto-mode-alist '("\\`private-dic\\.src\\'" . anthy-dict-mode))
  (add-hook 'anthy-dict-mode-hook
    #'(lambda ()
        (setq indent-tabs-mode t)
        (setq tab-width 8))))

(defun my-escape-regexp (re-src)
  (regexp-opt (list current-line)))

(defadvice save-buffer (before sort-anthy-user-dict activate)
  "Anthyの個人辞書を保存 C-x C-s (save-buffer) 時にソート。"
  (save-restriction
    (save-match-data
      (when (string-match "/private_words_default\\'"
                          (or (buffer-file-name) ""))
        (widen)
        ;; 連続する空白を一つにまとめる。
        (save-excursion
          (goto-char (point-min))
          (while (re-search-forward "[ \t][ \t]+" nil t)
            (replace-match " ")))
        (let ((current-line (buffer-substring-no-properties (point-at-bol) (point-at-eol))))
          ;; 漢字を「正字体」に變換する。
          (seijiseikana-seiji-region (point-min) (point-max))
          (sort-lines nil (point-min) (point-max))
          ;; バッファ先頭の空白類を削除する。
          (save-excursion
            (goto-char (point-min))
            (while (or (= (char-after) ?\ ) (= (char-after) ?\t)
                       (= (char-after) ?\n) (= (char-after) ?\r))
              (delete-char 1)))
          ;; バッファ末尾の空白類を削除し、末尾に改行を一つだけ加へる。
          (save-excursion
            (goto-char (point-max))
            (while (or (= (char-before) ?\ ) (= (char-before) ?\t)
                       (= (char-before) ?\n) (= (char-before) ?\r))
              (delete-char -1))
            ;; Add newline.
            (goto-char (point-max))
            (insert "\n"))
          ;; 重複行削除。
          (uniq-region (point-min) (point-max))
          ;; ソート前にポイントしていた行に移動する。
          ;; FIXME: 正字變換されてゐると見附けられない。
          (goto-char (point-min))
          (re-search-forward (concat "^" (my-escape-regexp current-line) "$")
                             nil t))))))


;;; Anthy Depgraph Mode

(define-derived-mode anthy-depgraph-mode fundamental-mode "Depgraph"
  "Major mode for depgraph files in Anthy source tree.

\\{anthy-depgraph-mode}"
  (set-syntax-table (let ((table (copy-syntax-table (syntax-table))))
                      (modify-syntax-entry ?\" "\"" table)
                      (modify-syntax-entry ?\- "_"  table)
                      (modify-syntax-entry ?\_ "_"  table)
                      (modify-syntax-entry ?\# "<"  table)
                      (modify-syntax-entry ?\n ">"  table)
                      (modify-syntax-entry ?\\ "\\" table)
                      table))
  ;; (set (make-local-variable (kill-local-variable 'font-lock-defaults))
  ;;      '(privoxy-font-lock-keywords nil t))
  (setq comment-start "#")
  (setq comment-end "")
  (setq comment-end-skip "[ \t]*\\(\\s>\\|\n\\)")
  (font-lock-fontify-buffer))

(add-to-list 'auto-mode-alist
  (cons (concat "/depgraph/"
                "\\(?:.+?\\."
                (regexp-opt '("table"
                                    "depword"
                                    "depdef") ;alt-depgraph
                                  t)
                "\\'"
                "\\|indepword\\.txt\\'\\)")
        'conf-mode))


;;; Global Key Bindings

;; Back Space key
(keyboard-translate ?\C-h ?\C-?)

(global-set-key "\C-h" #'backward-delete-char-untabify)

;; Help and Describes
(global-set-key "\C-ch" #'help-command)

;; Commentify / Uncommentify

(if (fboundp 'comment-or-uncomment-region)
    (global-set-key "\C-c;" #'comment-or-uncomment-region)
  (global-set-key "\C-c:" #'uncomment-region)
  (global-set-key "\C-c;" #'comment-region))

;; ローカルキーマップで `Alt + Tab' を束縛してゐるコマンド(たぶん
;; `completion-at-point' や `lisp-complete-symbol' などの補完函數)を
;; `Shift + Tab' で呼べるやうにする。
;;
;; FIXME: Emacs Lispモードでは期待どほりに動くが、LispモードSLIMEでは動かな
;; い。
(global-set-key [(shift tab)]
                #'(lambda ()
                    (interactive)
                    (funcall (cdr (assoc 9 (assoc 27 (current-local-map)))))))

;; Enable `delete-region'
(global-set-key [(shift delete)] #'delete-region)
(put 'delete-region 'disabled t)

;; Disable `transpose-chars'
(global-unset-key "\C-t")

;; Disable `tmm-menubar'.
(global-unset-key "\M-`")

;;
(global-set-key "\M-n" #'forward-paragraph)
(global-set-key "\M-p" #'backward-paragraph)
(global-set-key [(ctrl v)] #'scroll-up)
(global-set-key [(shift ctrl v)] #'scroll-down)
;;(global-set-key "\t" 'self-insert-command)
;;(global-set-key [insert] 'overwrite-mode)


;;; JavaScript/ECMAScript

(eval-after-load "js"
  '(setq js-indent-level 2))

(defun-if-undefined insert-user-script-template ()
  (insert (concat "// Created: " (iso-8601-w3c-dtf-string) "\n"  "\n"))
  (insert-file-contents "~/Templates/gm_script_template.user.js")
  (progn
    (goto-char (point-min))
    (end-of-line)
    (insert " -*- coding: utf-8 -*-"))
  (re-search-forward "/descendant::node()" nil t)
  (end-of-line))


;;; Fundamental Mode

(defcustom fundamental-mode-hook
  nil
  "Hook run when entering Fundamental mode."
  :type 'hook
  :group 'my)

(add-hook 'fundamental-mode-hook
  #'(lambda ()
      (set (make-local-variable 'adaptive-fill-mode) nil)))

(defadvice normal-mode (after fundamental-mode-hook)
  (if (string= "Fundamental" (or (and (stringp mode-name) mode-name) ""))
      (run-hooks 'fundamental-mode-hook)))

(ad-activate #'normal-mode)


;;; List Buffers

;; MEMO: 次のアドヴァイスは、"C-x C-b" から "C-x b" で照準を移したとき混乱
;; しがちなのでやめた。2012-04-23T08:58:57+09:00
;;
;; (defadvice list-buffers (after focus-list-buffers-window activate)
;;   "\"C-x C-b\" (list-buffers) で表示したウインドウに照準を合せる。"
;;   (other-window 1))


;;; Outline Mode

(require 'outline)

(add-hook 'outline-mode-hook
  #'(lambda ()
      (setq tab-width 4)
      (setq truncate-lines t)))

(add-hook 'outline-minor-mode-hook
  #'(lambda ()
      (local-set-key "\C-c\C-o" outline-mode-prefix-map)))

;;;; `outline-minor-mode' Key Map

;; Based on <http://www.emacswiki.org/emacs/OutlineMinorMode>.

(define-prefix-command 'cm-map nil "Outline")
;; Hide
(define-key cm-map "q" 'hide-sublevels)                    ;Hide everything but the top-level headings
(define-key cm-map "t" 'hide-body)                         ;Hide everything but headings (all body lines)
(define-key cm-map "o" 'hide-other)                        ;Hide other branches
(define-key cm-map "c" 'hide-entry)                        ;Hide this entry's body
(define-key cm-map "l" 'hide-leaves)                       ;Hide body lines in this entry and sub-entries
(define-key cm-map "d" 'hide-subtree)                      ;Hide everything in this entry and sub-entries
;; Show
(define-key cm-map "a" 'show-all)                          ;Show (expand) everything
(define-key cm-map "e" 'show-entry)                        ;Show this heading's body
(define-key cm-map "i" 'show-children)                     ;Show this heading's immediate child sub-headings
(define-key cm-map "k" 'show-branches)                     ;Show all sub-headings under this heading
(define-key cm-map "s" 'show-subtree)                      ;Show (expand) everything in this heading & below
;; Move
(define-key cm-map "u" 'outline-up-heading)                ;Up
(define-key cm-map "n" 'outline-next-visible-heading)      ;Next
(define-key cm-map "p" 'outline-previous-visible-heading)  ;Previous
(define-key cm-map "f" 'outline-forward-same-level)        ;Forward - same level
(define-key cm-map "b" 'outline-backward-same-level)       ;Backward - same level
;;
(global-set-key "\C-co" cm-map)


;;; SGML, XML

(defvar my-html4-tag-names
  ;; <http://www.w3.org/TR/html4/index/elements.html>.
  '("a" "abbr" "acronym" "address" "applet" "area" "b" "base" "basefont" "bdo"
    "big" "blockquote" "body" "br" "button" "caption" "center" "cite" "code"
    "col" "colgroup" "dd" "del" "dfn" "dir" "div" "dl" "dt" "em" "fieldset"
    "font" "form" "frame" "frameset" "h1" "h2" "h3" "h4" "h5" "h6" "head" "hr"
    "html" "i" "iframe" "img" "input" "ins" "isindex" "kbd" "label" "legend"
    "li" "link" "map" "menu" "meta" "noframes" "noscript" "object" "ol"
    "optgroup" "option" "p" "param" "pre" "q" "s" "samp" "script" "select"
    "small" "span" "strike" "strong" "style" "sub" "sup" "table" "tbody" "td"
    "textarea" "tfoot" "th" "thead" "title" "tr" "tt" "u" "ul" "var"))

(defvar my-html4-attribute-names
  ;; <http://www.w3.org/TR/html4/index/attributes.html>.
  '("abbr" "accept-charset" "accept" "accesskey" "action" "align" "alink" "alt"
    "archive" "axis" "background" "bgcolor" "border" "cellpadding" "cellspacing"
    "char" "charoff" "charset" "checked" "cite" "class" "classid" "clear" "code"
    "codebase" "codetype" "color" "cols" "colspan" "compact" "content" "coords"
    "data" "datetime" "declare" "defer" "dir" "disabled" "enctype" "face" "for"
    "frame" "frameborder" "headers" "height" "href" "hreflang" "hspace"
    "http-equiv" "id" "ismap" "label" "lang" "language" "link" "longdesc"
    "marginheight" "marginwidth" "maxlength" "media" "method" "multiple" "name"
    "nohref" "noresize" "noshade" "nowrap" "object" "onblur" "onchange"
    "onclick" "ondblclick" "onfocus" "onkeydown" "onkeypress" "onkeyup" "onload"
    "onmousedown" "onmousemove" "onmouseout" "onmouseover" "onmouseup" "onreset"
    "onselect" "onsubmit" "onunload" "profile" "prompt" "readonly" "rel" "rev"
    "rows" "rowspan" "rules" "scheme" "scope" "scrolling" "selected" "shape"
    "size" "span" "src" "standby" "start" "style" "summary" "tabindex" "target"
    "text" "title" "type" "usemap" "valign" "value" "valuetype" "version"
    "vlink" "vspace" "width"))

(defvar my-sgml-names-re
  (regexp-opt (append my-html4-tag-names
                      my-html4-attribute-names)))

;; 作りかけ。といふか使つてゐない(2012-06-13)。
(defun my-sgml-name-markup-ja-region (start end)
  "\
リージョン内の

    a div element.

といふテキストを

    a <code class=\"sgml\">div</code> element

へ置換する。"
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region start end)
      (goto-char (point-min))
      (while (re-search-forward (concat "\\(\\<" my-sgml-names-re "\\>\\)"
                                        "\\<"
                                        (regexp-opt '("要素"
                                                      "エレメント"
                                                      "element"
                                                      "屬性"
                                                      "属性"
                                                      "アトリビュート"
                                                      "attribute"))
                                        "\\>")
                                nil t)
        (replace-match "<code class=\"sgml\">\\1</span>" nil nil nil 1)))))

(eval-after-load "nxml-mode"
  ;; "</" を入力したとき終了タグを補完するか否か(初期値: nil):
  '(progn
     (setq nxml-slash-auto-complete-flag t)))

(eval-after-load "psgml"
  '(progn
     (setq sgml-indent-step 2)
     (setq sgml-set-face t)
     (setq sgml-auto-activate-dtd t)
     (setq sgml-indent-data t)))

(setq sgml-basic-offset 2)

(add-to-list 'magic-mode-alist '("\\`[ \t]*<\\?xml" . xml-mode))
(add-to-list 'auto-mode-alist '("\\.html?" . html-mode))

(add-hook 'sgml-mode-hook
  #'(lambda ()
      (setq my-delete-trailing-whitespace-mode t)
      (setq sgml-live-element-indicator t) ;PSGML
      (set (make-local-variable 'my-delete-trailing-whitespace-mode) t)
      (set (make-local-variable 'line-move-visual) t)
      (setq auto-fill-mode nil)
      (setq line-spacing 0)
      (setq tab-width sgml-basic-offset)
      (setq truncate-lines nil)))

(add-hook 'xml-mode-hook
  #'(lambda ()
      (setq my-delete-trailing-whitespace-mode t)
      (setq sgml-live-element-indicator t) ;PSGML
      (set (make-local-variable 'my-delete-trailing-whitespace-mode) t)
      (setq auto-fill-mode nil)))


;;; HTML

(add-hook 'html-mode-hook
  #'(lambda ()
      (setq tab-width sgml-basic-offset)
      (setq truncate-lines nil)
      ;; disable `html-autoview-mode':
      (local-unset-key "\C-c\C-s")))

;;;; `sgml-close-tag' でインデントしない

;; Created: 2011-09-24T22:15:59+09:00

(defadvice sgml-close-tag (around no-indent)
  (flet ((indent-according-to-mode () nil))
    ad-do-it))

;;;; Does not indent formatted content (PRE element) on `html-mode'

;; Description(ja): HTMLモードのPRE要素内容はインデントしないやうにする。
;; Copyright: © 2011  MORIYAMA Hiroshi
;; License: GPLv3 or leter
;; 2011-11-06 21:51:50 -0800: Published on Gist <https://gist.github.com/1344252>

(unless (fboundp 'within-current-line)
  (defmacro within-current-line (&rest body)
    `(save-excursion
       (save-restriction
         (narrow-to-region (point-at-bol) (point-at-eol))
         ,@body))))

(put 'within-current-line 'lisp-indent-hook 'defun)
(font-lock-add-keywords 'emacs-lisp-mode
  '(("(\\(within-current-line\\)\\>" . (1 font-lock-keyword-face))))

(defun my-sgml-tag-name-is (tag-name tag)
  (if (and tag
           (or (eql (sgml-tag-type tag) 'open)
               (eql (sgml-tag-type tag) 'close)))
      (let ((normalized-tag-name (upcase (sgml-tag-name tag))))
        (if (string-equal normalized-tag-name tag-name)
            normalized-tag-name))))

(defun my-sgml-point-inside-element-p (element-name)
  (let ((result nil)
        (element-name (upcase element-name)))
    (save-excursion
      (save-restriction
        (widen)
        (let (context)
          (while (setq context (sgml-get-context))
            (if (member element-name (mapcar (lambda (tag)
                                               (my-sgml-tag-name-is element-name tag))
                                             context))
                (setq result context)))
          (if result t))))))

(defun my-sgml-name-of-last-close-tag ()
  (within-current-line
    (let ((end-tag (condition-case nil (sgml-parse-tag-backward) (error nil))))
      (if end-tag
          end-tag))))

(defadvice sgml-indent-line (around my-html-preformatted-text-not-indent activate)
  ;; HTMLモードであれば
  (if (derived-mode-p 'html-mode)
      ;; PRE要素の外にゐるかどうか確認し
      (if (and (not (my-sgml-point-inside-element-p "PRE"))
               (not (my-sgml-tag-name-is "PRE" (my-sgml-name-of-last-close-tag))))
          ;; PRE要素の外にゐたならば `sgml-indent-line' を實行する。
          ad-do-it)
    ;; HTMLモードでなければ常に實行する。
    ad-do-it))

;;;; リージョンをタグ附けする

(defun my-html-insert-tag (tag-name &optional end-tag-p)
  (let ((tag (concat "<"
                     (if end-tag-p "/")
                     (if (stringp tag-name)
                         tag-name
                       (symbol-name tag-name))
                     ">")))
    (insert tag)
    tag))

(defun my-html-markup-region (start end tag-name)
  (let (inserted-tags)
    (goto-char end)
    (push (my-html-insert-tag tag-name 'end-tag) inserted-tags)
    (goto-char start)
    (push (my-html-insert-tag tag-name) inserted-tags)
    (let ((inserted-length (length (apply #'concat inserted-tags))))
      (goto-char (+ end inserted-length))
      inserted-length)))

(defun my-html-markup-code-region (start end)
  (interactive "r")
  (my-html-markup-region start end "code"))

(add-hook 'html-mode-hook
  #'(lambda ()
      (local-set-key "\C-c\C-tc" #'my-html-markup-code-region)))


;;; Escape Not Encodable Characters

;; Copyright: © 2012 MORIYAMA Hiroshi
;; License: GPLv3 or later
;; Version: 0.1.1
;; ChangeLog:
;;    2011-10-13 version 0.1.1
;;      - 動かないバグを修正。
;;      - docstring内の字下げを微修正。
;;    2011-10-11 version 0.1.0
;;      - 日記で公開。"2011-10-11 - HM weblog"
;;       <http://d.hatena.ne.jp/mhrs/20111011>

;; - インタラクティヴ函數にする。プロンプトでコーディングの指定を受附ける。

;; - 數値文字參照變換のunescape版裝する。(必要がないのでやる氣なし。)

;; - 第三引數codingを省略可能にする。省略した場合何を既定値にするかは、たぶんカ
;;   スタマイズ變數で指定させて、その既定値はiso-8859-1あたりか。インタラクティ
;;   ヴ呼出しの場合は前回の指定を再利用するといふのはどうか。

;; - 高速化。現状はとても遲い。

(defun my-find-coding-systems-and-aliases (char-or-string)
  "函數 `find-coding-systems-string' の返値のリストに、その各要素
の別名を追加したリストを返す。"
  (apply #'append
         (mapcar #'(lambda (coding) (coding-system-aliases coding))
                 (find-coding-systems-string
                  (or (and (stringp char-or-string) char-or-string)
                      (char-to-string char-or-string))))))

(defun my-replace-not-encodable-characters-region (start end coding conversion-function)
  "第三引數 CODING で符號化できない文字を置換する。

バッファ内位置 START から END の範圍内の各文字について、第三引數
CODING のコーディングシステムで符號化できるか否か調べ、符號化でき
なければその文字を CONVERSION-FUNCTION の返値に置換へる。

第四引數 CONVERSION-FUNCTION は、文字を一つ引數に取り文字列を返す
函數でなければならない。

Example:

;; バッファ内にあるEUC-JPで符號化できない文字を、SGMLの數値文
;; 字參照に變換する。
\(my-replace-not-encodable-characters-region (point-min) (point-max) 'euc-jp
                                            #'(lambda (char)
                                              (format \"&#x%x;\" char char)))"
  (save-excursion
    (save-restriction
      (narrow-to-region start end)
      (goto-char (point-min))
      (while (< (point) (point-max))
        (let* ((char (following-char))
               (charsets (my-find-coding-systems-and-aliases char)))
          ;; ポイントから見て次の位置の文字は指定の符號化方式で符號化できるか。
          (if (or (eql 'undecided (car charsets)) ;シングルバイト文字
                  (member coding charsets))
              ;; 符號化できるので何もせず次の文字へ。
              (forward-char 1)
            ;; 符號化できないので conversion-funciton の返値と置換へる。
            (delete-char 1)
            (insert (funcall conversion-function char))))))))

;;;; Numeric Character Reference

(defun my-escape-to-numeric-character-references-region (start end coding)
  "バッファ内位置 START から END の範圍内の各文字について、第三引
數 CODING のコーディングシステムで符號化できるか否か調べ、符號化で
きなければその文字をSGMLの「數値文字參照」に置換する。"
  (my-replace-not-encodable-characters-region start end coding
                                              #'(lambda (char)
                                                  (format "&#x%x;" char char))))
;;;; Unicode Escape

(defun my-unicode-escape-region (start end)
  (interactive "r")
  (my-replace-not-encodable-characters-region start end
                                              'iso-8859-1
                                              #'(lambda (char)
                                                  (format (if (< char #x10000)
                                                              "\\u%04x"
                                                            "\\u{%x}")
                                                          char char))))


;;; html-tidy.el --- HTML Tidy Interfaces for Emacs

(add-to-load-path (concat (user-emacs-directory) "html-tidy"))

(require 'html-tidy)


;;; CSS (Cascading Style Sheets)

(add-hook 'css-mode-hook
  #'(lambda ()
      (setq css-indent-offset 2)))


;;; Unfill Paragraph

;; <http://emacswiki.org/emacs/UnfillParagraph>

;; (require 'unfill-paragraph)
;; (define-key global-map "\M-Q" 'unfill-paragraph)


;;; Fonts

;; MEMO: フォントはフレームの幅や高さに影響するのでフレームパラメータよりも先に
;; 設定する。さうすることで起動中にフレームサイズが變更される回數を最小限に抑へ
;; る。

;;;; 參考

;; - "Emacs特集の未收録その3 「フォント設定を極める。1文字ごとに指定できるのは
;;   (たぶん) Emacsだけ!」。 - 日々、とんは語る。"
;;   <http://d.hatena.ne.jp/tomoya/20100828/1282948135>

;; - "Cocoa Emacs のフォント設定について - 瀬戸亮平"
;;   <http://d.hatena.ne.jp/setoryohei/20110117/1295336454>

;;;; Examples

;; いろはにほへ
;; abcdefghijkl
;; 漢字感じ幹事
;; ｲﾛﾊﾆﾎﾍﾄﾁﾘﾇﾙｦ

;;;;; ASCII

;; !"#$%&'()*+,-./0123456789:;<=>?@
;; ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`
;; abcdefghijklmnopqrstuvwxyz{|}~

;;;;; C1 Controls and Latin-1 Supplement

;; Range: 0080–00FF

;; ¡¢£¤¥¦§¨©ª«¬⬚®¯ ±²³´µ¶·¸¹º»¼½¾¿ ÁÂÃÄÅÆÇÈÉÊËÌÍÎÏ ÑÒÓÔÕÖ×ØÙÚÛÜÝÞß
;; áâãäåæçèéêëìíîï ñòóôõö÷øùúûüýþÿ

;;;;; Greek and Coptic

;; ΑΒΓΔΕϜϚΖΗ
;; αβγδεϝϛζη

;;;;; Greek Extended

;; ἂἒἢἲὂὒὢὲᾂᾒᾢᾲῂῒῢῲ
;; ἉἙἩἹὉὙὩᾉᾙᾩᾹΈῙῩΌ

;;;;; Ancient Greek Numbers

;; Range: 10140–1018F

;; 𐅀𐅁𐅂𐅃𐅄𐅅𐅐𐅑 𐅒𐅓𐅔𐅠𐅡𐅢𐅰𐆀𐅱 𐅲𐅣𐅳𐅤𐅴𐅕𐅥𐅵𐆁 𐆂𐆃𐆄𐆅𐅆𐅖𐅦𐅶
;; 𐆆𐅇𐅈𐅗𐅘𐅉𐅙𐅊 𐅋𐅌𐅍𐅎𐅏𐅚 𐅛𐅜𐅝𐅞𐅟𐅧𐅨 𐅷𐆇𐅸𐅩𐅹𐅪𐅺 𐆈𐆉𐆊𐅫𐅻𐅬𐅼
;; 𐅭𐅽𐅮𐅾𐅯𐅿

;;;;; Hiragana and Katakana

;; あめつちほしそら やまかはみねたに
;; くもきりむろこけ ひといぬうへすゑ
;; ゆわさるおふせよ えの𛀁をなれゐて んゝゞゟ

;; アメツチホシソラ ヤマカハミネタニ
;; クモキリムロコケ ヒトイヌウヘスヱ
;; ユワサルオフセヨ 𛀀ノエヲナレヰテ ンヽヾ・ヿ

;;;;; Mahjong Tiles

;; 🀀🀁🀂🀃🀄🀅🀆🀇🀈🀉🀊🀋🀌🀍🀎🀏🀐🀑🀒🀓🀔🀕🀖🀗🀘🀙🀚🀛🀜🀝🀞🀟🀠🀡🀢🀣🀤🀥🀦🀧🀨🀪🀫

;;;;; Others

;;;; Code:

(when (display-multi-font-p)
  (let ((fs (create-fontset-from-ascii-font "Ricty Discord 16")))
    (set-fontset-font fs 'ascii (font-spec :name "Inconsolata"))
    (set-fontset-font fs 'latin-jisx0201 (font-spec :name "Ricty Discord"))
    (set-fontset-font fs 'katakana-jisx0201 (font-spec :name "TakaoGothic"))
    (set-fontset-font fs 'japanese-jisx0208 (font-spec :name "TakaoGothic"))
    (set-fontset-font fs 'japanese-jisx0212 (font-spec :name "TakaoGothic"))
    (set-fontset-font fs 'japanese-jisx0213.2004-1 (font-spec :name "TakaoGothic"))
    (set-fontset-font fs 'japanese-jisx0213-2 (font-spec :name "TakaoGothic"))
    ;;
    (set-fontset-font fs '(#x3040 . #x309F) (font-spec :name "M+ 1m" :weight 'light)) ;Hiragana
    (set-fontset-font fs '(#x30A0 . #x30FF) (font-spec :name "M+ 1m" :weight 'light)) ;Katakana
    (set-fontset-font fs '(#x31F0 . #x31FF) (font-spec :name "M+ 1m")) ;Katakana Phonetic Extensions
    (set-fontset-font fs '(#x1B000 . #x1B001) (font-spec :name "AmetsuchiGothic")) ;Kana Supplement
    (set-fontset-font fs '(#x4E00 . #x9FBF) (font-spec :name "VL Gothic")) ;CJK Unified Ideographs
    (set-fontset-font fs '(#x0370 . #x03FF) (font-spec :name "Inconsolata")) ;Greek and Coptic
    (set-fontset-font fs '(#x1F00 . #x1FFF) (font-spec :name "Inconsolata")) ;Greek Extended
    (set-fontset-font fs '(#x10140 . #x1018F) (font-spec :name "Aroania")) ;Ancient Greek Numbers
    (set-fontset-font fs '(#x1F000 . #x1F02F) (font-spec :name "Symbola" :size 22)) ;Mahjong Tiles
    ;;
    (set-fontset-font fs '#x2013 (font-spec :name "Ricty")) ;EN DASH "–"
    ;;
    (set-default-font fs)
    (add-to-list 'default-frame-alist (cons 'font fs))
    fs))


;;; スクリプトを保存するとき自動的に chmod +x する

;; <http://www.namazu.org/~tsuchiya/elisp/chmod.el>
(load "chmod.el" t)


;;; デフォルトでは「無效」のコマンドを利用可能に

(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'scroll-left 'disabled nil)
(put 'dired-find-alternate-file 'disabled nil)
(put 'narrow-to-page 'disabled nil)
(put 'delete-region 'disabled nil)


;;; Compatibility for Emacs 21

;; (unless (fboundp 'syntax-ppss)
;;   (defun syntax-ppss (&optional pos)
;;     (parse-partial-sexp (point-min) (or pos (point)))))

;; (unless (fboundp 'syntax-ppss-context)
;;   ;; Copied from lisp/emacs-lisp/syntax.el in GNU Emacs 22.3:
;;   (defsubst syntax-ppss-context (ppss)
;;     (cond
;;      ((nth 3 ppss) 'string)
;;      ((nth 4 ppss) 'comment)
;;      (t nil))))


;;; Minor Modes

(auto-compression-mode 1)    ;壓縮ファイルの編輯機能
(auto-image-file-mode 1)     ;?
(blink-cursor-mode -1)       ;カーソルを點滅させない
(column-number-mode 1)       ;ポイント位置の桁數表示(モード行)
(line-number-mode 1)         ;ポイント位置の行數表示(モード行)
(show-paren-mode 1)          ;對應する括弧の強調表示
(temp-buffer-resize-mode -1) ;一時バッファの高さを必要最小限の大きさにリサイズするか
(transient-mark-mode -1)     ;マークしたリージョンの強調

;; ;; These are set up in `default-frame-alist' or file ~/.Xresources:
;; (menu-bar-mode 0)
;; (tool-bar-mode 0)
;; (scroll-bar-mode -1)
;; (set-scroll-bar-mode nil) 'left or 'right or 'nil or nil.
;; (set-foreground-color "gray80")
;; (set-background-color "gray4")


;;; Faces

(require 'hm-faces)


;;; Minibuffer

;; ミニバッファの入力履歴を `C-p', `C-n' で辿れるやうにする。
;; M-x prompt (`M-x').
(define-key minibuffer-local-must-match-map "\C-p" 'previous-history-element)
(define-key minibuffer-local-must-match-map "\C-n" 'next-history-element)
;; Find file promopt (`C-xC-f').
(define-key minibuffer-local-completion-map "\C-p" 'previous-history-element)
(define-key minibuffer-local-completion-map "\C-n" 'next-history-element)
;; Eval prompt (`M-:').
(define-key minibuffer-local-map "\C-p" 'previous-history-element)
(define-key minibuffer-local-map "\C-n" 'next-history-element)

(add-hook 'minibuffer-setup-hook
  #'(lambda()
      (setq truncate-lines nil)))


;;; Probe Shell Command

(defun-if-undefined probe-shell-command (command-name)
  (find-if #'(lambda (filename) (file-exists-p filename))
           (mapcar #'(lambda (path) (concat path "/" command-name))
                   (hm-string-split (getenv "PATH") ":"))))


;;; Filter Region by Shell Command

(defun my-filter-region (command)
  ;; Author: MORIYAMA Hiroshi
  ;; Created: 2007-07-25
  (interactive "sFilter command: ")
  (let ((cmdname (car (split-string command "[ \t]")))
        (cmdopt (mapconcat 'identity (cdr (split-string command "[ \t]")) " "))
        (temp-buffer (generate-new-buffer " *my-filter-region*"))
        (result))
    (cond
     ((string= cmdopt "")
      (setq result (call-process-region (point) (mark) cmdname nil temp-buffer t)))
     (t
      (setq result (call-process-region (point) (mark) cmdname nil temp-buffer t cmdopt))))
    (if (zerop result)
        (progn
          (delete-region (point) (mark))
          (insert-buffer-substring temp-buffer))
      (with-output-to-temp-buffer (concat " *my-filter-region error <" cmdname " " cmdopt ">*")
        (let (start end)
          (save-excursion
            (set-buffer temp-buffer)
            (setq start (point-min)
                  end (point-max)))
          (set-buffer standard-output)
          (insert-buffer-substring temp-buffer start end)
          (switch-to-buffer-other-window standard-output))))
    (kill-buffer temp-buffer)))

(global-set-key "\C-c|" #'my-filter-region)


;;; Forward/Backward Page Commands

;; Created: 2008-09-29T23:58:15+09:00
;; TODO: 見出しレヴェルの決打ちをやめて引数に取れるやうにする。
;; FIXME: といふか今は動いてゐないので動くやうにする。

(defun my-forward-section-header (arg)
  (interactive "p")
  (if (looking-at "^;;; ")
      (forward-line 1))
  (re-search-forward "^;;; " nil t)
  (beginning-of-line))

(defun my-backward-section-header (arg)
  (interactive "p")
  (re-search-backward "^;;; " nil t))

(defun my-narrow-to-emacs-lisp-code-block ()
  (widen)
  (let ((beg (save-excursion
               (beginning-of-line)
               (or (if (looking-at "^;;; ") (point))
                   (re-search-backward "^;;; " nil t)
                   (point-min))))
        (end (save-excursion
               (forward-line)
               (if (re-search-forward "^;;; " nil t)
                   (- (point) (length (match-string 0)))
                 (point-max)))))
    (narrow-to-region beg end)))

(defun my-backward-page-and-narrowing ()
  (interactive)
  (widen)
  (backward-page 2)
  (my-narrow-to-page-or-emacs-lisp-code-block)
  (goto-char (point-min)))

(defun my-forward-page-and-narrowing ()
  (interactive)
  (goto-char (point-max))
  (widen)
  (if (looking-at "\f")
      ;; ポイントが ^L の上にある時に forward-page するとページを一つ
      ;; 餘分に飛ばしてしまふので一字ずらす:
      (forward-char 1)
    (forward-page 1))
  (my-narrow-to-page-or-emacs-lisp-code-block)
  (goto-char (point-min)))

;; TODO: 端末でエスケープシーケンスを喰つてしまふので tty や コマンド
;; `emacs -nw' で起動した場合は次の設定を有效にしないやうにする。
(global-set-key "\M-[" #'my-backward-page-and-narrowing)
(global-set-key "\M-]" #'my-forward-page-and-narrowing)


;;; Diff

(setq diff-command "/usr/bin/diff")
(setq diff-switches "-urNb")
(setq diff-default-read-only t)


;;; Compile Mode

(global-set-key "\C-c\C-c" #'compile)


;;; C Language

(load "ruby-style" t)

;; C preprocessor directives hide/show.
(autoload 'hide-ifdef-mode "hideif" nil t)

(defun my-guess-c-coding-style ()
  "カレントバッファの内容がC系の言語で書かれたコードであると見做し
てそのコーディングスタイルを推測し、スタイル名を文字列で返す。

現在 `my-guess-c-coding-style' が推測出來るスタイルは \"gnu\" のみ
である。既知のスタイルを推測できなかった場合は文字列 \"user\" を返
す。"
  (save-restriction
    (widen)
    (cond
     ((save-excursion
        (goto-char (point-min))
        (and (eql major-mode 'c-mode)
             (or (re-search-forward "This file is part of GNU Emacs." 512 t)
                 (re-search-forward "Copyright ([Cc]).*? Free Software Foundation, Inc."
                                    512 t))))
      "gnu")
     ((or (save-excursion
            (goto-char (point-min))
            (re-search-forward "^#include [<\"]ruby\\.h[>\"]" nil t))
          (string-match "/ruby/" (or (buffer-file-name) "")))
      "ruby")
     (t
      (cdr (assoc 'c-mode c-default-style))))))

(require 'cc-mode)

(setq c-default-style
      '((c-mode . "user")
        (c++-mode . "user")
        (java-mode . "java")
        (d-mode . "stroustrup")
        (other . "cc-mode")))

(add-hook 'c-mode-common-hook
  #'(lambda ()
      (cond
       ((and (fboundp 'ruby-style-c-mode)
             (string-equal (my-guess-c-coding-style) "ruby"))
        (ruby-style-c-mode)))
      (setq c-auto-newline nil)
      (setq c-electric-slash nil)
      (local-set-key "\C-c\C-b" #'ff-find-other-file)
      (local-set-key "\C-c\C-c" #'compile)
      (c-toggle-hungry-state 1)
      ;; `c-basic-offset' をそのバッファの最初の字下げの幅にセット
      ;; する。
      (save-excursion
        (re-search-forward "{\n\\([\t ]\\)[\t ]*" (point-max) t)
        ;; Set tab width.
        (if (string= (match-string 1) "\t")
            (setq tab-width 4))
        (if (> (current-column) 0)
            (setq c-basic-offset (current-column))))))

;; 色附けする識別子の追加

(defcustom my-c-extra-types-c99
  '("_Bool" "bool")
  "Additional C types for C99."
  :group 'my)

(defcustom my-c-extra-types-ruby
  '("VALUE" "T_[A-Z]+" "Qtrue" "Qfalse" "Qnil" "rb_encoding")
  "Additional C types for CRuby."
  :group 'my)

(defcustom my-c-extra-types-glib
  '("CachedMagazine"
    "ChunkLink"
    "GAllocator"
    "GArray"
    "GAsyncQueue"
    "GBookmarkFile"
    "GBookmarkFileError"
    "GByteArray"
    "GCache"
    "GCacheDestroyFunc"
    "GCacheDupFunc"
    "GCacheNewFunc"
    "GChecksum"
    "GChecksumType"
    "GChildWatchFunc"
    "GCompareDataFunc"
    "GCompareFunc"
    "GCompletion"
    "GCompletionFunc"
    "GCompletionStrncmpFunc"
    "GCond"
    "GConvertError"
    "GCopyFunc"
    "GData"
    "GDataForeachFunc"
    "GDate"
    "GDateDMY"
    "GDateDay"
    "GDateMonth"
    "GDateWeekday"
    "GDateYear"
    "GDebugKey"
    "GDestroyNotify"
    "GDir"
    "GDoubleIEEE754"
    "GEqualFunc"
    "GError"
    "GErrorType"
    "GFileError"
    "GFileTest"
    "GFloatIEEE754"
    "GFreeFunc"
    "GFunc"
    "GHFunc"
    "GHRFunc"
    "GHashFunc"
    "GHashTable"
    "GHashTableIter"
    "GHook"
    "GHookCheckFunc"
    "GHookCheckMarshaller"
    "GHookCompareFunc"
    "GHookFinalizeFunc"
    "GHookFindFunc"
    "GHookFlagMask"
    "GHookFunc"
    "GHookList"
    "GHookMarshaller"
    "GIConv"
    "GIOChannel"
    "GIOChannelError"
    "GIOCondition"
    "GIOError"
    "GIOFlags"
    "GIOFunc"
    "GIOFuncs"
    "GIOStatus"
    "GKeyFile"
    "GKeyFileError"
    "GKeyFileFlags"
    "GList"
    "GLogFunc"
    "GLogLevelFlags"
    "GMainContext"
    "GMainLoop"
    "GMappedFile"
    "GMarkupCollectType"
    "GMarkupError"
    "GMarkupParseContext"
    "GMarkupParseFlags"
    "GMarkupParser"
    "GMatchInfo"
    "GMemChunk"
    "GMemVTable"
    "GModule"
    "GModuleCheckInit"
    "GModuleFlags"
    "GModuleUnload"
    "GMutex"
    "GNode"
    "GNodeForeachFunc"
    "GNodeTraverseFunc"
    "GNormalizeMode"
    "GOnce"
    "GOnceStatus"
    "GOptionArg"
    "GOptionArgFunc"
    "GOptionContext"
    "GOptionEntry"
    "GOptionError"
    "GOptionErrorFunc"
    "GOptionFlags"
    "GOptionGroup"
    "GOptionParseFunc"
    "GPatternSpec"
    "GPid"
    "GPollFD"
    "GPollFunc"
    "GPrintFunc"
    "GPrivate"
    "GPtrArray"
    "GQuark"
    "GQueue"
    "GRand"
    "GRegex"
    "GRegexCompileFlags"
    "GRegexError"
    "GRegexEvalCallback"
    "GRegexMatchFlags"
    "GRelation"
    "GSList"
    "GScanner"
    "GScannerConfig"
    "GScannerMsgFunc"
    "GSeekType"
    "GSequence"
    "GSequenceIter"
    "GSequenceIterCompareFunc"
    "GShellError"
    "GSource"
    "GSourceCallbackFuncs"
    "GSourceDummyMarshal"
    "GSourceFunc"
    "GSourceFuncs"
    "GSpawnChildSetupFunc"
    "GSpawnError"
    "GSpawnFlags"
    "GStaticMutex"
    "GStaticPrivate"
    "GStaticRWLock"
    "GStaticRecMutex"
    "GString"
    "GStringChunk"
    "GTestCase"
    "GTestSuite"
    "GTestTrapFlags"
    "GThread"
    "GThreadError"
    "GThreadFunc"
    "GThreadFunctions"
    "GThreadPool"
    "GThreadPriority"
    "GTime"
    "GTimeVal"
    "GTimer"
    "GTokenType"
    "GTokenValue"
    "GTranslateFunc"
    "GTrashStack"
    "GTraverseFlags"
    "GTraverseFunc"
    "GTraverseType"
    "GTree"
    "GTuples"
    "GUnicodeBreakType"
    "GUnicodeScript"
    "GUnicodeType"
    "GUserDirectory"
    "GVoidFunc"
    "gboolean"
    "gchar"
    "gconstpointer"
    "gdouble"
    "gfloat"
    "gint"
    "gint16"
    "gint32"
    "gint64"
    "gint8"
    "glong"
    "goffset"
    "gpointer"
    "gshort"
    "gsize"
    "gssize"
    "guchar"
    "guint"
    "guint16"
    "guint32"
    "guint64"
    "guint8"
    "gulong"
    "gunichar"
    "gunichar2"
    "gushort")
  "Additional C types for GLib."
  :group 'my)

(defcustom my-c-extra-types-shogi
  '("BasicKinds?"
    "Board"
    "Colors?"
    "Evaluator"
    "Kinds?"
    "Moves?"
    "PieceKinds?"
    "Points?"
    "Positions?"
    "Square"
    "Pieces?")
  "Additional C types for computer shogi programming."
  :group 'my)

(defcustom my-c-extra-types-others
  '("st_table"                          ;rubyが使用してゐるhashライブラリ
    )
  nil
  :group 'my)

(defcustom my-c++-extra-types
  '("pair")
  "Additional C++ types."
  :group 'my)

(defcustom my-c-extra-keywords
  '(("\\<NULL\\>" . font-lock-constant-face)
    ("\\<TRUE\\>" . font-lock-constant-face)
    ("\\<FALSE\\>" . font-lock-constant-face))
  "Additional keywords for C language"
  :group 'my)

(defcustom my-c-extra-keywords-c99
  '(("\\<inline\\>" . font-lock-keyword-face)
    ("\\<true\\>" . font-lock-constant-face)
    ("\\<false\\>" . font-lock-constant-face))
  "Additional keywords for C language"
  :group 'my)

(setq c-font-lock-extra-types
      (append my-c-extra-types-c99
              my-c-extra-types-ruby
              my-c-extra-types-glib
              my-c-extra-types-shogi
              my-c-extra-types-others
              c-font-lock-extra-types))

(setq c++-font-lock-extra-types
      (append my-c-extra-types-c99
              my-c-extra-types-ruby
              my-c-extra-types-glib
              my-c-extra-types-shogi
              my-c-extra-types-others
              my-c++-extra-types
              c++-font-lock-extra-types))

(font-lock-add-keywords 'c-mode my-c-extra-keywords)
(font-lock-add-keywords 'c-mode my-c-extra-keywords-c99)
(font-lock-add-keywords 'c++-mode my-c-extra-keywords)


;;; C# (csharp-mode)

(add-to-list 'load-path "/usr/share/emacs/site-lisp/csharp-mode")
(add-to-list 'load-path
  (expand-file-name (locate-user-emacs-file "csharp-mode")))

(let ((path (locate-library "csharp-mode")))
  (autoload 'csharp-mode "csharp-mode" "Major mode for editing C# code." t)
  (add-to-list 'auto-mode-alist '("\\.cs\\'" . csharp-mode))
  (add-hook 'csharp-mode-hook #'(lambda ()
                                  (setq c-basic-offset 4
                                        tab-width c-basic-offset))))


;;; D

(when (locate-library "d-mode")
  (autoload 'd-mode "d-mode" "Major mode for editing D code." t)
  (add-to-list 'auto-mode-alist '("\\.d[i]?\\'" . d-mode))
  (add-hook 'd-mode-hook #'(lambda ()
                             (setq c-basic-offset 4)
                             (setq tab-width c-basic-offset))))


;;; AWK

(add-hook 'awk-mode-hook
  #'(lambda ()
      (setq c-basic-offset 4)))


;;; Ruby

(defun my-electric-end (&optional count)
  "ポイント箇所に文字 \"d\" を插入する。插入後、ポイント直前の語が
\"end\" になつてゐれば `indent-line-function' を束縛してゐる函數を呼ぶ。"
  (interactive "P")
  (insert-char ?d (prefix-numeric-value count))
  (if (and (= 1 (prefix-numeric-value count))
           (save-excursion
             (backward-word)
             (looking-at "\\<end\\>")))
      (funcall indent-line-function)))

(autoload 'ruby-mode "ruby-mode" "Major mode for editing Ruby scripts." t)

(eval-after-load "ruby-mode"
  '(progn
     ;; (defun-if-undefined ruby-kill-sexp (&optional arg)
     ;;   "Kill S expression command for Ruby mode."
     ;;   (interactive "p")
     ;;   (let ((old-point (point)))
     ;;     (ruby-forward-sexp (or arg 1))
     ;;     (kill-region old-point (point))))

     ;; テキスト屬性で設定する追加の構文
     (defun my-ruby-percent-string ()
       (save-excursion
         (save-restriction
           (widen)
           (goto-char (point-min))
           (let (match)
             (while (re-search-forward "\\(%\\)[Qqxr]\\(.\\|\n\\)" nil t)
               (setq match (match-data 1))
               (if (re-search-forward (match-string-no-properties 2) nil t 1)
                   (set-match-data (append match (match-data 0)))))))))

     (defun my-ruby-init-embedded-document-property ()
       "埋込みドキュメントの部分に左マージンを設定する。"
       ;;  (interactive)
       (save-excursion
         (save-restriction
           (save-match-data
             (widen)
             (goto-char (point-min))
             (let (begin end overlay)
               (while (setq begin (re-search-forward "^=begin\\(\\s-+\\|$\\)" nil t))
                 (setq end (or (re-search-forward "^=end\\(\\s-+\\|$\\)" nil t) (point-max)))
                 (add-text-properties
                   begin end
                   (list 'point-entered #'(lambda (begin end)
                                            (setq left-margin (* 1 ruby-indent-level)))
                         'point-left #'(lambda (begin end) (setq left-margin 0))))
                 (set-buffer-modified-p nil)))))))

     (defun-if-undefined ruby-point-in-embedded-doc-p (limit)
       (save-excursion
         (save-match-data
           (widen)
           (if (and (re-search-backward "^=\\(end\\|begin\\)\\(\\s-\\|$\\)" limit t)
                    (string-match "begin" (match-string 1)))
               t))))

     (defun-if-undefined ruby-after-change-embedded-document (begin end length)
       (unless (my-ruby-point-in-embedded-doc-p)
         (setq left-margin 0)
         (remove-text-properties begin end
                                 (list 'point-entered nil
                                       'point-left nil))))

     ;; 「エンコーディング・マジックコメント」の強制插入・書換へ禁止
     (defadvice ruby-mode-set-encoding (around disable-ruby-mode-set-encoding activate)
       "Do nothing."
       nil)

     (defvar my-ruby-font-lock-syntactic-keywords
       (let ((keywords (copy-sequence ruby-font-lock-syntactic-keywords)))
         (setq keywords (delete '("^\\(=\\)begin\\(\\s \\|$\\)" 1 (7 . nil))
                                keywords))
         (setq keywords (delete '("^\\(=\\)end\\(\\s \\|$\\)" 1 (7 . nil))
                                keywords))
         (append '(("^\\(=\\)begin\\(\\s-*.+\\)?\\s-*" 1 (7 . nil))
                   ("^\\(=\\)end\\>" 1 (7 . nil))) keywords)))

     (defvar my-ruby-font-lock-keywords
       (let ((keywords (copy-sequence ruby-font-lock-keywords)))
         ;; 埋込みドキュメントの色附けだが、syntactic-keywords
         ;; で generic string 色附けするので之等は不要:
         (setq keywords (delete '(ruby-font-lock-docs
                                  0 font-lock-comment-face t)
                                keywords))
         (setq keywords (delete '(ruby-font-lock-maybe-docs
                                  0 font-lock-comment-face t)
                                keywords))
         ;; この正規表現だとシンボルや變數等にも一致してしまふので削除):
         (setq keywords (delete '("\\(^\\|[^_]\\)\\b\\([A-Z]+\\(\\w\\|_\\)*\\)"
                                  2 font-lock-type-face)
                                keywords))
         ;;
         (append '(("%[wW]\\(.\\)\\s-*\\(\\sw\\|\\s_\\)+?\\(\\1\\)"
                    2 font-lock-string-face t)
                   ;; percent notation
                   ("%[wW]\\(.\\|\n\\)[^\\1\n]*?\\(\\1\\)"
                    0 nil)
                   ("%[wW]\\((.*?)\\|{.*?}\\|\\[.*?\\]\\)"
                    0 nil)
                   ;; 定數に一致し、シンボルや變數等には一致しない正規表現:
                   ("\\(^\\|[^_.@$?]\\)\\b\\([A-Z]+\\(\\w\\|_\\)*\\)"
                    2 font-lock-type-face)
                   ;; テキスト構文だけでは色附けが難しい部分を補ふ:
                   ("^=\\(end\\)\\>"
                    1 font-lock-doc-face))
                 keywords))
       "變數 `ruby-font-lock-keywords' の内容を削除したり追加して微調整したもの。")

     (defvar ruby-command "ruby")

     (setq auto-mode-alist
           (append '(("\\.rb\\'" . ruby-mode))
                   '(("[Rr]akefile\\'" . ruby-mode))
                   auto-mode-alist))
     (setq interpreter-mode-alist
           (append '(("ruby"    . ruby-mode)
                     ("ruby1.6" . ruby-mode) ("ruby16" . ruby-mode)
                     ("ruby1.7" . ruby-mode) ("ruby17" . ruby-mode)
                     ("ruby1.8" . ruby-mode) ("ruby18" . ruby-mode)
                     ("ruby1.9" . ruby-mode) ("ruby19" . ruby-mode)
                     ("ruby2.0" . ruby-mode) ("ruby20" . ruby-mode)
                     ("ruby3.0" . ruby-mode) ("ruby30" . ruby-mode))
                   interpreter-mode-alist))

     (setq ruby-electric-expand-delimiters-list nil)
     (setq ruby-encoding-map '((japanese-cp932 . cp932)
                               (shift_jis . cp932)
                               (shift-jis . cp932)))

     (add-hook 'ruby-mode-hook
       #'(lambda ()
           ;; Modify mode map:
           (if (fboundp 'ruby-kill-sexp)
               (define-key ruby-mode-map "\C-\M-k" #'ruby-kill-sexp))
           (define-key ruby-mode-map "\C-h" #'c-hungry-delete-backwards)
           (define-key ruby-mode-map "\C-d" #'c-hungry-delete-forward)
           (define-key ruby-mode-map "d" #'my-electric-end)
           ;;
           ;; Font-lock keywords:
           (set (make-local-variable 'font-lock-defaults)
                '(my-ruby-font-lock-keywords nil nil))
           (set (make-local-variable 'font-lock-keywords)
                my-ruby-font-lock-keywords)
           (set (make-local-variable 'font-lock-syntactic-keywords)
                my-ruby-font-lock-syntactic-keywords)
           ;;
           ;; Compilation.
           (require 'compile)
           (make-local-variable 'compile-command)
           (setq compile-command
                 (concat ruby-command
                         (if (or (buffer-file-name) "")
                             (concat " "
                                     (substring (or (buffer-file-name) "")
                                                (string-match "[^/]+\\'"
                                                              (or (buffer-file-name) ""))))
                           "")
                         " "))
           (setq compilation-error-regexp-alist
                 (cons '("^\tfrom \\([^: \t]+\\):\\([1-9][0-9]+\\)" 1 2)
                       compilation-error-regexp-alist))
           ;;                (setq compilation-error-regexp-alist
           ;;                      (cons '("^\\([^: \t]+\\):\\([1-9][0-9]+\\)" 1 2)
           ;;                            compilation-error-regexp-alist))
           ;; 函數 ruby-mode-variables 内で何故か nil に set してゐる
           (setq case-fold-search t)
           ;; Text properties:
           ;;                (my-ruby-init-embedded-document-property)
           ;;                (set (make-local-variable 'after-change-functions)
           ;;                     'my-ruby-after-change-embedded-document)
           ;; S expression:
           (set (make-local-variable 'parse-sexp-lookup-properties) t)
           ;; Change hook
           ;;            (add-hook (make-local-variable 'after-change-functions)
           ;;                      'my-ruby-after-change-function nil t)
           ;; Paragraphs
           (setq paragraph-start
                 (concat page-delimiter
                         "\\|^\\s-*#\\s-*$"
                         "\\|^=begin\\(\\s-+.+\\)?\\s-*$"
                         "\\|^=end\\s-*$"
                         "\\|\n"))
           (setq paragraph-separate (concat paragraph-start))
           (setq paragraph-ignore-fill-prefix t)
           ;; Settings of indentation:
           (setq indent-tabs-mode nil)
           (setq ruby-indent-tabs-mode nil)
           (setq tab-width 2)
           ;; Align
           (when (require 'align nil t)
             (add-to-list 'align-rules-list
               '(ruby-assignment
                 (regexp . "\\(\\s-*\\)=\\s-*")
                 (repeat . t)
                 (modes  . '(ruby-mode))))
             (add-to-list 'align-rules-list
               '(ruby-hash-literal
                 (regexp . "\\(\\s-*\\)=>\\s-*[^# \t\r\n]")
                 (repeat . t)
                 (modes  . '(ruby-mode)))))))))


;;; endless-view-mode

;; Copyright © 2012  MORIYAMA Hiroshi
;; Published: 2011-10-26 on <http://d.hatena.ne.jp/mhrs/20111026>
;; License: GPLv3 or leter

;; "end" だけ、または "end" とコメントだけの行を、その "end" のフェイスが
;; `font-lock-keyword-face' である場合にのみ非表示にする。

(defmacro endless-view-mode-define-buffer-local-variable (var-name &optional default-value docstring)
  `(progn
     (defvar ,var-name ,default-value ,docstring)
     (make-variable-buffer-local (quote ,var-name))
     (setq-default ,var-name ,default-value)))

(endless-view-mode-define-buffer-local-variable endless-view-mode-overlays
                                                '())

(defun endless-view-mode-invisible-region (start end)
  (let ((end-line-overlay (make-overlay start end)))
    (add-to-list 'endless-view-mode-overlays end-line-overlay)
    (overlay-put end-line-overlay 'invisible t)
    end-line-overlay))

(defun endless-view-mode-on ()
  (save-excursion
    (goto-char (point-min))
    ;; Set invisible overlays to "end" lines.
    (while (re-search-forward "^\\s-*\\(end\\)\\s-*\\(?:#.*?\\)?$" nil t)
      ;; Check face of the matched "end".
      (when (eql (plist-get (text-properties-at (match-beginning 1)) 'face)
                 'font-lock-keyword-face)
        (endless-view-mode-invisible-region (point-at-bol) (point-at-eol))
        (when (looking-at "[\r\n]")
          (endless-view-mode-invisible-region (point-at-eol)
                                              (1+ (point-at-eol))))))
    (toggle-read-only 1)))

(defun endless-view-mode-off ()
  (unless (null endless-view-mode-overlays)
    (save-restriction
      (widen)
      ;; Delete invisible overlays.
      (mapcar #'(lambda (ol) (delete-overlay ol))
              endless-view-mode-overlays)
      (setq endless-view-mode-overlays nil)
      (toggle-read-only -1))))

(defun toggle-endless-view-mode ()
  (interactive)
  (let ((case-fold-search nil))
    (if (null endless-view-mode-overlays)
        (endless-view-mode-on)
      (endless-view-mode-off))))

(defadvice toggle-read-only (after disable-endless-view-mode activate)
  (unless buffer-read-only
    (endless-view-mode-off)))


;;; Racc

;; (setq load-path (cons "~/.emacs.d/racc-mode" load-path))
;; (when (require 'racc-mode nil t)
;;   (setq auto-mode-alist
;;         (append '(("\\.ry\\'" . racc-mode)
;;                   ("\\.racc?\\'" . racc-mode))
;;                 auto-mode-alist)))


;;; Auto Setting `indent-tabs-mode' Variable

;; Inspired by "タブコード使用の自動判別"
;; <http://www.greenwood.co.jp/~k-aki/article/emacs_autotab.html>.

(defun my-buffer-indent-tabs-code-p (&optional buffer)
  "BUFFER 内の最初のインデントがタブ文字であれば t を返す。
BUFFER が nil であれば現バッファ(current buffer)を調べる。"
  (let ((buffer (or buffer (current-buffer))))
    (with-current-buffer buffer
      (save-excursion
        (save-restriction
          (widen)
          (goto-char (point-min))
          (and (re-search-forward-without-string-and-comments "^[ \t]"
                                                              (point-max) t)
               (string= (match-string 0) "\t")))))))

(defun my-set-indent-tabs-mode ()
  (setq indent-tabs-mode (my-buffer-indent-tabs-code-p)))

(add-hook 'c-mode-common-hook #'my-set-indent-tabs-mode)
(add-hook 'emacs-lisp-mode-hook #'my-set-indent-tabs-mode)
(add-hook 'java-mode-hook #'my-set-indent-tabs-mode)
(add-hook 'perl-mode-hook #'my-set-indent-tabs-mode)
(add-hook 'python-mode-hook #'my-set-indent-tabs-mode)
(add-hook 'racc-mode-hook #'my-set-indent-tabs-mode)
(add-hook 'ruby-mode-hook #'my-set-indent-tabs-mode)
(add-hook 'sh-mode-hook #'my-set-indent-tabs-mode)


;;; Text Mode

(add-hook 'text-mode-hook
  #'(lambda ()
      (if (string-match "\\.dict?\\'" (or (buffer-file-name) ""))
          (setq truncate-lines t))
      (setq line-spacing 2)
      (setq truncate-lines nil)
      (setq tab-always-indent 'always)
      ;; Comment
      (set (make-local-variable 'comment-start) "#")
      ;; (set (make-local-variable 'comment-end) "")
      (set (make-local-variable 'comment-use-syntax) t)
      ;;(set (make-local-variable 'comment-continue) " * ")
      ;;(set (make-local-variable 'comment-start-skip) "\\(#+\\|/\\*+\\)\\s-*")
      ;;(set (make-local-variable 'comment-end-skip) "$\\|\\*/")
      ;; TODO: tab-stop-listの値をtab-widthの倍數にしたい
      ;; (setq paragraph-start (concat "^[>|]* *$\\|" paragraph-start))
      ;; (setq paragraph-separate paragraph-start)
      ;; (setq paragraph-separate (concat "|" paragraph-separate))
      ;;
      (make-local-variable 'adaptive-fill-mode)
      (setq adaptive-fill-mode t)
      ;;(make-local-variable adaptive-fill-regexp)
      (make-local-variable 'adaptive-fill-first-line-regexp)
      (setq adaptive-fill-first-line-regexp "\\`[ \t>|]*\\'")
      ;;(make-local-variable adaptive-fill-function)
      ))


;;; Mouse

(mouse-wheel-mode 1)
(setq mouse-wheel-follow-mouse t)
;; マウスホイールで一度にスクロールする行數。
;;
;;    '(通常時 . Shiftキーを押しながら回した時)
;;
;; Emacs 21でのデフォルト: ??
;; Emacs 23でのデフォルト: '(5 ((shift) . 1) ((control) . nil))
(setq mouse-wheel-scroll-amount '(5 ((shift) . 1) ((control) . nil)))


;;; Window

;; (windmove-default-keybindings) ;`Shift + 矢印キー'で分割したウィンドウを移動


;;; My Functions

;; Author: MORIYAMA Hiroshi

(defun-if-undefined string-to-list (string)
  (append string nil))

(defun-if-undefined list-to-string (characters)
  (apply #'string characters))

(defun-if-undefined sort-charcters-at-line ()
  (interactive)
  (let ((characters (string-to-list (buffer-substring-no-properties (point-at-bol) (point-at-eol)))))
    (delete-region (point-at-bol) (point-at-eol))
    (insert (list-to-string (sort characters #'<)))))

(defun-if-undefined get-buffer-with-predicate (predicate)
  ;; Created: 2011-08-09T19:02:33+09:00
  "`get-window-with-predicate' の buffer 版。"
  (find-if predicate (buffer-list)))

(defun-if-undefined base-file-name (string)
  "STRING をパスネームとしてそのベースネームを返す。
すなはち STRING の最後の `/' 以降の文字列を返す。
STRING が `/' を含まない場合は STRING と同じ内容の文字列を返す。"
  (substring string (string-match "[^/]+\\'" string)))

(defun-if-undefined insert-emacs-version ()
  (interactive)
  (insert (emacs-version)))

(defun hm-uuid-string ()
  (interactive)
  (with-temp-buffer
    (call-process "uuidgen" nil (current-buffer) t)
    (buffer-substring-no-properties (point-min)
                                    ;; Remove newline.
                                    (1- (point-max)))))

(defun hm-insert-uuid ()
  (interactive)
  (insert (hm-uuid-string)))

(defun-if-undefined insert-xml-decl ()
  "Insert XML decl."
  (interactive)
  (insert "<?xml version=\"1.0\" encoding=\"UTF-8\">"))

(defun-if-undefined insert-doctype (&optional doctype)
  "Insert document type."
  (interactive)
  (insert "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\">"))

(defun-if-undefined insert-mail-address ()
  "Insert e-mail address."
  (interactive)
  (insert user-mail-address))

(defun-if-undefined insert-author ()
  "\"Author: user-full-name <user-mail-address>\" 形式の行を插入する。"
  (interactive)
  (let ((column (current-column)))
    (beginning-of-line)
    (insert (concat "Author: " user-full-name " <" user-mail-address ">\n"))
    (forward-line -1)
    (comment-region (point-at-bol) (point-at-eol))
    (move-to-column column)))

(defun-if-undefined insert-unix-time ()
  (interactive)
  (insert (format-time-string "%s" (current-time))))

(defun-if-undefined display-face-name-at-point ()
  "ポイント箇所のface名を表示"
  (interactive)
  (message "%S" (get-text-property (point) 'face)))

(defun my-create-buffer-by-time-stamp (&optional ext)
  "タイムスタンプを名前にしたバッファを作製する"
  (interactive)
  (find-file
   (concat (format-time-string "%Y-%m-%dT%H-%M-%S" (current-time)) ext)))

(defun-if-undefined rename-current-buffer-file (newname)
  "カレントバッファに關連附けられてゐるファイルをリネームする"
  (interactive "FRename current buffer file to: ")
  (if (file-exists-p (or (buffer-file-name) ""))
      (progn
        (rename-file (or (buffer-file-name) "") newname)
        (find-alternate-file newname))
    (rename-buffer newname)))

(global-set-key "\C-cR" #'rename-current-buffer-file)

(defun my-sort-region (field)
  "前置引數を與へた場合は `sort-field' を、引數無しの場合は `sort-lines'
を實行する。"
  (interactive "p")
  (if (not (=  field 1))
      (sort-fields field (mark) (point))
    (sort-lines nil (mark) (point))))

;; (global-set-key "\M-s" #'my-sort-region)

(defun-if-undefined insert-iroha (&optional arg)
  (interactive "P")
  (let ((iroha (concat "いろはにほへとちりぬるをわかよたれそつねならむ"
                       "うゐのおくやまけふこえてあさきゆめみしゑひもせす")))
    (insert iroha)))


;;; ISO 8601

;; 作り掛け。

;;;; Variables

;; (defconst iso-8601-time-zone-designator-re
;;   (concat "\\(Z\\|"
;;           "\\([-+]\\)\\([0-1][0-9]\\|2[0-3]\\):\\([0-5][0-9]\\)"
;;           "\\)"
;;           "$"))

;; (defconst iso-8601-year-re
;;   "^\\([0-9][0-9][0-9][0-9]\\)$")

;; (defconst iso-8601-year-month-re
;;   (concat "^\\([0-9][0-9][0-9][0-9]\\)"
;;           "-\\(0[1-9]\\|1[0-2]\\)$"))

;; (defconst iso-8601-year-month-day-re
;;   (concat "^\\([0-9][0-9][0-9][0-9]\\)"
;;           "-\\(0[1-9]\\|1[0-2]\\)"
;;           "-\\([0-2][1-9]\\|[1-2][0-9]\\|3[0-2]\\)$"))

;; (defconst iso-8601-year-month-day-time-tzd-re
;;   (concat "^\\([0-9][0-9][0-9][0-9]\\)-\\(0[1-9]\\|1[0-2]\\)-\\([0-2][0-9]\\|3[0-2]\\)"
;;           "T\\([0-1][0-9]\\|2[0-3]\\):\\([0-5][0-9]\\):\\([0-5][0-9]\\)" ; 00:00:00 ... 23:59:62
;;           iso-8601-time-zone-designator-re))

;; (defconst iso-8601-year-month-day-time-microseconds-tzd-re
;;   (concat "^\\([0-9][0-9][0-9][0-9]\\)-\\(0[1-9]\\|1[0-2]\\)-\\([0-2][0-9]\\|3[0-2]\\)"
;;           "T\\([0-1][0-9]\\|2[0-3]\\):\\([0-5][0-9]\\):\\([0-5][0-9]\\)" ; 00:00:00 ... 23:59:62
;;           "\\.\\([0-9]+\\)"
;;           iso-8601-time-zone-designator-re))

;; (defun iso-8601-valid-w3c-dtf-p (string)
;;   (let ((case-fold-search nil))
;;     (cond
;;      ((string-match iso-8601-year-month-day-time-microseconds-tzd-re string) t)
;;      ((string-match iso-8601-year-month-day-time-tzd-re string) t)
;;      ((string-match iso-8601-year-month-day-re string) t)
;;      ((string-match iso-8601-year-month-re string) t)
;;      ((string-match iso-8601-year-re string) t)
;;      (t nil))))

;;;; W3C-DTF

;; ref. "Date and Time Formats" <http://www.w3.org/TR/NOTE-datetime>.

(defun iso-8601-w3c-dtf-time-zone-designator (&optional time universal)
  (save-match-data
    (let ((time (or time (current-time))))
      (let ((tzd (format-time-string "%z" time universal)))
        (if universal
            "Z"
          (if (string-match "\\`\\([-+][0-9][0-9]\\)\\([0-9][0-9]\\)\\'"
                            tzd)
              (concat (match-string-no-properties 1 tzd) ":"
                      (match-string-no-properties 2 tzd))
            (error (concat "Unexpected return value of "
                           "(format-time-string \"%%z\" time universal): %s")
                   (prin1-to-string tzd))))))))

(defun iso-8601-w3c-dtf-string (&optional time universal)
  (let ((time (or time (current-time))))
    (concat (format-time-string "%Y-%m-%dT%T" time universal)
            (iso-8601-w3c-dtf-time-zone-designator time universal))))

(defun iso-8601-string (&optional time universal)
  (error "Not implemented."))

(defun iso-8601-insert-iso-8601 ()
  (interactive)
  (insert (iso-8601-w3c-dtf-string)))

;; `C-c' `i'nsert `t'ime と覺える。
(global-set-key "\C-cit" #'iso-8601-insert-iso-8601)


;;; Time Stamp

(autoload 'time-stamp "time-stamp")

(eval-after-load "time-stamp"
  '(progn
     (setq time-stamp-format '(iso-8601-w3c-dtf-string))
     (setq time-stamp-old-format-warn nil)
     (setq time-stamp-line-limit 24)
     (setq time-stamp-warn-inactive t)

     ;; `write-file-hooks' で起動すると `kill-ring' にタイムスタンプの變更が頻
     ;; 繁に記録され `undo' が使ひづらくなるのでコメントアウトしてゐる。VCSのリ
     ;; ポジトリに追加するときなどでのみ有效にしたい。なほ `M-x time-stamp' に
     ;; よる手動での使用は可能。
     ;;
     ;; (add-hook 'write-file-hooks #'time-stamp)

     ;; Emacsの設定ファイル(「この」ファイル又は `user-emacs-directory' 内の.el
     ;; ファイル)でのタイムスタンプの書式設定。`time-stamp' を有效にするか否か
     ;; の設定は別箇にし、このフック函數では書式のみ設定する:
     (add-hook 'emacs-lisp-mode-hook
       #'(lambda ()
           (setq time-stamp-start "^;; Modified: ")
           (setq time-stamp-end "$")))))


;;;  Grep

(if (file-exists-p "/bin/grep")
    (progn
      (setq grep-command "/bin/grep -RnH -e ")
      (setq grep-program "/bin/grep")))


;;; Abbrev

;; (global-set-key (kbd "<backtab>") 'expand-abbrev)

;; (setq abbrev-file-name "~/.emacs-abbrev-defs")
;; (setq save-abbrevs t)
;; (quietly-read-abbrev-file)
;; ;; 以下は單なる好み
;; (global-set-key "\C-x'" #'just-one-space)
;; (global-set-key "\M- " #'dabbrev-expand)
;; (global-set-key "\M-/" #'expand-abbrev)
;; (eval-after-load "abbrev" '(global-set-key "\M-/" #'expand-abbrev))


;;; その他の擴張子・ファイル名の關聯附け

(defconst my-iso-639-1-codes-re
  (regexp-opt (mapcar #'symbol-name
                      '(aa ab af ak sq am ar an hy as av ae ay az ba bm eu be
                           bn bh bi bo bs br bg my ca cs ch ce zh cu cv kw co cr
                           cy cs da de dv nl dz el en eo et eu ee fo fa fj fi fr
                           fr fy ff ka de gd ga gl gv el gn gu ht ha he hz hi ho
                           hr hu hy ig is io ii iu ie ia id ik is it jv ja kl kn
                           ks ka kr kk km ki rw ky kv kg ko kj ku lo la lv li ln
                           lt lb lu lg mk mh ml mi mr ms mk mg mt mo mn mi ms my
                           na nv nr nd ng ne nl nn nb no ny oc oj or om os pa fa
                           pi pl pt ps qu rm ro ro rn ru sg sa sr hr si sk sk sl
                           se sm sn sd so st es sq sc sr ss su sw sv ty ta tt te
                           tg tl th bo ti to tn ts tk tr tw ug uk ur uz ve vi vo
                           cy wa wo xh yi yo za zh zu))))

;; AUTHORS, COPYING, TODO, README, etc ...
(add-to-list 'auto-mode-alist
  (cons (concat "\\`" (regexp-opt '("AUTHORS"
                                    "BSD"
                                    "COPYING"
                                    "GLOSSARY"
                                    "GPL"
                                    "LEGAL"
                                    "LGPL"
                                    "LICENSE"
                                    "MIT"
                                    "README"
                                    "TODO"))
                "\\(?:\\." my-iso-639-1-codes-re "\\)?\\'")
        'text-mode))

(setq auto-mode-alist
      (append '(("/PKGBUILD\\'" . sh-mode) ;Arch Linux
                ("/\\.bashrc\\'" . sh-mode)
                ("/\\.gnomerc\\'" . sh-mode)
                ("/\\.zshrc\\'" . sh-mode)
                ("/\\.clisprc\\'" . lisp-mode)
                ("/\\.sbclrc\\'" . lisp-mode)
                ("/\\.devilspie/.+?\\.ds\\'" . lisp-mode)
                ("/\\.irbrc\\'" . ruby-mode)
                ("\\.jar\\'" . archive-mode))
              auto-mode-alist))

;; XPI (zippy)
(add-to-list 'auto-mode-alist '("\\.xpi\\'" . archive-mode))
(add-to-list 'auto-coding-alist '("\\.xpi\\'" . no-conversion))

;; ファイル内容によつてHTMLと解釋されるのを防ぐ。
(add-to-list 'magic-mode-alist '("browser\\.jar\\'" . archive-mode))

;; crontab
(add-to-list 'auto-mode-alist '("\\`crontab\\'" . sh-mode))
(add-to-list 'magic-mode-alist '("^SHELL=/bin/\\(?:ba\\)?sh$" . sh-mode))

;; Graphviz
(if (load "graphviz-dot-mode" t)
    (add-to-list 'auto-mode-alist '("\\.\\(?:dot\\|gv\\)\\'" . graphviz-dot-mode)))


;;; ac-mode --- Intelligent Complete Command

;; <http://taiyaki.org/elisp/ac-mode/>

(autoload 'ac-mode "ac-mode" "Minor mode for advanced completion." t nil)


;;; browse-url --- Open URL in external web browser

(require 'browse-url)

(defun my-search-command-in-exec-path (command-names)
  (let (name found)
    (while (setq name (car command-names))
      (setq found (find-if #'file-executable-p
                           (mapcar #'(lambda (dirname)
                                       (expand-file-name (concat dirname "/" name)))
                                   exec-path)))
      (if found
          (setq command-names nil)
        (setq command-names (cdr command-names))))
    found))

(defcustom my-browse-url-order-of-search-browsers
  '("icecat"
    "firefox"
    "midori"
    "galeon"
    "epiphany"
    "chromium-browser"
    "seamonkey")
  "docstring."
  :group 'my)

;; `thing-at-point-url-at-point' がURLを識別する爲の正規表現。初期値では全角の
;; 括弧などにも一致してしまふ。
(setq thing-at-point-url-path-regexp "[-A-Za-z0-9~@#%&()_=+./?:;]+")

;; 外部コマンドの設定。
(let ((command (base-file-name
                (car (split-string
                      (with-temp-buffer
                        (if (zerop (call-process "gconftool-2" nil (current-buffer) nil
                                                 "--get" "/desktop/gnome/url-handlers/http/command"))
                            (buffer-substring-no-properties (point-min) (point-max)))))))))
  (cond
   ;; Chromium.
   ((or (string-equal (base-file-name command) "chromium-browser")
        (string-equal (base-file-name command) "chromium"))
    (setq browse-url-generic-program command
          browse-url-generic-args '()
          browse-url-browser-function #'browse-url-generic))
   ;;
   ;; Mozilla Firefox.
   ((string-equal (base-file-name command) "firefox")
    (setq browse-url-mozilla-program command
          browse-url-new-window-flag nil
          browse-url-browser-function #'browse-url-mozilla
          ;; 新規タブで開く。
          browse-url-mozilla-arguments '("-new-tab") ))))


;;; Autoinsert (template)

(require 'autoinsert)

(add-hook 'find-file-hook 'auto-insert)
(auto-insert-mode 1)
(setq auto-insert-directory (concat (user-emacs-directory) "template"))

(defvar my-auto-insert-alist-orig
  (copy-sequence auto-insert-alist)
  "カスタマイズ變數 `auto-insert-alist' のバックアップコピー。")


;;; Recenter

(global-set-key "\C-l" #'recenter) ;Emacs 23では C-l は `recenter' ではない。

(defadvice recenter (after recenter-and-font-lock-fontify-buffer)
  "`recenter' (\"C-l\") にfont-lockの再描畫を追加。"
  (unless (or (eql major-mode 'eshell-mode))
    (font-lock-fontify-buffer)))

(ad-activate #'recenter)


;;; `uniq-region'

;; - <http://www.astrogoth.com/~reeses/software/uniq.el> (Redirects to GitHub)
;; - <https://github.com/arttaylor/scripts/blob/master/elisp/uniq.el>

;; % cd ~/.emacs.d
;; % git clone git://github.com/arttaylor/scripts.git arttaylor/scripts

(load (locate-user-emacs-file "arttaylor/scripts/elisp/uniq") t)


;;; Htmlize

(require 'htmlize)

(defadvice htmlize-untabify (around
                             disable-htmlize-untabify (text start-column))
  "`htmlize' が勝手に untabify するのを防ぐ。"
  (setq ad-return-value text))

(ad-activate #'htmlize-untabify)

(defadvice htmlize-protect-string (after
                                   whitespace-to-numeric-reference (string))
  "`htmlize' 時にタブ文字と空白を數値文字參照へ變換する。"
  (setq ad-return-value
        (replace-regexp-in-string "[ \t]+"
                                  #'(lambda (s)
                                      (mapconcat #'(lambda (c)
                                                     (format "&#%d;" c))
                                                 (string-to-list s)
                                                 ""))
                                  ad-return-value)))

(defadvice htmlize-region (around temporary-set-light-background-color (beg end))
  "`htmlize-region' を實行するとき背景色を白、文字色を黒に變更し、
實效し終つたら元に戻す。"
  (let ((fgcolor (cdr (assq 'foreground-color (frame-parameters (selected-frame)))))
        (bgcolor (cdr (assq 'background-color (frame-parameters (selected-frame))))))
    (unwind-protect
        (progn
          (set-background-color "white")
          (set-foreground-color "black")
          ad-do-it)
      (progn
        (set-background-color bgcolor)
        (set-foreground-color fgcolor)))))

(defun-if-undefined htmlize-region-string (start end)
  ;; `htmlze-region'を呼出し、PRE要素の中身だけを取出して文字列で返す。
  "Run `htmlize-region' and extract contents of the PRE element,
returns a string."
  (let ((output-buffer (htmlize-region start end)))
    (unwind-protect
        (with-current-buffer output-buffer
          (let* ((text (buffer-substring-no-properties
                        (plist-get htmlize-buffer-places 'content-start)
                        (plist-get htmlize-buffer-places 'content-end)))
                 ;; Remove PRE tags:
                 (text (substring (substring text 0
                                             (- (length text)
                                                (length "</pre>")))
                                  (length "<pre>")))
                 (index-of-not-newline-character (or (string-match "[^\r\n]" text)
                                                     (length text))))
            (substring text index-of-not-newline-character)))
      (kill-buffer output-buffer))))

(defun-if-undefined kill-ring-save-htmlized-region (start end)
  (interactive "r")
  (let ((html-fragment (htmlize-region-string start end)))
    (with-temp-buffer
      (insert (concat "<pre><code>" html-fragment "</code></pre>"))
      (copy-region-as-kill (point-min) (point-max))
      (message "Successed copy htmlized text to kill ring."))))

(eval-after-load "htmlize"
  '(progn
     (setq htmlize-html-charset "UTF-8")
     (setq htmlize-convert-nonascii-to-entities nil)
     (ad-activate #'htmlize-untabify)
     ;; `htmlize' 時にタブ文字と空白を數値文字參照へ變換する。
     ;; (ad-activate #'htmlize-protect-string)
     (ad-activate #'htmlize-region)))


;;; auto-save-buffers

;; - "Emacsでファイルの自動保存 (auto-save-buffers)"
;;   <http://0xcc.net/misc/auto-save/>

;; - "auto-save-buffers.el" (Encoding: EUC-JP)
;;   <http://namazu.org/~satoru/misc/auto-save/auto-save-buffers.el>

;; Alternative feature:
;; - "auto-save-buffers-enhanced更新 - antipop"
;;   <http://d.hatena.ne.jp/antipop/20080222/1203688543>

(add-to-load-path (locate-user-emacs-file "auto-save-buffers/"))

(when (require 'auto-save-buffers nil t)
  (setq auto-save-buffers-regexp (concat "\\`" (getenv "HOME")))
  (setq auto-save-buffers-exclude-regexp (mapconcat 'identity
                                                    '("^$"
                                                      "/Mail\\(/.+\\)?/[1-9][0-9]*\\'"
                                                      "\\.howm-keys"
                                                      "\\`PKGBUILD\\'")
                                                    "\\|"))
  ;; `auto-save-buffers' の ON/OFF を切替へるキー定義 (C-x a s):
  (define-key ctl-x-map "as" 'auto-save-buffers-toggle)
  ;; アイドル状態が1.72秒續いたら自動保存する。
  (run-with-idle-timer 1.72 t 'auto-save-buffers))


;;; 保存するとき無駄な空白・改行を削除

;; Author: MORIYAMA Hiroshi
;; FIXME: 筋のよい實裝とはとても言へない。改良の餘地あり。

(defcustom my-delete-trailing-whitespace-mode nil
  "FIXME: write docstring."
  :group 'my)

(defun my-exist-diff-output-in-current-buffer-p ()
  "カレントバッファの内容に `diff -u' の出力が含まれてゐれば眞を返す。"
  (save-excursion
    (save-restriction
      (widen)
      (goto-char (point-min))
      (re-search-forward "^@@ [-+][0-9,]+ [-+][0-9,]+ @@$" nil t))))

(defun my-delete-whitelines-at-point (point &optional without-current-line-p)
  (interactive)
  (save-excursion
    (if (looking-at "\n\n")
        (if (not (and without-current-line-p
                      (= (point) point)))
            (progn (delete-char 1)
                   (my-delete-whitelines-at-point point without-current-line-p))))))

(defun my-delete-trailing-whitespace ()
  (interactive)
  (when (and my-delete-trailing-whitespace-mode
             (not (my-exist-diff-output-in-current-buffer-p))
             (or (interactive-p)
                 (and (buffer-file-name)
                      (not (string-match (regexp-opt '("/Projects"
                                                       "/tmp"
                                                       "/mytest"
                                                       "debian"
                                                       "index.dat"
                                                       "anthy-9100h"
                                                       "depgraph"
                                                       "hatena-mode"
                                                       "hatena-diary-mode"
                                                       "/src/"
                                                       "/ruby-edge/"
                                                       "/ruby-elisp"))
                                         (buffer-file-name))))))
    (save-excursion
      (save-restriction
        (widen)
        (let ((current-point (point)))
          (goto-char (point-min))
          (while (re-search-forward "[ \t]+$" nil t)
            (let ((begin (match-beginning 0))
                  (end (match-end 0)))
              (if (and (not (= end current-point))
                       (not (string-match "^-- " ;E-mail signature
                                          (buffer-substring-no-properties
                                           (point-at-bol) (point-at-eol)))))
                  (delete-region begin end)))))
        (goto-char (point-max))
        (skip-chars-backward "\r\n")
        (my-delete-whitelines-at-point (point) 'without-current-line)))))

;; ファイルのセーブ時に自動的に行末の空白類を削除する。
(add-hook 'before-save-hook
  #'(lambda ()
      (unless (or (string-match "\\.ws\\'" (or (buffer-file-name) ""))
                  (eql major-mode 'diff-mode)
                  ;; TODO: 他人のリポジトリでは動作しないやうにしたい。
                  ;; (vc-backend (buffer-file-name))
                  )
        (my-delete-trailing-whitespace))))


;;; Normalize Whitspaces

(defun normalize-whitespaces-region (start end)
  "行末尾の空白を削除し、複数の空行を一つの空行に纏める。バッファ
末尾の空白類は一つの改行に纏める。"
  (interactive "r")
  (save-excursion
    (save-restriction
      (widen)
      (narrow-to-region start end)
      (goto-char (point-min))
      (save-excursion
        (while (re-search-forward "[ \t]+$" nil t)
          (replace-match "")))
      (save-excursion
        (while (re-search-forward "\n\\{2,\\}" nil t)
          (replace-match "\n\n")))
      (save-excursion
        (if (re-search-forward "[ \t\n]+\\'" nil t)
            (replace-match "\n"))))))


;;; Dired Mode

(require 'dired)

(eval-after-load "dired"
  '(progn
     (require 'dired-x)
     (require 'ls-lisp)
     (setq ls-lisp-dirs-first t)))

(setq dired-omit-files (concat dired-omit-files "\\|\\.bak\\'"))

;; 參考: <http://www.i.kyushu-u.ac.jp/~s-fusa/emacs/elisp/dot.emacs-dired.el.html>

(defcustom my-dired-omit-extensions-in-directory
  nil
  "`dired-omit' で非表示にしたいファイルの擴張子のリスト(cdr部)と、
そのリストを實際に有效にしたい特定のディレクトリ
名(`dired-current-directory'の返値)に一致する正規表現(car部)からな
る聯想配列。

Example:

    '((\"/depgraph/\" . (\".tmp\")))"
  :group 'my)

(defun my-dired-current-directory-no-error (&optional localp)
  (condition-case nil
      (dired-current-directory localp)
    (error nil)))

(defadvice dired-revert (around my-dired-omit-file-names activate)
  (let ((dired-omit-extensions dired-omit-extensions))
    (dolist (pair my-dired-omit-extensions-in-directory)
      (let* ((directory-name-re (car pair))
             (omit-extensions (cdr pair)))
        (if (string-match directory-name-re (or (my-dired-current-directory-no-error) ""))
            (setq dired-omit-extensions (append omit-extensions dired-omit-extensions)))
        ad-do-it))))

(defadvice dired-omit-mode (around my-dired-omit-file-names activate)
  (let ((dired-omit-extensions dired-omit-extensions))
    (dolist (pair my-dired-omit-extensions-in-directory)
      (let* ((directory-name-re (car pair))
             (omit-extensions (cdr pair)))
        (if (string-match directory-name-re (or (my-dired-current-directory-no-error) ""))
            (setq dired-omit-extensions (append omit-extensions dired-omit-extensions)))
        ad-do-it))))

;; ディレクトリの再歸コピー・再歸削除を有效にする ('top or 'always)
;; Emacs 21以降のみらしい。
(setq dired-recursive-copies 'top)
(setq dired-recursive-deletes 'top)

;; ls command optoin
(setq dired-listing-switches "-lDAth --group-directories-first")

;; dired-do-shell-command で實行するコマンドのデフォルト
(setq dired-guess-shell-alist-user '(("\\.t\\(ar\\.\\)?gz\\'" "tar -zxf")
                                     ("\\.tar\\.bz2\\'" "tar -jxf")))

;; Diredの `M-o' で非表示にするファイル名。
(setq dired-omit-files (concat "^\\.?#\\|^\\.$\\|^\\.\\.$" ;default value
                               "\\|^[._].+$"))

(setq my-dired-omit-extensions-in-directory
      '(("/depgraph/" . (".tmp"))))


;;; サイズ・擴張子で竝べ替へ

;; <http://www.bookshelf.jp/soft/meadow_25.html#SEC287>

;; (load "sorter")


;;; Backup

;; 番號附バックアップファイル。
(setq make-backup-files t)              ;default: t
(setq version-control t)                ;default: nil
(setq backup-by-copying-when-linked t)  ;default: nil
(setq kept-new-versions 4)              ;default: 2
(setq kept-old-versions 4)              ;default: 2
(setq delete-old-versions t)            ;default: nil
;; (setq backup-by-copying nil)                ;default: nil
;; (setq backup-by-copying-when-linked nil)    ;default: t
;; (setq backup-by-copying-when-mismatch nil)  ;default: nil
;; (setq vc-make-backup-files nil)             ;default: nil
(setq backup-directory-alist
      (cons (cons "\\.*\\'" (expand-file-name "~/backups/emacs-backup-files"))
            backup-directory-alist))


;;; Recent Opened Files

;; Usage: `M-x recentf-open-files'

;; (recentf-mode)


;;; ff-find-other-file

;; `M-x ff-find-other-file' で對應するファイル間を移動。

;;  #include 付近ではインクルードしてゐるファイルに訪問する。
(global-set-key "\C-c\C-b" #'ff-find-other-file)
(setq ff-other-file-alist
      '(("\\.c\\'"  (".h"))
        ("\\.h\\'"  (".c"))
        ;; C++
        ("\\.cc\\'"  (".hh" ".h"))
        ("\\.hh\\'"  (".cc" ".C" ".CC" ".cxx" ".cpp"))
        ;; Yacc and Lex
        ("\\.y\\'" (".l"))
        ("\\.l\\'" (".y"))
        ;; RSpec
        ("_spec\\.rb\\'" (".rb"))
        ("\\.rb\\'" ("_spec.rb"))))

(setq ff-search-directories
      '(".."
        "spec")) ;RSpec


;;; Eshell

;; NOTE: 2012-06-25現在使つてゐないので適當。

(defun my-eshell-erase-command-line ()
  (interactive)
  (kill-region (my-eshell-point-at-beginning-of-command-line)
               (point-at-eol)))

(eval-after-load "eshell"
  '(progn
     (setq eshell-glob-include-dot-dot nil) ;ワイルドカードの展開に `..' を含めない
     (setq eshell-ls-exclude-regexp "~\\'")
     (setq eshell-directory-name (locate-user-emacs-file "eshell"))
     (setq eshell-history-file-name (concat eshell-directory-name "/eshell_history"))
     (setq eshell-history-size 200000)
     (setq eshell-ask-to-save-history nil)
     ;; (eshell-complete-hostname eshell-host-names)
     (setq eshell-prompt-function
           #'(lambda () (concat (eshell/pwd)
                                (if (= (user-uid) 0) "# " "$ "))))
     (setq eshell-hist-rebind-keys-alist
           '(([(control ?a)]   . eshell-bol)
             ([(control ?e)]   . end-of-line)
             ([(control ?p)]   . eshell-previous-matching-input-from-input)
             ([(control ?n)]   . eshell-next-matching-input-from-input)
             ([(control up)]   . eshell-previous-input)
             ([(control down)] . eshell-next-input)
             ([(control u)]    . my-eshell-erase-command-line)
             ([(control ?r)]   . eshell-isearch-backward)
             ([(control ?s)]   . eshell-isearch-forward)
             ([(meta ?r)]      . eshell-previous-matching-input)
             ([(meta ?s)]      . eshell-next-matching-input)
             ([(meta ?p)]      . eshell-previous-matching-input-from-input)
             ([(meta ?n)]      . eshell-next-matching-input-from-input)
             ([up]             . eshell-previous-matching-input-from-input)
             ([down]           . eshell-next-matching-input-from-input)))))


;;; shell-command completion

;; <http://namazu.org/~tsuchiya/elisp/shell-command.el>

(when (require 'shell-command nil t)
  (shell-command-completion-mode 1))


;;; YAML

;; yaml-mode
;; <http://yaml-mode.clouder.jp/>
;;
;; % svn co http://svn.clouder.jp/repos/public/yaml-mode/trunk yaml-mode

;; (setq load-path (cons "~/.emacs.d/yaml-mode" load-path))
;; (require 'yaml-mode)


;;; Mew (E-mail client)

;; (autoload 'mew "mew" nil t)
;; (autoload 'mew-send "mew" nil t)
;; (setq mew-icon-directory "/usr/share/pixmaps/mew"))
;; ;; Mew theme:
;; (setq mew-theme-file "~/.emacs-themes/mew-theme.el")


;;; w3m

;; (require 'w3m-load)

;; (setq w3m-add-referer 'lambda)

;; (add-hook 'w3m-mode-hook
;;           #'(lambda ()
;;             (setq line-spacing 5)))

(eval-after-load "w3m"
  '(progn
     (define-key w3m-mode-map "j" #'(lambda () (scroll-up 1)))
     (define-key w3m-mode-map "k" #'(lambda () (scroll-down 1)))
     (define-key w3m-mode-map "n" 'w3m-next-anchor)
     (define-key w3m-mode-map "p" 'w3m-previous-anchor)
     (define-key w3m-mode-map [(meta left)] 'w3m-view-previous-page)
     (define-key w3m-mode-map [(meta right)] 'w3m-view-next-page)
     (define-key w3m-mode-map [down] 'next-line)
     (define-key w3m-mode-map [left] 'backward-char)
     (define-key w3m-mode-map [right] 'forward-char)
     (define-key w3m-mode-map [up] 'previous-line)))


;;; minibuf-isearch

;; - <http://www.sodan.org/~knagano/emacs/minibuf-isearch/>
;; - <http://www.sodan.org/~knagano/emacs/minibuf-isearch/minibuf-isearch.el>

(add-to-load-path (locate-user-emacs-file "minibuf-isearch"))

(require 'minibuf-isearch)


;;; Emacs Server / emacsclient / emacs --daemon

(require 'server)

(unless (server-running-p)
  (server-start))


;;; browse-kill-ring

;; Usage: `M-x browse-kill-ring'
(require 'browse-kill-ring)


;;; ibuffer.el

(require 'ibuffer)


;;; Buffer Menu

;; (define-key global-map "\C-x\C-b" 'electric-buffer-list)
;; (eval-after-load "ebuff-menu"
;;   (function #'(lambda ()
;;               (define-key electric-buffer-menu-mode-map "x"
;;                 'Buffer-menu-execute))))


;;; Buffer Name Uniquify

(require 'uniquify)

(setq uniquify-buffer-name-style 'post-forward-angle-brackets)


;;; Furigana Markup Helper

;; Author: MORIYAMA Hiroshi

;; (require 'furigana)
;; (global-set-key "\C-cr" #'furigana-markup)
;; (global-set-key "\C-cR" #'furigana-markup-region)


;;; Migemo

;; MEMO: 生成された正規表現が長過ぎるとEmacsが 21クラッシュした。たし
;; かEmacs自身のバグだったか。Migemoに責任は無かったと思ふ。詳しいこと
;; は忘れた。
;;
;; (if (require 'migemo nil t)
;;     ()
;;   (message "Filed load migemo."))
;; migemo-process
;; (migemo-init)
;; test: eS


;;; Bookmarks

(setq bookmark-bmenu-file-column 60)


;;; underscore-region, camelcase-region

(defun my-underscore (obj)
  ;; Created: 2008-05-11
  "Example:
  (my-underscore \"FooBarName\")
   => \"foo_bar_name\""
  (let ((case-fold-search nil))
    (downcase
     (replace-regexp-in-string
      "-" "_" (replace-regexp-in-string "\\([^-_A-Z]\\)\\([A-Z]\\)"
                                        "\\1_\\2" obj t)))))

(defun my-camelcase (obj)
  ;; Created: 2008-05-11
  "Example:
  (my-camelcase \"foo_bar_name\")
   => \"FooBarName\""
  (let ((case-fold-search nil))
    (replace-regexp-in-string
     "[_\-]" ""
     (capitalize (replace-regexp-in-string
                  "\\([^A-Z]\\)\\([A-Z]\\)" "\\1_\\2" obj t)))))

(defun my-underscore-region (start end)
  ;; Created: 2008-05-11
  (interactive "r")
  (let (newtext)
    (setq newtext (my-underscore (buffer-substring-no-properties start end)))
    (save-excursion
      (delete-region start end)
      (goto-char start)
      (insert newtext))))

(defun my-camelcase-region (start end) ;for Ruby scripts.
  ;; Created: 2008-05-11
  (interactive "r")
  (let (newtext)
    (setq newtext (my-camelcase (buffer-substring-no-properties start end)))
    (save-excursion
      (delete-region start end)
      (goto-char start)
      (insert newtext))))


;;; Haskell

(when (load "haskell-site-file" t)
  (add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
  (add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
  ;;(add-hook 'haskell-mode-hook 'turn-on-haskell-simple-indent)
  (add-hook 'haskell-mode-hook 'font-lock-mode))


;;; log-edit-mode

(add-hook 'log-edit-mode-hook
  #'(lambda ()
      (setq fill-column 68)
      (set (make-local-variable 'adaptive-fill-mode) nil)))


;;; VC (version control)

;; MEMO: これ、defadviceではダメなのか? (2012-06-25)

(defun my-vc-diff (arg &optional opt-arg)
  "コマンド `vc-diff' のラッパー。`vc-diff' は呼出した diff-modeの
ウインドウを選擇するが、此のコマンドでは呼出元のウインドウを選擇し
直す。diff-modeのウインドウのスクロールは M-C-v 及び M-C-S-v で可
能。"
  (interactive (list current-prefix-arg t))
  (let ((win (selected-window)))
    (vc-diff arg opt-arg)
    (select-window win)))

(define-key global-map "\C-xv=" 'my-vc-diff)


;;; vc-arch

(when (require 'vc-arch nil t)
  ;; `vc-arch-checkin' was copied from `vc-arch.el' in GNU Emacs 23.0.60.18.
  ;;
  ;; ChangeLog:
  ;;
  ;; 2008-10-02T18:03:43+09:00  MORIYAMA Hiroshi  <hiroshi@kvd.biglobe.ne.jp>
  ;;
  ;;  * 現在バッファのファイルだけコミットするのではなく、プロジェクト
  ;;    ツリー全體をコミットするやうにした。
  ;;
  (defun vc-arch-checkin (files rev comment)
    (if rev (error "Committing to a specific revision is unsupported"))
    (let ((summary (file-relative-name (car files) (vc-arch-root (car files)))))
      ;; Extract a summary from the comment.
      (when (or (string-match "\\`Summary:[ \t]*\\(.*[^ \t\n]\\)\\([ \t]*\n\\)*" comment)
                (string-match "\\`[ \t]*\\(.*[^ \t\n]\\)[ \t]*\\(\n?\\'\\|\n\\([ \t]*\n\\)+\\)" comment))
        (setq summary (match-string 1 comment))
        (setq comment (substring comment (match-end 0))))
      (vc-arch-command nil 0 nil "commit" "-s" summary "-L" comment
                       (vc-switches 'Arch 'checkin)))))


;;; vc-git

(defun my-git-version ()
  (with-temp-buffer
    (call-process-shell-command "git" nil (current-buffer) nil "--version")
    (goto-char (point-min))
    (re-search-forward "[0-9.]+" nil t)
    (match-string-no-properties 0)))

(eval-after-load "vc-git"
  '(progn
     (setq git-commits-coding-system my-default-coding-sytem)
     (when (string< (my-git-version) "1.5")
       (defun vc-git-diff (files &optional rev1 rev2 buffer)
         ;; This function based on `vc-git-diff' of GNU Emacs 23.0.60.15.
         ;; Removed "--exit-code" option, for fix a bug in git version
         ;; 1.5.
         (let ((buf (or buffer "*vc-diff*")))
           (if (and rev1 rev2)
               (vc-git-command buf 1 files "diff-tree" "-p" rev1 rev2 "--")
             (vc-git-command buf 1 files "diff-index"
                             "-p" (or rev1 "HEAD") "--")))))))


;;; sh-mode

(add-hook 'sh-mode-hook
  #'(lambda ()
      (setq tab-width 2)
      (setq sh-basic-offset 2)
      (setq sh-indent-comment t)))

(add-to-list 'auto-mode-alist '("/[a-z]?profile\\'" . sh-mode))
;; Bash
(add-to-list 'auto-mode-alist '("/\\.?bashrc\\'" . sh-mode))
(add-to-list 'auto-mode-alist '("/\\.bash\\'" . sh-mode))
;; Zsh
(add-to-list 'auto-mode-alist '("\\.zsh\\'" . sh-mode))
(setq auto-mode-alist
      (append `((,(concat "\\`" (getenv "HOME") "/zsh/_.+\\'") . sh-mode))
              auto-mode-alist))


;;; Lisp

;; ファイル一行目の一文字目が `;' (Lispのコメント開始文字)であるバッファ
;; をLispコードと見做す。magic-mode-alist で之を設定するとEmacs Lispも
;; lisp-mode になつてしまふので、fundamental-mode をフックする:
(add-hook 'fundamental-mode-hook
  #'(lambda ()
      (if (and (numberp (buffer-size))
               (> (buffer-size) 0)
               (string= (buffer-substring-no-properties (point-min) 2) ";"))
          (lisp-mode))))

;; SXML
(setq auto-mode-alist (cons '("\\.sxml\\'" . lisp-mode) auto-mode-alist))

(put 'font-lock-add-keywords 'lisp-indent-hook 'defun)


;;; Emacs Lisp

(add-hook 'emacs-lisp-mode-hook
  #'(lambda ()
      (outline-minor-mode 1)
      ;; 全ての括弧を閉ぢる;
      (if (commandp 'slime-close-all-parens-in-sexp)
          (local-set-key [(ctrl c) (ctrl \])]
                         #'slime-close-all-parens-in-sexp))
      ;; Lisp mode with SLIMEのやうに `C-c TAB' で補完:
      (local-set-key [(ctrl c) tab] 'completion-at-point)
      (local-set-key "\C-c\C-r" #'eval-region)))

;; インデントが深くなり勝ちなので、名前に "add-" を含む函數(`add-hook'等)の
;; 字下げスタイルを `defun' と同じにする。
(do-symbols (sym)
  (if (and (fboundp sym)
           (string-match "\\(?:^\\|[-:_]\\)add-" (symbol-name sym)))
      (put sym 'lisp-indent-hook 'defun)))

;;;; Highlighting `cl' functions

;; Usage:
;; "cl の関数に色を付けてくれる highlight-cl.el を作ったよ - 適当めも"
;; <http://d.hatena.ne.jp/buzztaiki/20090403/1238791522>
;;
;; Download:
;; <http://www.emacswiki.org/emacs/download/highlight-cl.el>
;;
(when (load "highlight-cl/highlight-cl.elc" t)
  (add-hook 'emacs-lisp-mode-hook #'highlight-cl-add-font-lock-keywords)
  (add-hook 'lisp-interaction-mode-hook #'highlight-cl-add-font-lock-keywords))


;;; Common Lisp

;; Related files:
;;   File ~/.config/common-lisp/source-registry.conf.d/01-add-local-lisp.conf

;; (load "cl-indent")

;; (eval-after-load "cl-indent"
;;   '(progn
;;      (add-hook 'lisp-mode-hook
;;                #'(lambda ()
;;                    (if (fboundp 'common-lisp-indent-function) ;`cl-indent.el'
;;                        (set (make-local-variable lisp-indent-function)
;;                             #'common-lisp-indent-function))))
;;      ;; backquoted listのインデントを、通常のリストと同じにする:
;;      (setq lisp-backquote-indentation nil)   ;`cl-indent.el'
;;      ;; LOOPマクロのインデント幅:
;;      (setq lisp-loop-keyword-indentation 6)  ;`cl-indent.el'
;;      (setq lisp-loop-forms-indentation 5)    ;`cl-indent.el'
;;      (setq lisp-simple-loop-indentation 3)   ;`cl-indent.el'
;;      ;;
;;      ;; for CL-TEST-MORE:
;;      (put 'deftest 'common-lisp-indent-function 1)))

(put 'defsystem 'lisp-indent-function 2)


;;; Quicklisp

(defcustom my-quicklisp-directory
  (expand-file-name "~/.quicklisp/")
  "Quicklisp directory."
  :group 'my)


;;; SLIME

(defun my-sort-by-desc (strings)
  (sort strings #'(lambda (s1 s2) (not (string-lessp s1 s2)))))

(defun my-slime-directory (&optional skip-quicklisp skip-user-emacs-directory)
  "システムにインストールされてゐる中でヴァージョンが一番新しいと
思はれるSLIMEのディレクトリ名を返す(注意: 新しい「と思はれるもの」
であつて實際にヴァージョンを見てはゐない)。

SLIMEのインストールディレクトリが見附からなければ nil を返す。"
  (my-normalize-pathname
   (or
    ;; Quicklisp.
    (unless (or skip-quicklisp
                skip-user-emacs-directory
                (string-match (regexp-opt (list (expand-file-name
                                                 user-emacs-directory)))
                              (expand-file-name my-quicklisp-directory)))
      (when-directory-p (dir (concat my-quicklisp-directory
                                     "dists/quicklisp/software/"))
        (nth 0 (my-sort-by-desc
                (directory-files dir t "\\`slime-[0-9]+-cvs\\'")))))
    ;; ~/.emacs.d/slime
    (unless skip-user-emacs-directory
      (when-directory-p (dir (concat user-emacs-directory "slime")) dir)
      (when-directory-p (dir (concat user-emacs-directory "slime-cvs")) dir)
      ;; ~/.emacs.d/slime-NNNN
      (when-directory-p (dir user-emacs-directory)
        (nth 0 (my-sort-by-desc
                (directory-files dir t "\\`slime\\(?:-[-_.0-9]+\\)?\\'")))))
    ;; System directories.
    (when-directory-p (dir "/opt/slime") dir)
    (when-directory-p (dir "/usr/local/share/emacs/site-lisp/slime/") dir)
    (when-directory-p (dir "/usr/share/emacs/site-lisp/slime/") dir))
   t))

(add-to-load-path (my-slime-directory 'skip-quicklisp
                                      'skip-user-emacs-directory))

(require 'slime-autoloads nil t)

(defcustom my-slime-repl-frame-parameters
  `((width . 70)
    (height . 50)
    (top . (+ 0))
    (left . (- 0))
    (user-position . t)
    (minibuffer . nil))
  "`slime' のREPLバッファを表示するフレームのパラメータ(聯想配列)。"
  :group 'my)

(defun my-get-slime-repl-buffer ()
  "`*slime-repl*' バッファが存在してゐればそのバッファを、さもなくば
nil を返す。"
  (get-buffer-with-predicate #'(lambda (b)
                                 (string-match
                                  "\\`\\*slime-repl .+?\\(?:<[0-9]+>\\)?\\*\\'"
                                  (buffer-name b)))))
(defun my-slime-repl-frame-list ()
  "タイトルが \"*slime-repl <CL-IMPLEMENTATION-NAME>*\" であるフレー
ムのリストを返す。"
  (remove nil
          (mapcar #'(lambda (frame)
                      (let ((title (cdr (assoc 'name (frame-parameters frame)))))
                        (if (and (stringp title)
                                 (string-match "\\*slime-repl .+?\\*"
                                               title))
                            frame)))
                  (frame-list))))

(defadvice slime (around slime-in-repl-frame)
  "新規フレームにREPLバッファを開く。既にREPLが起動し接續状態にあ
る場合は、REPLフレームにフォーカスし、REPLのバッファを表示する。"
  (let ((repl-frame (car (my-slime-repl-frame-list)))
        (repl-buffer (my-get-slime-repl-buffer)))
    (cond
     ;; 既にREPLに接續してをり、*slime-repl* バッファも存在する:
     ((and (slime-connected-p) repl-buffer)
      (select-frame-set-input-focus
       (or repl-frame (make-frame my-slime-repl-frame-parameters)))
      (switch-to-buffer repl-buffer))
     ;; REPLに接續されてゐるが、*slime-repl* バッファが存在しない:
     ((and (slime-connected-p) (not repl-buffer))
      (select-frame-set-input-focus
       (or repl-frame (make-frame my-slime-repl-frame-parameters)))
      ad-do-it)
     ;; REPLに接續されてゐない:
     (t
      (save-current-buffer
        (save-current-frame
          (select-frame (or repl-frame
                            (make-frame my-slime-repl-frame-parameters)))
          (if repl-buffer
              (switch-to-buffer repl-buffer)
            ad-do-it
            (if (>= (length (window-list)) 2)
                (delete-other-windows)))))))))

(defadvice slime-restart-inferior-lisp (around focus-slime-repl-frame)
  "\"*slime repl*\" フレームが存在してゐたら、そのフレームに切替へ
てから `slime-restart-inferior-lisp' を實行する。フレームが無かつ
たら新規に作る。restart後、元のフレームに戻る。但し呼出し時のフレー
ムが \"*slime repl*\" フレームであつたならフレーム移動はしない。"
  (let ((previous-frame (selected-frame))
        (previous-buffer (current-buffer)))
    (unless (eql (current-buffer) (my-get-slime-repl-buffer))
      (switch-to-buffer-other-frame (my-get-slime-repl-buffer)))
    ad-do-it
    (unless (eql (selected-frame) previous-frame)
      (switch-to-buffer-other-frame previous-buffer))))

(defadvice slime-repl-sayoonara (after delete-repl-frames)
  (let ((repl-frames (my-slime-repl-frame-list)))
    (dolist (frame repl-frames)
      (if frame
          (delete-frame frame)))))

(defadvice eval-buffer (around smart-eval-buffer
                               (&optional buffer printflag
                                          filename unibyte do-allow-print))
  "`eval-buffer' をEmacs LispモードとLispモード(SLIME)の兩方に對應
させるアドヴァイス。Emacs Lispモードでは通常の `eval-buffer' を、
Lispモードでは `slime-eval-buffer' を實行する。"
  (if (save-excursion
        (and (fboundp 'slime-eval-buffer)
             (or (and buffer (switch-to-buffer buffer))
                 t)
             (eql major-mode #'lisp-mode)))
      (slime-eval-buffer)
    ad-do-it))

(defadvice eval-region (around smart-eval-region (start end &optional printflag
                                                        read-function))
  "`eval-region' をEmacs LispモードとLispモード(SLIME)の両方に対応
させる。Emacs Lispモードでは `eval-region' を、Lispモードでは
`slime-eval-region' を実行する。"
  (if (and (eql major-mode #'lisp-mode)
           (fboundp 'slime-eval-buffer))
      (slime-eval-region start end)
    ad-do-it))

(defadvice eval-defun (around smart-eval-defun)
  "`eval-defun' をEmacs LispモードとLispモード(SLIME)の兩方に對應
させるアドヴァイス。Emacs Lispモードでは通常の `eval-defun' を、
Lispモードでは `slime-eval-defun' を實行する。"
  (if (and (eql major-mode #'lisp-mode)
           (fboundp 'slime-eval-defun))
      (slime-eval-defun)
    ad-do-it))

(defadvice slime-eval-last-expression (around start-swank-server-if-not-started)
  "SWANKサーバーが接續されてゐなければ eval せずに `slime' を實行する。"
  (if (slime-connected-p)
      ad-do-it
    ;;TODO: `slime-connected-hook' を使って接続後に自動的に
    ;;`slime-eval-last-expression' を継続する。
    (slime)))

(eval-after-load "slime"
  '(defun slime-clisp ()
     (interactive)
     (let ((slime-lisp-implementations nil)
           (inferior-lisp-program "clisp"))
       (slime))))

(eval-after-load "slime"
  '(defun slime-sbcl ()
     (interactive)
     (let ((slime-lisp-implementations nil)
           (inferior-lisp-program "sbcl"))
       (slime))))

(eval-after-load "slime"
  '(defun slime-ccl ()
     (interactive)
     (let ((slime-lisp-implementations nil)
           (inferior-lisp-program "ccl"))
       (slime))))

(defadvice slime-space (around my-avoid-key-binding-conflict-with-input-method
                               (arg) disable)
  "入力方式(input method)の變換開始とのキー束縛衝突を回避する。"
  (cond
   ;; DDSKK
   ((and (boundp 'skk-henkan-mode)
         skk-henkan-mode)
    (skk-insert arg))
   ;; anthy.el
   ((and (boundp 'anthy-preedit-keymap)
         (eql (cdr (assoc 'anthy-minor-mode minor-mode-map-alist))
              anthy-preedit-keymap))
    (anthy-handle-key 32 (anthy-encode-key 32)))
   (t
    ad-do-it)))

(eval-after-load "slime"
  '(progn
     (defalias 'slime-sayonara 'slime-repl-sayoonara)
     (setq slime-startup-animation nil)
     (setq slime-kill-without-query-p t)
     (setq slime-net-coding-system 'utf-8-unix)
     ;; Indentation
     ;;
     (setq lisp-backquote-indentation t)
     (setq common-lisp-style-default 'modern)
     ;; MEMO: `slime-lisp-implementations' に定義された處理系は
     ;; `M- M-x slime' で選ぶことが出來る。`M-' を附けなかつた場合はリスト先頭
     ;; の定義が使用される。
     ;;
     (setq slime-lisp-implementations
           (let ((imples '())
                 (candidates `((ccl ("ccl") :coding-system ,slime-net-coding-system)
                               (sbcl ("sbcl") :coding-system ,slime-net-coding-system)
                               (clisp ("clisp") :coding-system ,slime-net-coding-system)
                               (abcl ("abcl") :coding-system ,slime-net-coding-system)
                               (gcl ("gcl") :coding-system ,slime-net-coding-system)
                               (cmucl ("cmucl") :coding-system ,slime-net-coding-system))))
             (dolist (impl candidates)
               (if (executable-find (car (car (cdr impl))))
                   (setq imples (cons impl imples))))
             (reverse imples)))
     (setq inferior-lisp-program nil)   ;`C-u M-x slime' したときのデフォルト値
     ;; Activate advices
     ;;
     (ad-activate 'slime)
     (ad-activate 'slime-restart-inferior-lisp)
     (ad-activate 'slime-repl-sayoonara)
     (ad-activate 'eval-buffer)
     (ad-activate 'eval-region)
     (ad-activate 'eval-defun)
     (ad-activate 'slime-eval-last-expression)
     ;; Hooks
     ;;
     (add-hook 'kill-emacs-hook #'(lambda ()
                                    (when (slime-connected-p)
                                      (slime-repl-sayoonara))))
     ;;
     (slime-setup '(slime-asdf slime-fancy slime-indentation))))


;;; HyperSpec

(defcustom my-hyperspec-directory
  (let ((pathnames '("/opt/HyperSpec/usr/share/doc/hyperspec/HyperSpec/"
                     "/usr/local/share/doc/hyperspec/HyperSpec/"
                     "/usr/share/doc/hyperspec/HyperSpec/"))
        result)
    (while (and pathnames (not result))
      (let ((pathname (car pathnames)))
        (if (file-directory-p pathname)
            (setq result pathname)
          (setq pathnames (cdr pathnames)))))
    result)
  "HyperSpecドキュメントのディレクトリ。"
  :type 'string
  :group 'my)

(when (and my-hyperspec-directory
           (require 'hyperspec nil t))
  (setq common-lisp-hyperspec-root (concat "file://" my-hyperspec-directory))
  (setq common-lisp-hyperspec-symbol-table (concat my-hyperspec-directory
                                                   "Data/Map_Sym.txt"))
  (setq my-hyperspec-lookup-orig #'hyperspec-lookup)
  (defun hyperspec-lookup-by-w3 (symbol-name)
    (let ((browse-url-browser-function #'browse-url-w3))
      (funcall my-hyperspec-lookup-orig "symbol-name"))))

(define-key 'help-command "h" #'hyperspec-lookup)


;;; Scheme

(defun my-set-scheme-indent-function-gauche ()
  (put 'match 'scheme-indent-function 1)
  (put 'parameterize 'scheme-indent-function 1)
  (put 'parse-options 'scheme-indent-function 1)
  (put 'receive 'scheme-indent-function 2)
  (put 'rxmatch-case 'scheme-indent-function 1)
  (put 'rxmatch-cond 'scheme-indent-function 0)
  (put 'rxmatch-if  'scheme-indent-function 2)
  (put 'rxmatch-let 'scheme-indent-function 2)
  (put 'syntax-rules 'scheme-indent-function 1)
  (put 'unless 'scheme-indent-function 1)
  (put 'until 'scheme-indent-function 1)
  (put 'when 'scheme-indent-function 1)
  (put 'while 'scheme-indent-function 1)
  (put 'with-builder 'scheme-indent-function 1)
  (put 'with-error-handler 'scheme-indent-function 0)
  (put 'with-error-to-port 'scheme-indent-function 1)
  (put 'with-input-conversion 'scheme-indent-function 1)
  (put 'with-input-from-port 'scheme-indent-function 1)
  (put 'with-input-from-process 'scheme-indent-function 1)
  (put 'with-input-from-string 'scheme-indent-function 1)
  (put 'with-iterator 'scheme-indent-function 1)
  (put 'with-module 'scheme-indent-function 1)
  (put 'with-output-conversion 'scheme-indent-function 1)
  (put 'with-output-to-port 'scheme-indent-function 1)
  (put 'with-output-to-process 'scheme-indent-function 1)
  (put 'with-output-to-string 'scheme-indent-function 1)
  (put 'with-port-locking 'scheme-indent-function 1)
  (put 'with-string-io 'scheme-indent-function 1)
  (put 'with-time-counter 'scheme-indent-function 1)
  (put 'with-signal-handlers 'scheme-indent-function 1)
  (put 'with-locking-mutex 'scheme-indent-function 1)
  (put 'guard 'scheme-indent-function 1)
  (put 'let1 'scheme-indent-function 2)
  (put 'let-keywords 'scheme-indent-function 2)
  (put 'let-keywords* 'scheme-indent-function 2))

(require 'scheme)

;; (autoload 'scheme-mode "cmuscheme" "Major mode for Scheme." t)
;; (autoload 'run-scheme "cmuscheme" "Run an inferior Scheme process." t)
(setq scheme-program-name "gosh -i")
(add-hook 'scheme-mode-hook
  #'(lambda ()
      (local-set-key "\C-x\C-e" #'my-scheme-eval-last-sexp)
      ;; Gauche
      (font-lock-add-keywords nil
        '(("\\<parameterize\\>" . font-lock-keyword-face)
          ("\\<guard>\\>" . font-lock-keyword-face)
          ("\\<when\\>" . font-lock-keyword-face)
          ("\\<while\\>" . font-lock-keyword-face)
          ("\\<until\\>" . font-lock-keyword-face)
          ("\\<unless\\>" . font-lock-keyword-face)
          ("\\<let1\\>" . font-lock-keyword-face)
          ("\\<let-keywords\\*?\\>" . font-lock-keyword-face)
          ;; Common Lisp
          ("\\<dotimes\\>" . font-lock-keyword-face)
          ("\\<dolist\\>" . font-lock-keyword-face)))
      (my-set-scheme-indent-function-gauche)
      ;; User defined forms:
      (put 'dolist-with-index 'scheme-indent-function 1)
      (put 'with-db 'scheme-indent-function 1)))

(defun my-get-scheme-buffer-create ()
  (if (null (get-buffer (or scheme-buffer "*scheme*")))
      (let ((pop-to-buffer-orig (symbol-function 'pop-to-buffer)))
        (fset 'pop-to-buffer #'(lambda (arg) arg))
        (run-scheme scheme-program-name)
        (fset 'pop-to-buffer pop-to-buffer-orig)
        (accept-process-output (scheme-proc))))
  (get-buffer scheme-buffer))

(defun my-scheme-eval-last-sexp ()
  (interactive)
  (let ((sexp (my-last-sexp-string)))
    (set-buffer (my-get-scheme-buffer-create))
    (let ((begin (marker-position (process-mark (scheme-proc))))
          (proc-mark (process-mark (scheme-proc))))
      (process-send-string (scheme-proc) (concat sexp "\n"))
      (while (or (not (accept-process-output (scheme-proc) 0 100))
                 (not (string-match "^[^>]*> "
                                    (buffer-substring-no-properties
                                     (- proc-mark 2) proc-mark)))))
      (message "%s" (buffer-substring-no-properties
                     begin (save-excursion
                             (goto-char (process-mark (scheme-proc)))
                             (forward-line -1)
                             (point-at-eol)))))))

(defun my-popup-scheme-window ()
  (interactive)
  (let ((pop-up-windows t))
    (pop-to-buffer (get-buffer-create "*scheme*") t)
    (run-scheme scheme-program-name)
    (enlarge-window (- (/ (frame-height) 4)))
    (goto-char (point-max))
    (other-window -1)))

;; Gauche.
(add-to-list 'interpreter-mode-alist '("gosh" . scheme-mode))
(add-to-list 'interpreter-mode-alist '("gauche" . scheme-mode))


;;; view-mode

(add-hook 'view-mode-hook
  #'(lambda ()
      (define-key view-mode-map "b" #'scroll-down)
      (define-key view-mode-map " " #'scroll-up)))

;; Do not iconify on window system.
(when window-system
  (global-unset-key "\C-z")
  (global-unset-key "\C-x\C-z"))


;;; seijiseikana-el

;; <https://github.com/moriyamahiroshi/seijiseikana-el>

(add-to-list 'load-path (expand-file-name "~/.emacs.d/seijiseikana-el"))

(require 'seijiseikana)

(defadvice save-buffer (before seiji-buffer-when-save activate)
  "!! EXPERIMENTAL 實驗的 間違つた變換が少くないので非推奬。

特定のファイルを保存するとき自動的に正字化する。"
  (let ((targets '("/seijiseikana-project/.+\\.html" ;正字正かなプロジェクトのウェブページ。
                   "/\\.hatena/[0-9]+$" ;はてなダイアリーソース。
                   )))
    (save-excursion
      (save-restriction
        (save-match-data
          (let (re)
            (while (setq re (car targets))
              (when (string-match re (or (buffer-file-name) ""))
                (setq targets nil)
                (widen)
                (seijiseikana-seiji-region (point-min) (point-max)))
              (setq targets (cdr targets)))))))))


;;; 日本語の文字と文字の間にある改行文字を削除するEmacs Lisp函數

;; 分ち書きをしない用字系(日本語)なのに、その文字と文字の間に存在する改行
;; を空白にして表示してしまふHTMLレイアウトエンジンを考慮したHTML文書用テ
;; キスト置換コード。`hatena-diary-mode-submit-hook' などのフック變數にセッ
;; トし、手元のソースには改行を殘すといふ使ひ方をする。

;; TODO: 現在はPRE要素内の改行を削除しないために、"seijiseikana-el"
;; <https://github.com/moriyamahiroshi/seijiseikana-el/blob/4ba1bdff1d850987286f7d039bb3124a3a6097bc/seijiseikana.el>
;; に含まれてゐる函數 `seijiseikana-point-inside-sgml-element-p' に依存し
;; てゐる。あの邊りのコードはいづれ別のパッケージに獨立させよう。

(defun remove-obstructive-newlines-ja (start end)
  (interactive "r")
  (save-excursion
    (save-restriction
      (save-match-data
        (goto-char (point-min))
        (while (re-search-forward
                (concat "\\([一-龠ぁ-🈀ァ-𛀀ー・、。「」『』]\\)"
                        "\n\\([一-龠ぁ-🈀ァ-𛀀ー・、。「」『』]\\)") nil t)
          (unless (seijiseikana-point-inside-sgml-element-p "PRE")
            (replace-match (concat (match-string 1) (match-string 2)))))))))


;;; Hatena Diary Mode Settings

;; Note: 2012-07-15現在、森山ひろしのマイクロWeb日記 on Hatena::Diary
;; <http://d.hatena.ne.jp/mhrs/> の形式に最適化されてをり汎用性は無い。

(add-to-load-path (locate-user-emacs-file "hatena-diary-mode"))

(require 'hatena-diary-mode)

;;;; auto insert

(defun my-auto-insert-micro-web-nikki-on-hatena-diary ()
  (save-match-data
    (insert-file-contents (concat auto-insert-directory
                                  "/hatena-diary.ja.html.utf8"))
    ;; タイトルに日附を足す。
    (when (re-search-forward "<title>" nil t)
      (let ((filename (buffer-file-name)))
        (if (and filename
                 (string-match (concat "/\\.hatena/\\([1-9][0-9]\\{3\\}\\)"
                                       "\\([0-9][0-9]\\)\\([0-9][0-9]\\)\\'")
                               filename))
            (insert (match-string 1 filename) "-"
                    (match-string 2 filename) "-"
                    (match-string 3 filename)
                    " - ")))
      (re-search-forward "<ol\\(?:\s+\\|[ \t\r\n]+[^>]+\\)?>\n" nil t))))

(setq auto-insert-alist
      (append
       '(("/\\.hatena/[1-9][0-9]\\{7\\}\\'" .
          my-auto-insert-micro-web-nikki-on-hatena-diary))
       auto-insert-alist))

;;;; Helper Functions for Hatena Diary Mode

(defun my-convert-html-buffer-for-hatena-diary ()
  "バッファ内容のマークアップ(HTML)をはてなダイアリー用に改變する。"
  (interactive)

  ;; ;; Call `tidy` command.
  ;; (tidy-clean-html-buffer)
  ;; ;; tidyが (改行)</code></pre> を (改行)</code>(改行)</pre> にしてしまふので修正:
  ;; (my-replace-string-buffer "\\(</[^>]+>\\)\\(\n\\)\\(</pre>\\)"
  ;;                           #'(lambda ()
  ;;                               (concat (match-string-no-properties 1)
  ;;                                       (match-string-no-properties 3))))

  ;; (goto-char (point-min))
  ;; (let ((body (buffer-substring
  ;;              (save-excursion (re-search-forward "<body\\(?:\s-[^>]*\\)?>[ \t\r\n]*"))
  ;;              (save-excursion (- (re-search-forward "</body>") (length "</body>"))))))
  ;;   (delete-region (point-min) (point-max))
  ;;   (insert body))

  ;; 二行以上の空行ははてなダイアリーが "<br>" に變換してしまふので、それ
  ;; らを取除く。
  (my-replace-string-buffer (concat "[ \t\r\n]+\\(</?"
                                    (regexp-opt '("h1" "h2" "h3" "h4" "h5" "h6"
                                                  "div" "blockquote" "hr"
                                                  "ol" "ul" "li"
                                                  "p" "pre"
                                                  "ins" "del") t)
                                    "\\(?:[ \t\r\n]\\|>\\)\\)")
                            #'(lambda () (concat "\n" (match-string-no-properties 1))))

  ;; 文書型宣言やTITLE要素などはてなダイアリーには不要なものを削除する。
  (my-replace-string-buffer "^[ \t]*<!DOCTYPE .+$" "")
  (my-replace-string-buffer "^[ \t]*<\\(?:meta\\|link\\) .+?>" "") ;empty element
  (my-replace-string-buffer "^[ \t]*<\\(?:meta\\|link\\) .+?>" "") ;empty element
  (my-replace-string-buffer "^[ \t]*<title>.*?</title>[\r\n]*" "")
  (my-replace-string-buffer "^[ \t]*<h1>.*?</h1>[\r\n]*" "")
  (my-replace-string-buffer "^[ \t]*<h2>.*?</h2>[\r\n]*" "")

  ;; バッファ先頭の空白類を削除する。
  (save-excursion
    (goto-char (point-min))
    (while (or (= (char-after) ?\ ) (= (char-after) ?\t)
               (= (char-after) ?\n) (= (char-after) ?\r))
      (delete-char 1)))

  ;; バッファ末尾の空白類を削除する。
  (save-excursion
    (goto-char (point-max))
    (while (or (= (char-before) ?\ ) (= (char-before) ?\t)
               (= (char-before) ?\n) (= (char-before) ?\r))
      (delete-char -1)))

  ;; 行末の空白類を削除する。
  (my-delete-trailing-whitespace)

  ;; はてなの「pタグ停止記法」(><ol> ... </ol><)を有効にする。
  (save-excursion
    (save-restriction
      (widen)
      (progn
        (goto-char (point-min))
        (if (looking-at "<ol\\(?:[ \t\r\n][^<>]*\\)?>")
            (insert ">")))
      (let ((end-tag "</ol>"))
        (goto-char (point-max))
        (when (re-search-backward end-tag nil t)
          (delete-char (length end-tag))
          (insert (concat end-tag "<"))))))

  (save-excursion
    (save-restriction
      (widen)
      (goto-char (point-min))
      (while (re-search-forward "^\\(<div class=\"section-body\">\\)[ \t]*$" nil t)
        (replace-match (concat ">\\1")))
      (goto-char (point-min))
      (while (re-search-forward "^</div>[ \t]*$" nil t)
        (replace-match (concat "</div><"))))))

;;;; Hatena Diary Mode Settings

(eval-after-load "hatena-diary-mode"
  '(progn
     (setq my-hatena-user-name "mhrs")
     (when (commandp 'hatena-logout)
       (add-hook 'kill-emacs-hook #'hatena-logout))
     (defconst my-hatena-diary-mode-font-lock-keywords
       '(("^\\(Title\\) \\(.*\\)$"
          (1 hatena-header-face t)
          (2 hatena-title-face t))
         ("\\(<[^\n/].*>\\)\\([^<>\n]*\\)\\(</.*>\\)"
          (1 hatena-html-face t)
          (2 hatena-link-face t)
          (3 hatena-html-face t))
         ("^\\(\\*[^\n ]*\\) \\(.*\\)$"
          (1 hatena-markup-face t)
          (2 hatena-html-face t))
         ("\\(\\[?\\(a:id\\|f:id\\|i:id\\|r:id\\|map:id\\|graph:id\\|g.hatena:id\\|b:id:\\|id\\|google\\|isbn\\|asin\\|http\\|http\\|ftp\\|mailto\\|search\\|amazon\\|rakuten\\|jan\\|ean\\|question\\|tex\\):\\(\\([^\n]*\\]\\)\\|[^ 　\n]*\\)\\)"
          (1 hatena-markup-face t))
         ("^:\\([^:\n]+\\):"
          (0 hatena-markup-face t)
          (1 hatena-link-face t))
         ("^\\([-+]+\\)"
          (1 hatena-markup-face t))
         ("\\(((\\).*\\())\\)"
          (1 hatena-markup-face t)
          (2 hatena-markup-Face T))
         ("^\\(>>\\|<<\\|><!--\\|--><\\|>\\(|.+\\)?|?|\\||?|<\\)"
          (1 hatena-markup-face t))
         ("\\(s?https?://\[-_.!~*'()a-zA-Z0-9;/?:@&=+$,%#\]+\\)"
          (1 hatena-html-face t)))
       "はてな記法の色附け削除用。")

     (defun-if-undefined hatena-kill-all ()
       (interactive)
       (hatena-exit))

     (defun-if-undefined hatena-relogin ()
       "再ログイン。

うまく行かないときもある。さういふときは ~/.hatena/Cookie@hatena
を削除してみる。"
       (interactive)
       (let ((cookie-file-name (expand-file-name (concat hatena-directory
                                                         "Cookie@hatena"))))
         (hatena-logout)
         (when (file-regular-p cookie-file-name)
           (delete-file cookie-file-name))
         (hatena-login)))

     (defun my-hatena-escape-hatena-markups (start end)
       "Escape Hatena markups."
       (my-replace-string-region "^+" "&#43;" start end) ;リスト記法
       ;;
       (my-replace-string-region "^-" "&#45;" start end) ;リスト記法
       (my-replace-string-region "^&#45;->" "-->" start end) ;HTMLのコメント閉ぢを元に戻す
       ;;
       (my-replace-string-region "((" "&#40;(" start end) ;脚註記法
       (my-replace-string-region "\\bid:\\([^\\b]+\\)" ;ID記法 (e.g. "こんにちはid:sampleさん")
                                 #'(lambda ()
                                     (concat "id&#58;" (match-string-no-properties 1)))
                                 start end))

     (defun my-hatena-abort-submit-if-buffer-narrowed ()
       "バッファがナローイン(ファイルの一部のみ表示)されてゐたら警
告し、はてなダイアリーへの送信を取止める。"
       (when (my-buffer-narrowed-p)
         (message (concat "Buffer is narrowed !\n"
                          "aborted submit. You can widening buffer "
                          "(M-x widen) and retry submit."))
         (return-from 'hatena-submit)))

     (setq hatena-change-day-offset 0)
     (setq hatena-entry-type 0)
     (setq hatena-trivial t) ;「ちょっとした更新」にするか否か。"C-c t" で切替。
     (setq hatena-usrid my-hatena-user-name)
     (setq hatena-plugin-directory
           (concat (user-emacs-directory) "hatena-mode/hatena-mode/"))

     ;; `hatena-diary-mode-hook': hatena-diary-mode起動時のフック。
     (add-hook 'hatena-diary-mode-hook
       #'(lambda ()
           (set (make-local-variable 'auto-insert-query) nil)
           (setq hatena-trivial t ;"ちょっとした更新"
                 sgml-basic-offset 2
                 tab-width sgml-basic-offset
                 indent-tabs-mode t)
           ;;
           ;; hatena-modeのfont-lockキーワードを削除する。hatena-modeの派生元
           ;; になつてゐるモード由來のfont-lockキーワードは消さないやうにする。
           (font-lock-remove-keywords nil my-hatena-diary-mode-font-lock-keywords)
           ;;
           ;; "C-c C-c" で日記送信、確認の問合せを "yes or no" にする。
           ;; (既定では "C-c C-p" で送信、問合せは "y or n"。)
           (local-unset-key "\C-c\C-p")
           (local-set-key "\C-c\C-c"
                          #'(lambda ()
                              (interactive)
                              (if (yes-or-no-p "Rellay send this diary ?")
                                  (hatena-submit))))))


     ;; `hatena-diary-mode-before-submit-hook': 日記がはてなダイアリーに送信さ
     ;; れる直前に實行されるフック。これによる變更はローカルファイルにも殘る。
     (setq hatena-diary-mode-before-submit-hook
           #'(lambda ()
               ;; バッファがナローインされてゐたら警告して送信を取止める。
               (my-hatena-abort-submit-if-buffer-narrowed)
               (message "Run hatena-diary-mode-before-sumit-hook.")
               ;; "%datetime%"を日附(W3C-DTF)に變換する。變換箇所が複數の場合、一
               ;; 個毎に時刻を一秒追加する。
               (let ((ct (current-time)))
                 (my-replace-string-buffer "%datetime%\\|<dt></dt>"
                                           #'(lambda ()
                                               ;; ct に一秒加算
                                               (rplaca (cdr ct) (1+ (car (cdr ct))))
                                               (let ((m (match-string 0)))
                                                 (replace-match
                                                  (iso-8601-w3c-dtf-string ct))))))
               ;; TwitterのURLから "#!/" を取除く。
               (save-excursion
                 (save-restriction
                   (save-match-data
                     (widen)
                     (goto-char (point-min))
                     (my-replace-string-buffer "\\(https://twitter.com/\\)#\\(?:!\\|%21\\)/\\([^/]+/status/\\)"
                                               #'(lambda ()
                                                   (concat (match-string 1)
                                                           (match-string 2)))))))
               ;; 空のID属性に値を設定する。
               (my-replace-string-buffer "id=\"\""
                                         #'(lambda ()
                                             (concat "id=\""
                                                     ;; ID属性の先頭はアルファベットでなければならない。
                                                     (let ((uuid (hm-uuid-string)))
                                                       (while (not (string-match "^[A-Z]" uuid))
                                                         (setq uuid (hm-uuid-string)))
                                                       (upcase uuid))
                                                     "\"")))))

     ;; `hatena-diary-mode-submit-hook': 日記がはてなダイアリーに送信される直前
     ;; に實行されるフック。これによる變更はローカルファイルには殘らない。
     (setq hatena-diary-mode-submit-hook
           #'(lambda ()
               ;; TODO: BLOCKQUOTEの開始タグを複数行に分けるとTITLE属性が
               ;; 消えるといふはてなダイアリーのバグ対策。
               ;; 例: <blockquote cite="http://www.example.com/"
               ;;                 title="Example Web Page">

               ;; (setq hatena-trivial t) ;常に必ず「ちょっとした更新」で送る。
               (widen)
               (html-mode)
               (my-convert-html-buffer-for-hatena-diary)
               (remove-obstructive-newlines-ja (point-min) (point-max))

               ;; はてなダイアリーによる自動リンクを回避するため http:// の ":"
               ;; を &#58; へ置換する。ただしタグの中(後方を見たときに > よりも先
               ;; に < が見える場所)では置換しない。
               ;;
               ;; 例:
               ;;     http://www.example.com/                       → http&#58;//www.example.com/
               ;;     a href="http://www.example.com:80/"              → a href="http&#58;//www.example.com&#58;/"
               ;;     <a href="http://www.example.com/">Example</a> → <a href="http://www.example.com/">Example</a>
               (my-replace-string-buffer
                "\\(https?\\|ftps?\\):"
                #'(lambda ()
                    (let ((start (match-beginning 0))
                          (protocol (match-string 1)))
                      (save-restriction
                        (save-match-data
                          (widen)
                          (if (save-match-data
                                (and (re-search-backward "[<>]" nil t)
                                     (string= (match-string 0) "<"))) ;inside a tag
                              (concat protocol ":")
                            (progn
                              (goto-char start)
                              (concat protocol "&#58;"))))))))

               ;; 屬性値以外の ":" をエスケープする(※不完全。たとへば
               ;; STYLE要素内のそれも變換してしまふ)。
               (save-excursion
                 (save-restriction
                   (save-match-data
                     (widen)
                     (goto-char (point-min))
                     (while (re-search-forward ":" nil t)
                       (when (save-match-data (eql (car (sgml-lexical-context)) 'text))
                         (replace-match "&#58;"))))))

               ;; title属性に含まれる ":" と "]" をエスケープする。
               (save-excursion
                 (save-restriction
                   (save-match-data
                     (widen)
                     (goto-char (point-min))
                     (while (re-search-forward "<[^>]+\\(title=\"[^\"]*\\(:\\|\\]\\)[^\">]*\"\\)" nil t)
                       (narrow-to-region (match-beginning 1) (match-end 1))
                       (my-replace-string-buffer ":" "&#58;")
                       (my-replace-string-buffer "]" "&#93;")
                       (widen)))))

               ;; Q要素のTITLE属性を取除く。
               (save-excursion
                 (save-restriction
                   (save-match-data
                     (widen)
                     (goto-char (point-min))
                     (while (re-search-forward "\\(<q[ \t\r\n][^>]*?\\)[ \t\r\n]*title=\"[^\"]*\"[ \t\r\n]*\\([^>]*>\\)" nil t)
                       (replace-match (concat (match-string 1) (match-string 2)))))))

               ;; url:スキームのURNを持つCITE属性を取除きコメントにする。
               (save-excursion
                 (save-restriction
                   (save-match-data
                     (widen)
                     (goto-char (point-min))
                     (while (re-search-forward (concat "\\(<q[ \t\r\n][^>]*?[ \t\r\n]*\\)"
                                                       "\\(cite=\"urn:[^\"]*\"[ \t\r\n]*\\)"
                                                       "\\([^>]*>\\)") nil t)
                       (replace-match (concat (match-string 1)
                                              (match-string 3)
                                              "<!-- " (match-string 2) " -->"))))))

               ;; 内容がISBNのTITLE屬性やHREF屬性をもとにして、はてなダイ
               ;; アリーの「ISBN記法」をHTMLコメントで書く(はてなダイアリー
               ;; の「ISBN記法」による關聯附けを有效にするため)。
               (save-excursion
                 (save-restriction
                   (save-match-data
                     (widen)
                     (goto-char (point-min))
                     (let ((semicolon-re "\\(?::\\|&#\\(?:58\\|x3[Aa]\\);\\)"))
                       (while (re-search-forward
                               (concat "\\(<[^<> \t\r\n]+[ \t\r\n][^>]*?[ \t\r\n]*\\)" ;1 = tagname and preceding attribute(s)
                                       "\\(\\(?:title\\|href\\)=\"" ;2 = TITLE or HREF attribute
                                       ;;
                                       "\\(" ;3 = attribute value
                                       "\\(?:"
                                       (regexp-opt '("http://calil.jp/book/"))
                                       "\\|urn\\(?::\\|&#\\(?:58\\|x3[Aa]\\);\\)isbn\\(?::\\|&#\\(?:58\\|x3[Aa]\\);\\)"
                                       "\\)" ;close 3rd paren
                                       ;;
                                       "\\([-0-9AZ]*\\)" ;4 = ISBN
                                       "\\)"
                                       ;;
                                       "\"[ \t\r\n]*\\)"
                                       "\\([^>]*>\\)")  ;5 = rest attributes
                               nil t)
                         (replace-match (concat (match-string 1)
                                                ;; Unescape semicolon.
                                                (replace-regexp-in-string "&#\\(?:58\\|x3[Aa]\\);" ":"
                                                                          (match-string 2))
                                                (match-string 5)
                                                "<!-- urn:isbn:"  (match-string 4) " -->"
                                                )))))))

               ;; U+FF5E (FULL WIDTH TILDE) を數値文字參照に變換する。
               ;; ～ U+FF5E FULL WIDTH TILDE
               ;; 〜 U+301C WAVE DASH
               (save-excursion
                 (save-restriction
                   (save-match-data
                     (widen)
                     (goto-char (point-min))
                     (my-replace-string-buffer "～" "&#xff5e;"))))

               ;; YEN SIGN
               (save-excursion
                 (save-restriction
                   (save-match-data
                     (widen)
                     (goto-char (point-min))
                     (my-replace-string-buffer "¥" "&yen;"))))

               ;; はてな記法を無効化。
               (my-hatena-escape-hatena-markups (point-min) (point-max))
               ;; EUC-JPで符號化できない文字をHTMLの數値文字參照に置替へる。
               (my-escape-to-numeric-character-references-region (point-min) (point-max) 'euc-jp)))

     ;; `hatena-diary-mode-after-submit-hook': 日記がはてなダイアリーに送信され
     ;; た後、送信が成功した場合に實行されるフック。送信したURLをフック函数の引
     ;; 数として渡す。
     (setq hatena-diary-mode-after-submit-hook
           #'(lambda (url)
               ;; はてなアンテナに更新を通知。
               (httpel-get-url "http://a.hatena.ne.jp/check?robots=1;fixpage=1;url=http://d.hatena.ne.jp/mhrs/")))))


;;; HTML Utils

(require 'my-html-escape)

;; `C-c h e': Html Escape.
(global-set-key "\C-che" #'my-html-escape-region)
;; `C-c h u e': Html UnEscape.
(global-set-key "\C-chue" #'my-html-unescape-region)


;;; Development

(add-to-list 'auto-mode-alist '("/\\.xscreensaver\\'" . conf-mode))


;;; Markdown

;; "Emacs markdown-mode" <http://jblevins.org/projects/markdown-mode/>
;; "markdown-mode.el" <http://jblevins.org/projects/markdown-mode/markdown-mode.el>

(when (require 'markdown-mode nil t)
  (add-to-list 'auto-mode-alist '("\\.m\\(arkdown\\|d\\)\\'" . markdown-mode))
  (add-hook 'markdown-mode
    #'(lambda ()
        (setq truncate-lines t))))


;;; Org-mode and remember-mode (memo/agenda/todo managiment utilities)

(when (require 'org-install nil t)
  (setq org-directory (expand-file-name "~/Documents/memo"))
  (setq org-default-notes-file "~/.notes")
  (add-to-list 'auto-mode-alist `(,(expand-file-name org-default-notes-file) . org-mode))
  (add-to-list 'auto-mode-alist '("\\.memo\\(\\'\\|\\.\\)" . org-mode))
  (add-to-list 'auto-mode-alist
    `(,(concat org-directory "/\\([^.]+\'\\|.+\\)\\.\\(txt\\|memo\\)\\(\\'\\|\\.\\)") . org-mode))
  ;; 空白類を除いて最初の文字が行頭の "*" であるバッファを org-mode にする:
  (add-to-list 'magic-mode-alist '("\\`\\*\\|\\`[ \t\r\n]+^\\*" . org-mode))
  ;; Key bindings:
  ;; (define-key global-map "\C-cl" 'org-store-link)
  ;; (define-key global-map "\C-ca" 'org-agenda)
  ;; Remenber mode:
  ;; (when (require 'remember nil t)
  ;;   (define-key global-map "\C-cr" 'org-remember))
  ;; TODO
  (setq org-todo-keywords
        '((sequence "TODO(t)" "WAIT(w)" "|" "DONE(d)" "SOMEDAY(s)")))
  ;; 起動時、セクションを折疊まない:
  (setq org-startup-folded nil)
  ;; DONEの時刻を記録
  (setq org-log-done 'time))

(when (require 'org-publish nil t)
  (setq org-export-default-language "ja")
  (add-to-list 'org-export-language-setup
    '("ja" "著者" "更新日時" "目次" "脚註"))
  (setq org-export-html-style-include-default nil)
  (setq org-export-html-style-include-scripts nil)
  (setq org-publish-project-alist
        '(("org-notes"
           :base-directory "~/org"
           :base-extension "org"
           :publishing-directory "~/public_html"
           :recursive t
           :publishing-function org-publish-org-to-html
           :headline-levels 4
           :auto-preamble t))))

(add-hook 'org-mode-hook
  #'(lambda ()
      ;; C-a/C-eを通常のコマンドに直す:
      (local-set-key "\C-a" #'beginning-of-line)
      (local-set-key "\C-e" #'end-of-line)))


;;; CSV


;;; Re-markup — Conversion HTML legacy markup to clean markup.

(defun my-remarkup-br-to-p (&optional limit-column)
  (interactive "P")
  (let ((limit-column (or limit-column 48)))
    (save-match-data
      (goto-char (point-min))
      (let ((previous-column (current-column))
            (previous-point (point)))
        (while (re-search-forward "<[Bb][Rr][\r\n\t\ ]*/?>" nil t)
          (let ((line (buffer-substring-no-properties previous-point (point))))
            (when (>= (string-width line) (- limit-column 2))
              ;; Remove BR tag:
              ;; TODO: line 末尾が句點文字や括弧であれば、との條件を追加する。
              (replace-match ""))
            (setq previous-column (string-width line)
                  previous-point (point))))))))

(defun my-remarkup-delete-non-wakati-newline-characters ()
  (interactive)
  (goto-char (point-min))
  (while (re-search-forward "\n" nil t)
    (backward-char 1)
    (delete-char 1)
    ;; 直前の文字が "?" か "!" であれば空白を追加する:
    (backward-char 1)
    (if (looking-at "\\([?？!！]\\)")
        (replace-match "\\1 "))))

(defun my-remarkup-x ()
  (interactive)
  (my-remarkup-br-to-p)
  (my-remarkup-delete-non-wakati-newline-characters))


;;; Vim

;; "SourceForge.net: vimrc-mode.el - Project Web Hosting - Open Source Software"
;; <http://vimrc-mode.sourceforge.net/>
;;
;;     svn co https://vimrc-mode.svn.sourceforge.net/svnroot/vimrc-mode/vimrc-mode
;;

(when-exists-file-p (dirname (concat user-emacs-directory "vimrc-mode/"))
  (add-to-list 'load-path (expand-file-name dirname)))

(when (locate-library "vimrc-mode")
  (autoload #'vimrc-mode "vimrc-mode" ".vimrc file editing mode.")
  (add-to-list 'auto-mode-alist '("/\\.?vimrc\\'" . vimrc-mode))
  (add-to-list 'auto-mode-alist '("\\.vim\\'" . vimrc-mode))
  (add-to-list 'auto-mode-alist '("/\\.?vim\\(?:\\.d\\)?/.+" . vimrc-mode)))


;;; Debian GNU/Linux

(add-to-list 'auto-mode-alist
  (cons "/debian/changelog\\'"
        (if (or (featurep 'debian-change-log-mode)
                (load "debian-change-log-mode" t))
            #'debian-change-log-mode
          #'change-log-mode)))


;;; Arch Linux

(add-to-list 'auto-mode-alist
  (cons "/PKGBUILD\\'"
        (if (or (featurep 'pkgbuild-mode)
                (load "pkgbuild-mode" t))
            #'pkgbuild-mode
          #'sh-mode)))


;;; Gentoo Linux

(defun-if-undefined ebuild-or-sh-mode ()
  "`ebuild-mode' が使へる場合は `ebuild-mode' を、使へない場合は
`sh-mode' を實行する。"
  (if (fboundp 'ebuild-mode)
      (ebuild-mode)
    (sh-mode)))

(when (require 'gentoo-syntax nil t)
  (add-to-list 'auto-mode-alist '("\\.ebuild\\'" . ebuild-or-sh-mode))
  (add-to-list 'auto-mode-alist '("/make\\.conf\\'" . ebuild-or-sh-mode))
  (add-to-list 'auto-mode-alist '("\\`/etc/portage/env" . ebuild-or-sh-mode))
  (add-to-list 'auto-mode-alist '("/package\.\\(?:use\\|keywords\\|license\\)\\'" . conf-mode))
  ;;
  (add-hook 'ebuild-mode-hook
    #'(lambda ()
        (setq sh-basic-offset 4)
        (setq tab-width 4)
        (setq indent-tabs-mode t)))
  ;;
  (add-hook 'find-file-hook
    #'(lambda ()
        (if (and (string-match "/portage/package\\.[a-z]+\\'" (or (buffer-file-name) ""))
                 (eql major-mode 'conf-space-mode))
            (setq tab-width 50
                  indent-tabs-mode t
                  tab-always-indent nil)))))


;;; Privoxy

(require 'font-lock)

(defvar privoxy-font-lock-keywords
  (let ((filter-keywords-re (regexp-opt '("FILTER"
                                          "SERVER-HEADER-FILTER"
                                          "CLIENT-HEADER-FILTER"
                                          "SERVER-HEADER-TAGGER"
                                          "CLIENT-HEADER-TAGGER")))
        (action-keywords-re (regexp-opt '("BLOCK"
                                          "FILTER"
                                          "HANDLE-AS-EMPTY-DOCUMENT"
                                          "HANDLE-AS-IMAGE"
                                          "SERVER-HEADER-FILTER"
                                          "CLIENT-HEADER-FILTER"
                                          "SERVER-HEADER-TAGGER"
                                          "CLIENT-HEADER-TAGGER"
                                          "REDIRECT"
                                          "FAST-REDIRECTS"
                                          "HIDE-REFERRER"
                                          "HIDE-USER-AGENT"
                                          "ADD-HEADER"))))
    (list
     (cons (concat "^\\([ \t]*\\(?:\\<"
                   filter-keywords-re
                   "\\>\\)[ \t]*:[ \t]*\\)"
                   "\\(?:\\([-_A-Za-z0-9]+\\)\\(.*?\\)[ \t]*\\)?$")
           '((1 font-lock-keyword-face)
             (2 font-lock-function-name-face)
             (3 font-lock-doc-face)))
     (cons (concat "\\([-+]\\)"                   ;\1
                   "\\(" action-keywords-re "\\)" ;\2
                   "[ \t]*"
                   "\\({\\)"            ;\3
                   "[ \t]*"
                   "\\([^ \t}]+?\\)"    ;\4
                   "[ \t]*"
                   "\\(}\\)")           ;\5
           '((2 font-lock-keyword-face)
             (4 font-lock-function-name-face)))
     (cons (concat "\\([-+]\\)"                          ;\1
                   "\\<\\(" action-keywords-re "\\)\\>") ;\2
           '((2 font-lock-keyword-face))))))

(define-derived-mode privoxy-mode fundamental-mode "Privoxy"
  "Major mode for Privoxy action and filter files.

\\{privoxy-mode-map}"
  (set-syntax-table (let ((table (copy-syntax-table text-mode-syntax-table)))
                      (modify-syntax-entry ?\- "_" table)
                      (modify-syntax-entry ?\_ "_" table)
                      (modify-syntax-entry ?\# "<" table)
                      (modify-syntax-entry ?\n ">" table)
                      (modify-syntax-entry ?\\ "\\" table)
                      table))
  (set (make-local-variable (kill-local-variable 'font-lock-defaults))
       '(privoxy-font-lock-keywords nil t))
  (font-lock-fontify-buffer)
  (setq comment-start "#")
  (setq comment-end "")
  (setq comment-end-skip "[ \t]*\\(\\s>\\|\n\\)")
  (setq fill-column 76))

(add-to-list 'auto-mode-alist
  '("privoxy/.+?\\.\\(?:filter\\|action\\)\\'" . privoxy-mode))


;;; Restore Frame Size

;; "EmacsWiki: frame-restore.el"
;; <http://www.emacswiki.org/emacs/download/frame-restore.el>

(when (or (add-to-load-path (locate-user-emacs-file "frame-restore"))
          (locate-library "frame-restore"))
  (require 'frame-restore))


;;; my-escape-region

;; MEMO: なんだこれ? 忘れた。

(defun my-escape-string (string escape-character)
  (let ((new-characters '())
        (i 0)
        (len (length string)))
    (while (< i len)
      (when (char= (elt string i) escape-character)
        (setq new-characters (cons escape-character new-characters)))
      (setq new-characters (cons (elt string i) new-characters))
      (setq i (1+ i)))
    (list-to-string new-characters)))

(defun my-escape-region (start end &optional escape-character)
  (interactive "r")
  (let* ((escape-character ?\\)
         (escape-targets '(?\" ?\())
         (escape-targets-re (concat "["
                                    (my-escape-string
                                     (list-to-string escape-targets) ?\\)
                                    "]")))
    (save-excursion
      (save-restriction
        (narrow-to-region start end)
        (goto-char start)
        (while (re-search-forward escape-targets-re nil t)
          (replace-match (concat (if (char= escape-character ?\\)
                                     "\\\\"
                                   (string escape-character))
                                 (if (char= (char-after (1- (point))) ?\\)
                                     (string ?\\ (char-after (1- (point))))
                                   (string (char-after (1- (point))))))))))))


;;; Apache

(add-to-list 'auto-mode-alist '("/\\.htaccess\\'" . conf-mode))


;;; Compilation Mode

(add-hook 'compilation-mode-hook
  #'(lambda ()
      (setq truncate-lines t)))


;;; Makefile

(add-hook 'makefile-mode-hook
  #'(lambda ()
      ;; C-c C-c を `compile' に束縛する。デフォルトでは
      ;; `comment-region' に束縛されてゐる。
      (local-set-key "\C-c\C-c" #'compile)))


;;; Tabify

(defcustom my-tabify-target-filename-re
  "\\.mecab\\.txt\\'"
  "セーブ時に `tabify' するファイル名の正規表現。"
  :group 'my)

(add-hook 'before-save-hook
  #'(lambda ()
      (if (string-match my-tabify-target-filename-re
                        (or (buffer-file-name) ""))
          (tabify (point-min) (point-max)))))


;;; ~/.gtkrc*

(add-to-list 'auto-mode-alist '("/\\.?gtkrc\\(?:-[0-9]+\\.[0-9]+\\)?\\'"
                                . conf-mode))


;;; Misc Settings

;; カーソルの形状。
(setq-default cursor-type 'box)

;; 行の表示を右端で切捨てるか否か(nilで折返し表示)。
(setq-default truncate-lines t)

;; 改行文字による折返しをする桁數(コマンド fill-paragprah)。
;; TODO: モードごとのfill-column設定。
(setq-default fill-column 72)
(setq-default comment-fill-column 72)

;; 行末コメントの開始桁位置。
(setq-default comment-column 42)

;; `C-j'で 改行と共にインデント。
(setq-default indent-line-function 'indent-relative-maybe)

;; 字下げの空白にタブを用ゐるか否か。
(setq-default indent-tabs-mode nil)

;; バッファ末尾の改行も何も無い「行」を強調表示するか。
(setq-default indicate-empty-lines t)

;; `kill-line' で改行も一緒にkillするか。
(setq-default kill-whole-line t)

;;
(setq-default backward-delete-char-untabify-method 'hungry)

;; スクロールした際に前の畫面で表示してゐた内容を何行殘すか。
(setq-default next-screen-context-lines 1)

;; バッファ末尾が改行でない状態で保存しようとした場合の擧動。t は確認せず自
;; 動追加。nil は 何もしない。t でも nil でもない場合は確認する。
(setq-default require-final-newline nil)

;; Tabキー、インデント關聯。
(setq-default tab-always-indent 'always)

;;
(setq-default visible-bell t)

;;
(setq-default x-select-enable-clipboard t)

;; 行間。
(setq-default line-spacing 0)

;;
(setq-default scroll-conservatively line-spacing)

;;
(setq-default adaptive-fill-mode t)

;; バッファ名やファイル名の補完で大文字小文字の違ひを吸收する。
;; (setq read-file-name-completion-ignore-case t)
;; (setq read-buffer-completion-ignore-case t)

;; 履歴。
(setq history-length 4096)
(setq kill-ring-max 4096)

;; 檢索。
(setq apropos-do-all t)

;;
(setq eval-expression-print-level nil)

;;
(setq inhibit-startup-screen t)

;;
(setq shell-command-on-region-prompt "Shell command on region %$ ")

;; User name and email address
(setq user-full-name "MORIYAMA Hiroshi")
(setq user-mail-address "hiroshi@kvd.biglobe.ne.jp")

;; Use the system's trash can:
;; FIXME: これが t だと `server-start' がエラー("File error: Cannot bind
;; server socket, address already in use")になる問題があるので現在は nil に
;; してゐる。
(setq delete-by-moving-to-trash t)

;; ウィンドウ。
(setq split-height-threshold 80)
(setq split-width-threshold 130)


;;; Use `delete-window' instead of `quit-window'

(defadvice quit-window (around use-delete-window-instead (&rest args) activate)
  "`quit-window' はウインドウを削除しない。このアドヴァイスは對話
的に `quit-window' が呼出されたとき(`help-mode' の \"q\" 等)、代り
に `delete-window' を使用して對象ウインドウを削除する。"
  (interactive "P")
  (if (and (interactive-p)
           (null (delete nil args))
           (> (length (window-list)) 1))
      (call-interactively #'delete-window (nth 1 args))
    ad-do-it))


;;; Insert NUL character

(defun insert-null-char ()
  (interactive)
  (insert "\0"))


;;; Insert EM Dash

(defun insert-dash ()
  (interactive)
  (insert "—"))

(defun quote-by-emdash (start end)
  (interactive "r")
  (save-restriction
    (narrow-to-region start end)
    (goto-char (point-min))
    (insert "——")
    (unless (= start end)
      (goto-char (point-max))
      (insert "——"))
    (goto-char (point-max))))

(defalias 'emdash-quote-region 'quote-by-emdash)


;;; Anything

;; (when (require 'anything nil t)
;;   (require 'anything-config)
;;   (add-to-list 'anything-sources 'anything-c-source-emacs-commands))


;;; EmacsWiki

(add-to-load-path "/usr/share/emacs/site-lisp/emacs-wiki")

(require 'emacs-wiki)

(eval-after-load "emacs-wiki"
  '(progn
     ))


;;; Desktop --- Save and Restore Session

(defun my-filter (list excludes)
  (let (new-list)
    (dolist (elt list)
      (unless (member elt excludes)
        (setq new-list
              (cons elt new-list))))
    new-list))

;; Window System上で起動された場合のみセッションを保存・復元する:
(when (and window-system (require 'desktop nil t))
  ;; セーブファイル `~/.emacs.desktop' が無ければ新たに作る:
  (unless (desktop-full-file-name)
    (desktop-save desktop-dirname))
  (desktop-save-mode 1)
  (setq desktop-save t)
  (setq desktop-load-locked-desktop t)
  ;; `desktop-globals-to-save': 保存・復元する變數。對象變數を束縛するオブジェ
  ;; クトがリストの場合、保存するその要素の最大數をドット對表記で指定できる。
  ;;
  ;; Example:
  ;;
  ;;     (setq desktop-globals-to-save
  ;;           `((kill-ring . 256)
  ;;             register-alist
  ;;             file-name-history))
  ;;
  ;; ここで指定した「セッション復元時に復活させる最大數」と、實際に使用する最大
  ;; 數の設定は別であることに注意したい。カスタマイズ變數 `kill-ring-max' や
  ;; `history-length' なども參照のこと。
  ;;
  (setq desktop-globals-to-save
        `(kill-ring ;"Saving `kill-ring' implies saving `kill-ring-yank-pointer'."
          register-alist
          tags-file-name
          tags-table-list
          search-ring
          regexp-search-ring
          file-name-history
          compile-history
          extended-command-history
          grep-history
          minibuffer-history
          query-replace-history
          read-expression-history
          regexp-history
          shell-command-history))
  (setq desktop-files-not-to-save
        (concat "\\(?:"
                "/[^/:]*:"
                ;; System directories.
                (concat "\\`/" (regexp-opt
                                (my-filter (directory-files "/")
                                           '("." ".." "home"))) "/")
                "\\|/tmp/"
                ;; VCS.
                "\\|/\\.git/"
                "\\|/{arch}/"
                ;; Archive files.
                "\\|\\.tar\\(?:\\.\\|'\\)"
                "\\|\\.gz\\'"
                "\\|\\.jar\\'"
                ;; Others.
                "\\|/ScrapBook/"
                "\\)"))
  (setq desktop-modes-not-to-save
        (append'(dired-mode
                 Info-mode
                 info-lookup-mode
                 tags-table-mode
                 hatena-mode
                 hatena-diary-mode)
               desktop-modes-not-to-save))
  ;; 一分毎に保存:
  (run-at-time "1 min" 60 #'(lambda () (desktop-save (expand-file-name "~/"))))
  ;; Restore the previous session:
  (unless (and (boundp 'my-do-not-read-desktop)
               my-do-not-read-desktop))
  (desktop-read))


;;; 讀んでくれてありがたう( ´ ▽ ` )ﾉ
;;; init.el ends here.
